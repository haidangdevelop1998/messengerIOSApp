//
//  CarouselViewCell.swift
//  Messenger
//
//  Created by Ngô Hải Đăng on 10/09/2022.
//

import UIKit

class CarouselViewCell: UICollectionViewCell {
    
    static let identifier = "CarouselViewCell"
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLayout()
        userImageView.layer.cornerRadius = contentView.width * 0.5
    }
    
    public func configure(with model: SearchResultUser) {
        userNameLabel.text = model.name
        
        let path = "images/\(model.email)_profile_picture.png"
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
    
    private func setupLayout() {
//        userImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        userImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        userImageView.widthAnchor.constraint(equalToConstant: contentView.width).isActive = true
        userImageView.heightAnchor.constraint(equalTo: userImageView.widthAnchor).isActive = true
        
        userNameLabel.topAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: 10).isActive = true
        userNameLabel.widthAnchor.constraint(equalTo: userImageView.widthAnchor).isActive = true
    }
}
