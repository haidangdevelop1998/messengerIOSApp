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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configure()
        title = "Edit profile"
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
            ProfileViewModel(viewModelType: .detail, title: "First Name", value: UserDefaults.standard.value(forKey: "first_name") as? String ?? "None", icon: nil, handler: {
                
            }),
            ProfileViewModel(viewModelType: .detail, title: "Last Name", value: UserDefaults.standard.value(forKey: "last_name") as? String ?? "None", icon: nil, handler: {
                
            })
        ]))
        
        models.append(Section(title: "Private Profile", options: [
            ProfileViewModel(viewModelType: .detail, title: "Email Address", value: UserDefaults.standard.value(forKey: "email") as? String ?? "None", icon: nil, handler: {
                
            })
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
        cell.setup(with: model)
        return cell
    }
    
    
}
