//
//  EditProfileViewController.swift
//  Messenger
//
//  Created by Ngô Hải Đăng on 12/09/2022.
//

import UIKit

class EditProfileViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.identifier)
        return tableView
    }()
    
    var models = [Section]()
    
    private var textFieldObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configure()
        title = "Profile Details"
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissSelf))
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
    
    func configure() {
        models.append(Section(title: "Public Profile", options: [
            ProfileViewModel(viewModelType: .detail, title: "First Name", value: UserDefaults.standard.value(forKey: "first_name") as? String ?? "None", icon: nil, handler: { [weak self] value in
                let alert = UIAlertController(title: "Change First Name", message: "", preferredStyle: .alert)
                
                alert.addTextField { textField in
                    textField.placeholder = "First Name"
                    textField.text = value
                }
                
                let saveAction = UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
                    
                    guard let textValue = alert.textFields?[0].text?.replacingOccurrences(of: " ", with: "") as? String else {
                        return
                    }
                    
                    if let textFieldObserver = self?.textFieldObserver {
                        NotificationCenter.default.removeObserver(textFieldObserver)
                    }
                    
                    // Change First Name
                    guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
                        return
                    }
                    DatabaseManager.shared.updateInfoUser(with: email, options: .firstName, value: textValue) { [weak self] success in
                        if success {
                            DispatchQueue.main.async {
                                UserDefaults.standard.set(textValue, forKey: "first_name")
                                self?.tableView.reloadData()
                            }
                            
                            print("Updated First Name")
                        }
                    }
                })
                
                saveAction.isEnabled = true
                
                self?.textFieldObserver = NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: nil, queue: .main, using: { _ in
                    
                    guard let textField = alert.textFields?[0] as? UITextField,
                          let textValue = textField.text else {
                        return
                    }
                    saveAction.isEnabled = !textValue.isEmpty
                })
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alert.addAction(saveAction)
                
                self?.present(alert, animated: true)
            }),
            ProfileViewModel(viewModelType: .detail, title: "Last Name", value: UserDefaults.standard.value(forKey: "last_name") as? String ?? "None", icon: nil, handler: { [weak self] value in
                let alert = UIAlertController(title: "Change Last Name", message: "", preferredStyle: .alert)
                
                alert.addTextField { textField in
                    textField.placeholder = "Last Name"
                    textField.text = value
                }
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                self?.present(alert, animated: true)
            })
        ]))
        
        models.append(Section(title: "Private Profile", options: [
            ProfileViewModel(viewModelType: .detail, title: "Email Address", value: UserDefaults.standard.value(forKey: "email") as? String ?? "None", icon: nil, handler: nil)
        ]))
    }
    
}

extension EditProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        models.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models[section].options.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        models[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier, for: indexPath) as! ProfileTableViewCell
        let model = models[indexPath.section].options[indexPath.row]
        cell.selectionStyle = .none
        cell.setup(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
//        let model = models[indexPath.section].options[indexPath.row]
//        guard let value = model.value else {
//            return
//        }
//        model.handler?(value)
    }
    
}
