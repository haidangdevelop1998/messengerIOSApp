//
//  ProfileViewController.swift
//  Messenger
//
//  Created by Ngô Hải Đăng on 16/08/2022.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import SDWebImage

final class ProfileViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var data = [ProfileViewModel]()
    
    private var loginObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.addCustomBottomLine(color: .systemGray5, height: 1)
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.identifier)
        
        initProfile()
        
        data.append(ProfileViewModel(viewModelType: .logout, title: "Log Out", value: nil, icon: IconProfile(image: UIImage(systemName: "square.and.arrow.up"), color: UIColor.systemRed), handler: { [weak self] in
            
            guard let strongSelf = self else { return }
            
            let actionSheet = UIAlertController(title: "Are you sure?", message: "", preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self]_ in
                
                guard let strongSelf = self else { return }
               
                // Log out FB
                FBSDKLoginKit.LoginManager().logOut()
                
                // Log out Google
                GIDSignIn.sharedInstance.signOut()
                
                do {
                    // Firebase Logout
                    try FirebaseAuth.Auth.auth().signOut()
                    
                    // Change user online status
                    guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                        return
                    }
                    let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
                    DatabaseManager.shared.changeUserOnlineStatus(with: safeEmail, status: false) { success in
                        if success {
                            print("Change status successfully")
                        }
                    }
                    
                    // Remove cache
                    UserDefaults.standard.setValue(nil, forKey: "email")
                    UserDefaults.standard.setValue(nil, forKey: "name")
                    
                    // show welcome view
                    let vc = WelcomeViewController()
                    let navi = UINavigationController(rootViewController: vc)
                    navi.modalPresentationStyle = .fullScreen
                    strongSelf.present(navi, animated: true)
                } catch {
                    print("Failed Logout!")
                }
                
            }))
            
            strongSelf.present(actionSheet, animated: true)
        }))
        
        // Register tableview
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createTableHeader()
        tableView.separatorStyle = .none
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLoginNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            self?.tabBarController?.selectedIndex = 0
            strongSelf.updateProfile()
        })
    }
    
    private func updateProfile()  {
        if let loginObserver = loginObserver {
            NotificationCenter.default.removeObserver(loginObserver)
        }
        
        print("start updating profile")
        
//        initProfile()
//        tableView.reloadData()
    }
    
    private func initProfile() {
        
        data.append(ProfileViewModel(viewModelType: .settings, title: "Account Details", value: nil, icon: IconProfile(image: UIImage(systemName: "person.crop.circle"), color: UIColor.chatAppColor), handler: { [weak self] in
            let vc = EditProfileViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        }))
        data.append(ProfileViewModel(viewModelType: .settings, title: "Settings", value: nil, icon: IconProfile(image: UIImage(systemName: "gearshape"), color: UIColor.systemGray), handler: nil))
        data.append(ProfileViewModel(viewModelType: .settings, title: "Dark Mode", value: nil, icon: IconProfile(image: UIImage(systemName: "moon.circle.fill"), color: UIColor.systemGray), handler: nil))
    }
    
    private func createTableHeader() -> UIView? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String,
        let fullName = UserDefaults.standard.value(forKey: "name") as? String else {
            return nil
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let fileName = safeEmail + "_profile_picture.png"
        let path = "images/" + fileName
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 260))
        
        let imageView = UIImageView(frame: CGRect(x: (headerView.width-150)/2, y: 30, width: 150, height: 150))
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .white
        imageView.layer.borderColor = UIColor.systemGray3.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.cornerRadius = imageView.width/2
        imageView.layer.masksToBounds = true
        
        let fullNameLabel = UILabel(frame: CGRect(x: 0, y: imageView.bottom+30, width: headerView.width-250, height: 30))
        fullNameLabel.textAlignment = .center
        fullNameLabel.center.x = headerView.center.x
        fullNameLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        fullNameLabel.text = fullName
        
        headerView.addSubview(imageView)
        headerView.addSubview(fullNameLabel)
        
        
        StorageManager.shared.downloadURL(for: path) { result in
            switch result {
            case .success(let url):
                // Use SDWebImage
                DispatchQueue.main.async {
                    imageView.sd_setImage(with: url, completed: nil)
                }
                // Download image from firebase
//                self?.downloadImage(imageView: imageView, url: url)
            case .failure(let error):
                print("Failed to get download url: \(error)")
            }
        }
        
        return headerView
    }
    
//    func downloadImage(imageView: UIImageView, url: URL) {
//        URLSession.shared.dataTask(with: url) { data, _, error in
//            guard let data = data, error ==  nil else {
//                return
//            }
//
//            DispatchQueue.main.async {
//                let image = UIImage(data: data)
//                imageView.image = image
//            }
//        }.resume()
//    }

}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier, for: indexPath) as! ProfileTableViewCell
        cell.setup(with: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        data[indexPath.row].handler?()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
}
