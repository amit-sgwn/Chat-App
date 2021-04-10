//
//  ChatViewModel.swift
//  Chat
//
//  Created by Amit Kumar on 09/04/21.
//

import Foundation

class ChatViewModel {
    
    weak var delegate: ChatableProtocol
    
    private let _chatMessageFetcher: ChatMessageFetcher!
    private var _messageList: [FormattedMessage] = [] {
        didSet {
            delegate?.reload()
        }
    }
    
    private var currentUser: Sender {
        get {
            return self._currentUser
        }
    }
    private var otherUser: Sender {
        get {
            return self._otherUser
        }
    }
    
    private let _currentUser: Sender
    private let _otherUser: Sender
    
    
    init(currentUser: Sender, otherUser: Sender, delegate: ChatableProtocol) {
        
        self.delegate = delegate
        self._currentUser = currentUser
        self._otherUser = otherUser
        self._chatMessageFetcher = ChatMessageFetcher(httpUtility: HttpUtility())
    }
    
    func sendMessage(msg: String, completionHandler: @escaping(_ chat: Message) -> Void) {
        let currentMessage = FormattedMessage(sender: _currentUser, messageId: UUID(), sentDate: Date(), kind: .text(msg))
        self._chatMessageFetcher.getChats(message: msg, chatBotId: 63906, userId: currentUser.senderId) { (message) in
            _messageList.append(currentUser)
            let recievedMessage = FormattedMessage(sender: otherUser, messageId: UUID(), sentDate: Date(), kind: message.message)
            _messageList.append(recievedMessage)
            completionHandler(message)
        }
    }
}
