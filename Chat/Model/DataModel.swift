//
//  DataModel.swift
//  Chat
//
//  Created by Amit Kumar on 09/04/21.
//

import Foundation
import MessageKit

struct Sender: Codable, SenderType {
    var senderId: String
    
    var displayName: String
    
}


struct FormattedMessage: MessageType {
    var sender: SenderType

    var messageId: String

    var sentDate: Date

    var kind: MessageKind

}

// MARK: - Message
struct Message: Codable {
  
    let success: Int
    let errorMessage: String
    let message: MessageClass
    
    func getFormattedMessage() -> FormattedMessage {
        let sender = Sender(senderId: "\(message.chatBotID)", displayName: message.chatBotName)
        
    }
}

// MARK: - MessageClass
struct MessageClass: Codable {
    let chatBotName: String
    let chatBotID: Int
    let message, emotion: String
}
