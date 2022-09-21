//
//  ConversationTableViewCell.swift
//  Messenger
//
//  Created by Ngô Hải Đăng on 27/08/2022.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
    
    static let identifier = "ConversationTableViewCell"
    
    private let userImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 35
        image.layer.masksToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let userMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 1
//        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let sendDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
//        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let onlineStatusView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.chatAppColor
        view.layer.cornerRadius = 9
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.systemBackground.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
        contentView.addSubview(sendDateLabel)
        contentView.addSubview(onlineStatusView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // Change border color when appearance changes (dark-light)
        onlineStatusView.layer.borderColor = UIColor.systemBackground.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLayout()
    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        self.userMessageLabel.font = .systemFont(ofSize: 16, weight: .regular)
        self.sendDateLabel.font = .systemFont(ofSize: 16, weight: .regular)
    }
    
    private func setupLayout() {
        userImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        userImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        userImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        userImageView.heightAnchor.constraint(equalTo: userImageView.widthAnchor).isActive = true
        
        userNameLabel.leftAnchor.constraint(equalTo: userImageView.rightAnchor, constant: 10).isActive = true
        userNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
        userNameLabel.widthAnchor.constraint(equalToConstant: contentView.width-20-userImageView.width).isActive = true
        userNameLabel.heightAnchor.constraint(equalToConstant: (contentView.height-50)/2).isActive = true
        
        userMessageLabel.leftAnchor.constraint(equalTo: userNameLabel.leftAnchor).isActive = true
        userMessageLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor).isActive = true
        userMessageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: contentView.width-100-userImageView.width).isActive = true
        userMessageLabel.heightAnchor.constraint(equalToConstant: (contentView.height-30)/2).isActive = true
        
        sendDateLabel.leftAnchor.constraint(equalTo: userMessageLabel.rightAnchor, constant: 5).isActive = true
        sendDateLabel.topAnchor.constraint(equalTo: userMessageLabel.topAnchor).isActive = true
        sendDateLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendDateLabel.heightAnchor.constraint(equalTo: userMessageLabel.heightAnchor).isActive = true
        
        onlineStatusView.leftAnchor.constraint(equalTo: userImageView.rightAnchor, constant: -18).isActive = true
        onlineStatusView.topAnchor.constraint(equalTo: userImageView.topAnchor, constant: 52).isActive = true
        onlineStatusView.widthAnchor.constraint(equalToConstant: 18).isActive = true
        onlineStatusView.heightAnchor.constraint(equalToConstant: 18).isActive = true
    }
    
    public func configure(with model: Conversation) {
        userNameLabel.text = model.name
        userMessageLabel.text = model.latestMessage.message
        if !model.latestMessage.isRead {
            DispatchQueue.main.async {
                self.userMessageLabel.font = .systemFont(ofSize: 16, weight: .semibold)
                self.sendDateLabel.font = .systemFont(ofSize: 16, weight: .semibold)
            }
        }
        let dateString = model.latestMessage.date
        guard let date = ChatViewController.dateFormatter.date(from: dateString) else {
            return
        }

        sendDateLabel.text = "\u{00B7} \(TimeFormatHelper.chatString(for: date))"
        
        DatabaseManager.shared.getUserOnlineStatus(with: model.otherUserEmail) { [weak self] result in
            switch result {
            case .success(let status):
                guard let userOnlineStatus = status as? Bool else {
                    return
                }
                self?.onlineStatusView.isHidden = !userOnlineStatus
            case .failure(let error):
                print("Failed to read data with error: \(error)")
            }
        }
        
        let path = "images/\(model.otherUserEmail)_profile_picture.png"
        StorageManager.shared.downloadURL(for: path) { [weak self] result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url)
                }
            case .failure(let error):
                print("Failed to get image url: \(error)")
            }
        }
    }

}
