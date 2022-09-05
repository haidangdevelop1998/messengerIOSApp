//
//  ConversationsModels.swift
//  Messenger
//
//  Created by Ngô Hải Đăng on 03/09/2022.
//

import Foundation

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let message: String
    let isRead: Bool
}
