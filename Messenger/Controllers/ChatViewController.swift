//
//  ChatViewController.swift
//  Messenger
//
//  Created by Ngô Hải Đăng on 20/08/2022.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage
import AVKit
import CoreLocation

/// Controller that shows chat view of two user
final class ChatViewController: MessagesViewController {
    
    private var senderPhotoURL: URL?
    
    private var otherUserPhotoURL: URL?
    
    public static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .long
        dateFormatter.timeZone = .current
        return dateFormatter
    }()
    
    public let otherUserEmail: String
    
    private var conversationID: String?
    
    public var isNewConversation: Bool = false
    
    private var messages = [Message]()
    
    private var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        return Sender(photoURL: "", senderId: safeEmail, displayName: "")
    }
    
    init(with email: String, id: String?) {
        self.otherUserEmail = email
        self.conversationID = id
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.sendButton.setTitle("", for: .normal)
        messageInputBar.sendButton.setTitleColor(UIColor.chatAppColor, for: .normal)
        messageInputBar.sendButton.setImage(UIImage.localImage("send-icon", template: true), for: .normal)
        messageInputBar.inputTextView.backgroundColor = .systemGray6
        messageInputBar.inputTextView.layer.cornerRadius = 20
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.textContainerInset.left = 12
        messageInputBar.inputTextView.placeholderLabelInsets.left = 16
        messageInputBar.inputTextView.becomeFirstResponder()
        
        if let conversationID = conversationID {
            listenForMessages(id: conversationID, shouldScrollToBottom: true)
            // mark read latest message
            guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
                return
            }
            
            print("check message from: \(email)")
            
            let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
            DatabaseManager.shared.markLatestMessagesAsRead(currentEmail: safeEmail, conservationID: conversationID) { success in
                if success {
                    print("Mark read successfully!")
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        
        setupInputButton()
    }
    
    private func setupInputButton() {
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.onTouchUpInside { [weak self]  _ in
            self?.presentInputActionSheet()
        }
        
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    private func presentInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Media", message: "What would you like to attach?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoInputActionSheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self] _ in
            self?.presentVideoInputActionSheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Audio", style: .default, handler: { _ in
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Location", style: .default, handler: { [weak self] _ in
            self?.presentLocationPicker()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    // Send location message
    private func presentLocationPicker() {
        let vc = LocationPickerViewController(coordinates: nil)
        vc.title = "Pick Location"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completion = { [weak self] selectedCoordinates in
            
            guard let strongSelf = self else {
                return
            }
            
            guard let messageId = strongSelf.createMessageId(),
                  let conversationID = strongSelf.conversationID,
                  let name = strongSelf.title,
                  let selfSender = strongSelf.selfSender else {
                return
            }
                
            let longitude: Double = selectedCoordinates.longitude
            let latitude: Double = selectedCoordinates.latitude
            
            let location = Location(location: CLLocation(latitude: latitude, longitude: longitude), size: .zero)
            
            let message = Message(sender: selfSender,
                                  messageId: messageId,
                                  sentDate: Date(),
                                  kind: .location(location))
            
            DatabaseManager.shared.sendMessage(to: conversationID, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message) { success in
                if success {
                    print("Send success")
                } else {
                    print("Failed to send message")
                }
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // Send photo message
    private func presentPhotoInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Photo", message: "Where would you like to attach a photo from?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] _ in
            
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    // Send video message
    private func presentVideoInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Video", message: "Where would you like to attach a video from?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Library", style: .default, handler: { [weak self] _ in
            
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    private func listenForMessages(id: String, shouldScrollToBottom: Bool) {
        DatabaseManager.shared.getAllMessagesForConversation(with: id) { [weak self] result in
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else {
                    return
                }
                self?.messages = messages
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    
                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToLastItem()
                    }
                }
            case .failure(let error):
                print("Failed to get message: \(error)")
            }
        }
    }
    
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let messageId = createMessageId(),
              let name = self.title,
              let selfSender = selfSender else {
            return
        }
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage,
           let imageData = image.pngData() {
            
            // Upload image
            let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".png"
            
            StorageManager.shared.uploadMessagePhoto(with: imageData, fileName: fileName) { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                switch result {
                case .success(let urlString):
                    // Ready to send message
                    guard let url = URL(string: urlString),
                          let placeholder = UIImage(systemName: "plus") else {
                        return
                    }
                    
                    let media = Media(url: url, image: nil, placeholderImage: placeholder, size: .zero)
                    
                    let message = Message(sender: selfSender,
                                          messageId: messageId,
                                          sentDate: Date(),
                                          kind: .photo(media))
                    
                    // Send Message
                    if strongSelf.isNewConversation {
                        // create new conversation in database
                        DatabaseManager.shared.createNewConversation(with: strongSelf.otherUserEmail, name: name, firstMessage: message) { [weak self] success in
                            if success {
                                print("Send success")
                                self?.isNewConversation = false
                                let newConversationID = "conversation_\(messageId)"
                                self?.conversationID = newConversationID
                                self?.listenForMessages(id: newConversationID, shouldScrollToBottom: true)
                                self?.messageInputBar.inputTextView.text = nil
                            } else {
                                print("Failed to send")
                            }
                        }
                    } else {
                        
                        guard let conversationID = strongSelf.conversationID else {
                            return
                        }
                        
                        DatabaseManager.shared.sendMessage(to: conversationID, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message) { success in
                            if success {
                                print("Send success")
                            } else {
                                print("Failed to send message")
                            }
                        }
                    }
                case .failure(let error):
                    print("Message photo upload failed with error: \(error)")
                }
            }
        } else if let videoUrl = info[.mediaURL] as? URL {
            
            // Upload video
            let fileName = "video_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".mov"
            
            StorageManager.shared.uploadMessageVideo(with: videoUrl, fileName: fileName) { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                switch result {
                case .success(let urlString):
                    // Ready to send message
                    guard let url = URL(string: urlString),
                          let placeholder = UIImage(systemName: "plus") else {
                        return
                    }
                    
                    let media = Media(url: url, image: nil, placeholderImage: placeholder, size: .zero)
                    
                    let message = Message(sender: selfSender,
                                          messageId: messageId,
                                          sentDate: Date(),
                                          kind: .video(media))
                    
                    // Send Message
                    if strongSelf.isNewConversation {
                        // create new conversation in database
                        
                        DatabaseManager.shared.createNewConversation(with: strongSelf.otherUserEmail, name: name, firstMessage: message) { [weak self] success in
                            if success {
                                print("Send success")
                                self?.isNewConversation = false
                                let newConversationID = "conversation_\(messageId)"
                                self?.conversationID = newConversationID
                                self?.listenForMessages(id: newConversationID, shouldScrollToBottom: true)
                                self?.messageInputBar.inputTextView.text = nil
                            } else {
                                print("Failed to send")
                            }
                        }
                    } else {
                        
                        guard let conversationID = strongSelf.conversationID else {
                            return
                        }
                        
                        DatabaseManager.shared.sendMessage(to: conversationID, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message) { success in
                            if success {
                                print("Send success")
                            } else {
                                print("Failed to send message")
                            }
                        }
                    }
                case .failure(let error):
                    print("Message video upload failed with error: \(error)")
                }
            }
        }
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.selfSender,
              let messageId = createMessageId()
        else {
            return
        }
        
        let message = Message(sender: selfSender,
                              messageId: messageId,
                              sentDate: Date(),
                              kind: .text(text))
        
        // Send Message
        if isNewConversation {
            // create new conversation in database
            
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "User", firstMessage: message) { [weak self] success in
                if success {
                    print("Send success")
                    self?.isNewConversation = false
                    let newConversationID = "conversation_\(messageId)"
                    self?.conversationID = newConversationID
                    self?.listenForMessages(id: newConversationID, shouldScrollToBottom: true)
                    self?.messageInputBar.inputTextView.text = nil
                } else {
                    print("Failed to send")
                }
            }
        } else {
            // append existing conversation to database
            guard let conversationID = conversationID,
                  let name = self.title else {
                return
            }
            DatabaseManager.shared.sendMessage(to: conversationID, otherUserEmail: otherUserEmail, name: name, newMessage: message) { [weak self] success in
                if success {
                    self?.messageInputBar.inputTextView.text = nil
                    print("message sent")
                } else {
                    print("failed to send message")
                }
            }
        }
    }
    
    private func createMessageId() -> String? {
        // date, otheUserEmail, senderEmail, randomInt
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        
        let dateString = Self.dateFormatter.string(from: Date())
        
        let newIndentifier = "\(otherUserEmail)_\(safeEmail)_\(dateString)"
        
        return newIndentifier
    }
    
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Self sender is nil, email should be cached")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else {
            return
        }
        
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            imageView.sd_setImage(with: imageUrl, completed: nil)
        default:
            break
        }
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let sender = message.sender
        if sender.senderId == selfSender?.senderId {
            return UIColor.chatAppColor
        }
        return .secondarySystemBackground
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let sender = message.sender
        if sender.senderId == selfSender?.senderId {
            // show avatar
            if let currentUserAvatar = self.senderPhotoURL {
                avatarView.sd_setImage(with: currentUserAvatar)
            } else {
                guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
                    return
                }
                
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                let path = "images/\(safeEmail)_profile_picture.png"
                
                // fetch url
                StorageManager.shared.downloadURL(for: path) { [weak self] result in
                    switch result {
                    case .success(let url):
                        self?.senderPhotoURL = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url)
                        }
                    case .failure(let error):
                        print("Error: \(error)")
                    }
                }
            }
        } else {
            if let otherUserAvatar = self.otherUserPhotoURL {
                avatarView.sd_setImage(with: otherUserAvatar)
            } else {
                // fetch url
                let email = self.otherUserEmail
                
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                let path = "images/\(safeEmail)_profile_picture.png"
                
                // fetch url
                StorageManager.shared.downloadURL(for: path) { [weak self] result in
                    switch result {
                    case .success(let url):
                        self?.otherUserPhotoURL = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url)
                        }
                    case .failure(let error):
                        print("Error: \(error)")
                    }
                }
            }
        }
    }
    
    
}

extension ChatViewController: MessageCellDelegate {
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        let message = messages[indexPath.section]
        
        switch message.kind {
        case .location(let locationData):
            let coordinates = locationData.location.coordinate
            let vc = LocationPickerViewController(coordinates: coordinates)
            vc.title = "Location"
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        let message = messages[indexPath.section]
        
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            let vc = PhotoViewerViewController(with: imageUrl)
            navigationController?.pushViewController(vc, animated: true)
        case .video(let media):
            guard let videoUrl = media.url else {
                return
            }
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoUrl)
            present(vc, animated: true)
        default:
            break
        }
    }
}
