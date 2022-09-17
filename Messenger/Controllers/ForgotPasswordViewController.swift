//
//  ForgotPasswordViewController.swift
//  Messenger
//
//  Created by Ngô Hải Đăng on 07/09/2022.
//

import UIKit

class ForgotPasswordViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Reset Password"
        label.textColor = UIColor.chatAppColor
        label.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        return label
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.placeholder = "E-mail Address"
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
    
    private let resetButton: UIButton = {
        let button = UIButton()
        button.setTitle("Reset My Password", for: .normal)
        button.backgroundColor = UIColor.chatAppColor
        button.layer.cornerRadius = 10
        button.setTitleColor(.white, for: .normal)
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(emailField)
        scrollView.addSubview(resetButton)
 
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        titleLabel.frame = CGRect(x: 30, y: 50, width: scrollView.width-60, height: 45)
        emailField.frame = CGRect(x: 30, y: titleLabel.bottom+40, width: scrollView.width-60, height: 50)
        resetButton.frame = CGRect(x: 30, y: emailField.bottom+25, width: scrollView.width-100, height: 50)
        
        resetButton.center.x = view.center.x
    }

}
