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
    
    func getCoreDataObject(isSent: Bool = false)  -> CDFormattedMessage {
        let msg = CDFormattedMessage()
        msg.isSent = isSent
        msg.messageId = messageId
        msg.sentDate = self.sentDate
        msg.senderName = self.sender.displayName
        msg.senderId = self.sender.senderId
        
        switch kind {
        case .text(let text):
            msg.message = text
        default:
            break
        }
        return msg
    }

}

// MARK: - Message
struct Message: Codable {
  
    let success: Int
    let errorMessage: String
    let message: MessageClass

}

// MARK: - MessageClass
struct MessageClass: Codable {
    let chatBotName: String
    let chatBotID: Int
    let message, emotion: String
}
