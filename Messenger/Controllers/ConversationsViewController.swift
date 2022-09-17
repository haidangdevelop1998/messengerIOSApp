//
//  ViewController.swift
//  Messenger
//
//  Created by Ngô Hải Đăng on 16/08/2022.
//

import UIKit
import FirebaseAuth
import JGProgressHUD
import UserNotifications

/// Controller that shows list of coversations
final class ConversationsViewController: UIViewController {
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var conversations = [Conversation]()
    
    private var users = [SearchResultUser]()
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.isHidden = true
        table.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier)
        return table
    }()
    
    private let noConversationLabel: UILabel = {
        let label = UILabel()
        label.text = "No Conversations!"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    private var loginObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.addCustomBottomLine(color: .systemGray5, height: 1)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeButton))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.chatAppColor
        
        tableView.separatorStyle = .none
        tableView.register(ConversationsTableHeaderView.self, forHeaderFooterViewReuseIdentifier: "header")
        
        view.addSubview(tableView)
        view.addSubview(noConversationLabel)
        setupTableView()
        getAllUsers()
        startListeningForConversations()
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLoginNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
           
            strongSelf.getAllUsers()
            strongSelf.startListeningForConversations()
        })
    }
    
    private func pushNotification(title: String, message: String) {
        
        self.notificationCenter.getNotificationSettings { [weak self] settings in
            
            DispatchQueue.main.async {
                
                if settings.authorizationStatus == .authorized {
                    let content = UNMutableNotificationContent()
                    content.title = title
                    content.body = message
                    
                    let date = Date().addingTimeInterval(5)
                    let dateComp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    
                    self?.notificationCenter.add(request) { error in
                        
                            print("push notification!")
                        if error != nil {
                            print("Error: \(error.debugDescription)")
                            return
                        }
                    }
                }
            }
        }
    }
    
    private func getAllUsers() {
        
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        
        if let loginObserver = loginObserver {
            NotificationCenter.default.removeObserver(loginObserver)
        }
        
        DatabaseManager.shared.getAllUsers { [weak self] result in
            switch result {
            case .success(let users):
                let results: [SearchResultUser] = users.compactMap({
                    guard let email = $0["email"], email != safeEmail, let name = $0["name"] else {
                        return nil
                    }
                    return SearchResultUser(name: name, email: email)
                })
                self?.users = results
                
            case .failure(let error):
                print("Failed to get users: \(error)")
            }
        }
    }
 
    private func startListeningForConversations()  {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        if let loginObserver = loginObserver {
            NotificationCenter.default.removeObserver(loginObserver)
        }
        
        print("start listening for conversations")
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        DatabaseManager.shared.getAllConversations(for: safeEmail) { [weak self] result in
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else {
                    self?.tableView.isHidden = true
                    self?.noConversationLabel.isHidden = false
                    return
                }
                
                self?.tableView.isHidden = false
                self?.noConversationLabel.isHidden = true
                self?.conversations = conversations
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
            case .failure(let error):
                self?.tableView.isHidden = true
                self?.noConversationLabel.isHidden = false
                print("Failed to get conversations: \(error)")
            }
        }
    }
    
    @objc private func didTapComposeButton() {
        print("didTapComposeButton")
        let vc = NewConversationViewController()
        vc.completion = { [weak self] result in
            let currentConversations = self?.conversations
            if let targetConversation = currentConversations?.first(where: {
                $0.otherUserEmail == DatabaseManager.safeEmail(emailAddress: result.email)
            }) {
                let vc = ChatViewController(with: targetConversation.otherUserEmail, id: targetConversation.id)
                vc.isNewConversation = false
                vc.title = targetConversation.name
                vc.navigationItem.largeTitleDisplayMode = .never
                self?.navigationController?.pushViewController(vc, animated: true)
            } else {
                self?.createNewConversation(result: result)
            }
        }
        let navi = UINavigationController(rootViewController: vc)
        present(navi, animated: true)
    }
    
    private func createNewConversation(result: SearchResultUser) {
        let name = result.name
        let email = DatabaseManager.safeEmail(emailAddress: result.email)
        
        // Check in the database if conversation with these two user exists
        // if it does, reuse conversation id
        // otherwise use existing code
        
        DatabaseManager.shared.checkConversationExists(with: email) { [weak self] result in
            switch result {
            case .success(let conversationID):
                let vc = ChatViewController(with: email, id: conversationID)
                vc.isNewConversation = false
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                self?.navigationController?.pushViewController(vc, animated: true)
            case .failure(_):
                // create trully new conversation
                let vc = ChatViewController(with: email, id: nil)
                vc.isNewConversation = true
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = view.bounds
        noConversationLabel.frame = CGRect(x: 10, y: (view.height-100)/2, width: view.width-20, height: 100)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = WelcomeViewController()
            let navi = UINavigationController(rootViewController: vc)
            navi.modalPresentationStyle = .fullScreen
            navi.navigationBar.backgroundColor = .white
            present(navi, animated: false)
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
}

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier,
                                                 for: indexPath) as! ConversationTableViewCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        openConversation(model)
    }
    
    func openConversation(_ model: Conversation) {
        let vc = ChatViewController(with: model.otherUserEmail, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            showDeleteWarning(for: indexPath)
        }
    }
    
    func showDeleteWarning(for indexPath: IndexPath) {
        //Create the alert controller and actions
        let alert = UIAlertController(title: "Are you sure want to delete the conversation?", message: "", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            DispatchQueue.main.async {
                // begin delete
                let conversationID = strongSelf.conversations[indexPath.row].id
                strongSelf.tableView.beginUpdates()
                strongSelf.conversations.remove(at: indexPath.row)
                strongSelf.tableView.deleteRows(at: [indexPath], with: .left)
                
                DatabaseManager.shared.deleteConversation(conversationID: conversationID) { success in
                    if !success {
                        // add model and row back and show error alert
                        
                    }
                }
                
                self?.tableView.endUpdates()
            }
        }

        //Add the actions to the alert controller
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)

        //Present the alert controller
        present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: "header")! as! ConversationsTableHeaderView
        header.configure(with: users)
        header.delegate = self
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        150
    }
}

extension ConversationsViewController: CollectionTableViewHeaderDelegate {
    func collectionTableViewHeaderDidTapItem(with userData: SearchResultUser) {
        if let targetConversation = conversations.first(where: {
            $0.otherUserEmail == DatabaseManager.safeEmail(emailAddress: userData.email)
        }) {
            let vc = ChatViewController(with: targetConversation.otherUserEmail, id: targetConversation.id)
            vc.isNewConversation = false
            vc.title = targetConversation.name
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        } else {
            createNewConversation(result: userData)
        }
    }
}

