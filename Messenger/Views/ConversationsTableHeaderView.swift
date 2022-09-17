//
//  ConversationsTableHeaderView.swift
//  Messenger
//
//  Created by Ngô Hải Đăng on 10/09/2022.
//

import UIKit

protocol CollectionTableViewHeaderDelegate: AnyObject {
    func collectionTableViewHeaderDidTapItem(with userData: SearchResultUser)
}

class ConversationsTableHeaderView: UITableViewHeaderFooterView {
    
    weak var delegate: CollectionTableViewHeaderDelegate?
    
    private var users = [SearchResultUser]()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: -35, left: 15, bottom: 5, right: 15)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.showsHorizontalScrollIndicator = false
//        collection.isHidden = true
        collection.backgroundColor = .systemBackground
        collection.register(CarouselViewCell.self, forCellWithReuseIdentifier: CarouselViewCell.identifier)
        return collection
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = contentView.bounds
    }
    
    public func configure(with models: [SearchResultUser]) {
        users = models
        collectionView.reloadData()
    }
}

extension ConversationsTableHeaderView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = users[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarouselViewCell.identifier, for: indexPath) as! CarouselViewCell
        cell.configure(with: model)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = contentView.frame.size.width/7
        return CGSize(width: width, height: width*1.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        50
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        // start conversation
        let targetUserData = users[indexPath.row]
        delegate?.collectionTableViewHeaderDidTapItem(with: targetUserData)
    }
}
