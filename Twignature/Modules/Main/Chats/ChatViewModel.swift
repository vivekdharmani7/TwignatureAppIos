//
//  ChatViewModel.swift
//  Twignature
//
//  Created by Anton Muratov on 9/21/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation

class ChatsViewModel {
    let chatItems: [ChatViewItem]
    
    init(_ chats: [Conversation]) {
        self.chatItems = chats.map({ ChatViewItem($0) })
    }
    
    struct ChatViewItem {
        private let conversation: Conversation
        
        let text: String
        let recipientName: String
        let recipientTweeterName: String
        let isVerified: Bool
        let recipientAvatarUrl: URL?
        var lastMessageTime: String {
			return Date().offset(from: conversation.lastActivityDate)?.stringValue ?? "now"
        }
        
        init(_ conversation: Conversation) {
            self.conversation = conversation
			self.text = conversation.messages.first?.text ?? ""
			self.recipientName = conversation.user.name
            self.isVerified = conversation.user.isVerified
            self.recipientTweeterName = conversation.user.screenName
            self.recipientAvatarUrl = conversation.user.profileImageUrl
        }
    }
}
