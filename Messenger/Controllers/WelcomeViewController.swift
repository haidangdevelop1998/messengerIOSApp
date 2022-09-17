//
//  WelcomeViewController.swift
//  Messenger
//
//  Created by Ngô Hải Đăng on 07/09/2022.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "message.fill")
        imageView.tintColor = UIColor.chatAppColor
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to Chat App"
        label.textColor = UIColor.chatAppColor
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        return label
    }()
    
    private let introLabel: UILabel = {
        let label = UILabel()
        label.text = "Stay in touch with your \n best friends."
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20)
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = UIColor.chatAppColor
        button.layer.cornerRadius = 25
        button.setTitleColor(.white, for: .normal)
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        return button
    }()
    
    private let signupButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray.cgColor
        button.setTitleColor(.black, for: .normal)
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(logoImageView)
        view.addSubview(welcomeLabel)
        view.addSubview(introLabel)
        view.addSubview(loginButton)
        view.addSubview(signupButton)
        
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        signupButton.addTarget(self, action: #selector(didTapSignup), for: .touchUpInside)

        navigationController?.navigationBar.tintColor = UIColor.chatAppColor
        let backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let size = view.width/3
        logoImageView.frame = CGRect(x: (view.width-size)/2, y: 200, width: size, height: size)
        welcomeLabel.frame = CGRect(x: 30, y: logoImageView.bottom+30, width: view.width-60, height: 40)
        introLabel.frame = CGRect(x: 30, y: welcomeLabel.bottom+20, width: view.width-60, height: 80)
        introLabel.center.x = view.center.x
        loginButton.frame = CGRect(x: 30, y: introLabel.bottom+40, width: view.width-150, height: 50)
        loginButton.center.x = view.center.x
        signupButton.frame = CGRect(x: 30, y: loginButton.bottom+20, width: view.width-150, height: 50)
        signupButton.center.x = view.center.x
    }
    
    @objc func didTapLogin() {
        let vc = LoginViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapSignup() {
        let vc = RegisterViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

}
