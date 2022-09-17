//
//  LoginViewController.swift
//  Messenger
//
//  Created by Ngô Hải Đăng on 16/08/2022.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import Firebase
import JGProgressHUD

final class LoginViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign In"
        label.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        return label
    }()
    
    private let divideLabel: UILabel = {
        let label = UILabel()
        label.text = "OR"
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    private let forgotPassButton: UIButton = {
        let button = UIButton()
        button.setTitle("Forgot Password?", for: .normal)
        button.setTitleColor(UIColor.chatAppColor, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        return button
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.placeholder = "E-mail"
        field.layer.cornerRadius = 25
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        field.leftViewMode = .always
        field.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        field.rightViewMode = .always
        field.backgroundColor = .systemBackground
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.placeholder = "Password"
        field.layer.cornerRadius = 25
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        field.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        field.leftViewMode = .always
        field.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        field.rightViewMode = .always
        field.backgroundColor = .systemBackground
        field.isSecureTextEntry = true
        return field
    }()
    
    private let loginButton: UIButton = {
        let loginButton = UIButton()
        loginButton.setTitle("Log In", for: .normal)
        loginButton.backgroundColor = UIColor.chatAppColor
        loginButton.layer.cornerRadius = 10
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.masksToBounds = true
        loginButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        return loginButton
    }()

    private let facebookLoginButton: FBLoginButton = {
        let facebookLoginButton = FBLoginButton()
        facebookLoginButton.permissions = ["email", "public_profile"]
        facebookLoginButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        return facebookLoginButton
    }()
    
    private let googleLoginButton: GIDSignInButton = {
        let googleLoginButton = GIDSignInButton()
        return googleLoginButton
    }()
    
    private var loginObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLoginNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
        
        view.backgroundColor = .systemBackground
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        googleLoginButton.addTarget(self, action: #selector(googleLogin), for: .touchUpInside)
        
        // TextFiled Delegate
        emailField.delegate = self
        passwordField.delegate = self
        
        facebookLoginButton.delegate = self
        
        // Add Subviews
        view.addSubview(scrollView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(facebookLoginButton)
        scrollView.addSubview(googleLoginButton)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(forgotPassButton)
        scrollView.addSubview(divideLabel)

        emailField.becomeFirstResponder()
        
        forgotPassButton.addTarget(self, action: #selector(didTapForgotPassword), for: .touchUpInside)
        
        let backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
    }
    
    deinit {
        if let loginObserver = loginObserver {
            NotificationCenter.default.removeObserver(loginObserver)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        titleLabel.frame = CGRect(x: 30, y: 50, width: scrollView.width-60, height: 45)
        emailField.frame = CGRect(x: 30, y: titleLabel.bottom+50, width: scrollView.width-60, height: 50)
        passwordField.frame = CGRect(x: 30, y: emailField.bottom+20, width: scrollView.width-60, height: 50)
        forgotPassButton.frame = CGRect(x: 30, y: passwordField.bottom+10, width: scrollView.width-60, height: 45)
        forgotPassButton.contentHorizontalAlignment = .right
        loginButton.frame = CGRect(x: 30, y: forgotPassButton.bottom+10, width: scrollView.width-100, height: 50)
        divideLabel.frame = CGRect(x: 30, y: loginButton.bottom+30, width: scrollView.width-60, height: 45)
        facebookLoginButton.frame = CGRect(x: 30, y: divideLabel.bottom+20, width: scrollView.width-100, height: 50)
        googleLoginButton.frame = CGRect(x: 30, y: facebookLoginButton.bottom+20, width: scrollView.width-100, height: 50)
        
        loginButton.center.x = scrollView.center.x
        facebookLoginButton.center.x = scrollView.center.x
        googleLoginButton.center.x = scrollView.center.x
    }
    
    @objc func didTapForgotPassword() {
        let vc = ForgotPasswordViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func loginButtonTapped() {
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserLoginError()
            return
        }
        
        // show spinner when login
        spinner.show(in: view)
        
        // Firebase Login
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            
            // dismiss spinner
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard authResult != nil, error == nil else {
                print("Failed to login with email \(email).")
                strongSelf.alertUserLoginFailed()
                return
            }
            
            let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
            DatabaseManager.shared.getDataFor(path: safeEmail) { result in
                switch result {
                case .success(let data):
                    guard let userData = data as? [String: Any],
                          let firstName = userData["firstName"] as? String,
                          let lastName = userData["lastName"] as? String
                    else {
                        return
                    }
                    
                    UserDefaults.standard.setValue("\(firstName) \(lastName)", forKey: "name")
                    UserDefaults.standard.setValue(firstName, forKey: "first_name")
                    UserDefaults.standard.setValue(lastName, forKey: "last_name")
                    
                case .failure(let error):
                    print("Failed to read data with error: \(error)")
                }
            }
            
            
            // Update user online status
            DatabaseManager.shared.changeUserOnlineStatus(with: safeEmail, status: true) { success in
                if success {
                    print("Change status successfully")
                }
            }
            
            UserDefaults.standard.setValue(email, forKey: "email")
            
            // Dismiss Login view when login successfully
            NotificationCenter.default.post(name: .didLoginNotification, object: nil)
        }
    }
    
    private func alertUserLoginError() {
        let alert = UIAlertController(title: "Woops", message: "Please enter all information to login", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(alert, animated: true)
    }
    
    private func alertUserLoginFailed() {
        let alert = UIAlertController(title: "Woops", message: "Failed to login! Please check your email or password.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc func googleLogin() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        
        // show spinner when login
        spinner.show(in: view)
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { user, error in
            
            guard error == nil else { return }
            
            // unwrap and get email, first name and last name
            guard let email = user?.profile?.email,
                  let firstName = user?.profile?.givenName,
                  let lastName = user?.profile?.familyName
            else {
                print("Failed to get google user information.")
                return
            }
            
            UserDefaults.standard.setValue(email, forKey: "email")
            UserDefaults.standard.setValue("\(firstName) \(lastName)", forKey: "name")
            UserDefaults.standard.setValue(firstName, forKey: "first_name")
            UserDefaults.standard.setValue(lastName, forKey: "last_name")
            
            // check exists user
            DatabaseManager.shared.checkUserExists(with: email) { exists in
                if !exists {
                    
                    // insert user to database
                    let chatUser = ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email, isOnline: true)
                    DatabaseManager.shared.insertUser(with: chatUser) { success in
                        if success {
                            guard let url = user?.profile?.imageURL(withDimension: 200) else {
                                return
                            }
                            
                            // Download data from facebook image
                            URLSession.shared.dataTask(with: url) { data, _, _ in
                                guard let data = data else {
                                    print("Failed to get data from google image")
                                    return
                                }
                                
                                // upload image
                                let fileName = chatUser.profilePictureFileName
                                StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName) { result in
                                    switch result {
                                    case .failure(let error):
                                        print("Storage manager error: \(error)")
                                    case.success(let downloadUrl):
                                        print(downloadUrl)
                                        UserDefaults.standard.setValue(downloadUrl, forKey: "profile_picture_url")
                                    }
                                }
                            }.resume()
                        }
                    }
                }
            }
            
            
            guard let authentication = user?.authentication,
                    let idToken = authentication.idToken
            else {
                print("Missing auth object off of google user")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            
            FirebaseAuth.Auth.auth().signIn(with: credential) { [weak self ]authResult, error in
                
                // dismiss spinner
                DispatchQueue.main.async {
                    self?.spinner.dismiss()
                }
                
                guard authResult != nil, error == nil else {
                    print("Google credential login failed.")
                    return
                }
                
                print("Successfully logged user in.")
                
                // Update user online status
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                DatabaseManager.shared.changeUserOnlineStatus(with: safeEmail, status: true) { success in
                    if success {
                        print("Change status successfully")
                    }
                }
                
                NotificationCenter.default.post(name: .didLoginNotification, object: nil)
            }
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else {
            loginButtonTapped()
        }
        
        return true
    }
}

extension LoginViewController: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        //
    }
    
    // Login with facebook
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        // Get token and unwrap it
        guard let token = result?.token?.tokenString else {
            print("User failed to log in with facebook.")
            return
        }
        
        // show spinner when login
        spinner.show(in: view)
        
        // Create graph request to get information(email, name) from Facebook
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "email, first_name, last_name, picture.type(large)"], tokenString: token, version: nil, httpMethod: .get)
        
        facebookRequest.start { _, result, error in
            guard let result = result as? [String: Any], error == nil else {
                print("Falied to make facebook graph request.")
                return
            }
            
            // unwrap name and email
            guard let firstName = result["first_name"] as? String,
                  let lastName = result["last_name"] as? String,
                  let email = result["email"] as? String,
                  let picture = result["picture"] as? [String: Any],
                  let data = picture["data"] as? [String: Any],
                  let pictureUrl = data["url"] as? String
            else {
                print("Failed to get email and name from fb result.")
                return
            }
            
            UserDefaults.standard.setValue(email, forKey: "email")
            UserDefaults.standard.setValue("\(firstName) \(lastName)", forKey: "name")
            UserDefaults.standard.setValue(firstName, forKey: "first_name")
            UserDefaults.standard.setValue(lastName, forKey: "last_name")
            
            // check exists user
            DatabaseManager.shared.checkUserExists(with: email) { exists in
                if !exists {
                    // insert user to database
                    let chatUser = ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email, isOnline: true)
                    DatabaseManager.shared.insertUser(with: chatUser) { success in
                        if success {
                            guard let url = URL(string: pictureUrl) else {
                                return
                            }
                            
                            // Download data from facebook image
                            URLSession.shared.dataTask(with: url) { data, _, _ in
                                guard let data = data else {
                                    print("Failed to get data from facebook image")
                                    return
                                }
                                
                                // upload image
                                let fileName = chatUser.profilePictureFileName
                                StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName) { result in
                                    switch result {
                                    case .failure(let error):
                                        print("Storage manager error: \(error)")
                                    case.success(let downloadUrl):
                                        print(downloadUrl)
                                        UserDefaults.standard.setValue(downloadUrl, forKey: "profile_picture_url")
                                    }
                                }
                            }.resume()
                        }
                    }
                }
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            
            // singin
            FirebaseAuth.Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                
                // dismiss spinner
                DispatchQueue.main.async {
                    self?.spinner.dismiss()
                }
                
                guard authResult != nil, error == nil else {
                    print("Facebook credential login failed, MFA may be need.")
                    return
                }
                
                print("Successfully logged user in.")
                
                // Update user online status
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                DatabaseManager.shared.changeUserOnlineStatus(with: safeEmail, status: true) { success in
                    if success {
                        print("Change status successfully")
                    }
                }
                
                // Dismiss Login view when login successfully
                NotificationCenter.default.post(name: .didLoginNotification, object: nil)
            }
        }
    }
}
