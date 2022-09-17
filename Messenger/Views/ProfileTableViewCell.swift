//
//  ProfileTableViewCell.swift
//  Messenger
//
//  Created by Ngô Hải Đăng on 09/09/2022.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    static let identifier = "ProfileTableViewCell"
    
    private let iconImageView: UIImageView = {
        let view = UIImageView()
        view.isHidden = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
 
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.addSubview(iconImageView)
        
        if !iconImageView.isHidden {
            iconImageView.frame = CGRect(x: 15, y: 10, width: 30, height: 30)
            textLabel?.translatesAutoresizingMaskIntoConstraints = false
            textLabel?.leftAnchor.constraint(equalTo: iconImageView.rightAnchor, constant: 15).isActive = true
            textLabel?.heightAnchor.constraint(equalToConstant: contentView.height).isActive = true
        }
    }
    
    public func setup(with viewModel: ProfileViewModel) {
        textLabel?.text = viewModel.title
        iconImageView.image = viewModel.icon?.image
        iconImageView.tintColor = viewModel.icon?.color
        switch viewModel.viewModelType {
        case .logout:
            textLabel?.textColor = .systemRed
        case .settings:
            accessoryType = .disclosureIndicator
        case .detail:
            iconImageView.isHidden = true
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: contentView.width/1.5, height: 20))
            label.text = viewModel.value
            label.textAlignment = .right
            accessoryView = label
        }
    }
}
