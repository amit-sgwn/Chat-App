//
//  CDFormattedMessage+CoreDataProperties.swift
//  Chat
//
//  Created by Amit Kumar on 11/04/21.
//
//

import Foundation
import CoreData
import MessageKit

//CorreData classes
extension CDFormattedMessage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDFormattedMessage> {
        return NSFetchRequest<CDFormattedMessage>(entityName: "CDFormattedMessage")
    }

    @NSManaged public var messageId: String?
    @NSManaged public var sentDate: Date?
    @NSManaged public var senderId: String?
    @NSManaged public var message: String?
    @NSManaged public var senderName: String?
    @NSManaged public var isSent: Bool

}

extension CDFormattedMessage : Identifiable {

    func getFormattedMessage() -> FormattedMessage? {
        guard let senderid = self.senderId, let senderName = self.senderName, let sentDate = self.sentDate, let message = self.message, let messageId = self.messageId  else {
            return nil
        }
        let sender = Sender(senderId: senderid, displayName: senderName)
        let messageKind : MessageKind = .text(message)
        let formattedMessage = FormattedMessage(sender: sender, messageId: messageId, sentDate: sentDate, kind: messageKind)
        return formattedMessage
    }
}


