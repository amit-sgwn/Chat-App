//
//  MessageRepository.swift
//  Chat
//
//  Created by Amit Kumar on 11/04/21.
//

import Foundation
import CoreData

protocol MessageRepository {
    
    func createMessag(isSent: Bool , msg: FormattedMessage)
    func getAll(isSent: Bool) -> [FormattedMessage]?
    func getAll() -> [FormattedMessage]?
    func get(byIdentifier id: String) -> FormattedMessage?
    func update(isSent: Bool, msg: FormattedMessage) -> Bool
    func delete(msg: FormattedMessage) -> Bool
    
}


struct MessageDataRepository: MessageRepository {
    func getAll(isSent: Bool) -> [FormattedMessage]? {
        let result = PersistentStorage.shared.fetchManagedObject(managedObject: CDFormattedMessage.self)?.filter{ $0.isSent == isSent }
        var message: [FormattedMessage] = []
        debugPrint(result)
        result?.forEach({ (cdMsg) in
            if let msg = cdMsg.getFormattedMessage() {
                message.append(msg)
            }
        })
        debugPrint(message)
        return message
    }
    
    
    func createMessag(isSent: Bool = true, msg: FormattedMessage) {
        let message = CDFormattedMessage(context: PersistentStorage.shared.context)// msg.getCoreDataObject()
        message.isSent = isSent
        message.messageId = msg.messageId
        message.sentDate = msg.sentDate
        message.senderName = msg.sender.displayName
        message.senderId = msg.sender.senderId
        
        switch msg.kind {
        case .text(let text):
            message.message = text
        default:
            break
        }
        PersistentStorage.shared.saveContext()
    }
    
    func getAll() -> [FormattedMessage]? {
        let result = PersistentStorage.shared.fetchManagedObject(managedObject: CDFormattedMessage.self)
        var message: [FormattedMessage] = []
        result?.forEach({ (cdMsg) in
            if let msg = cdMsg.getFormattedMessage() {
                message.append(msg)
            }
        })
        return message
    }
    
    
    func get(byIdentifier id: String) -> FormattedMessage? {
      
        guard let result = getCDMessage(byIdentifier: id)?.getFormattedMessage() else {
            return nil
        }
        
        return result
        
       
    }
    
    func update(isSent: Bool = true, msg: FormattedMessage) -> Bool {
        
        guard let result = getCDMessage(byIdentifier: msg.messageId) else {
            return false
        }
        
        result.isSent = isSent
        result.messageId = msg.messageId
        result.sentDate = msg.sentDate
        result.senderName = msg.sender.displayName
        result.senderId = msg.sender.senderId
        
        switch msg.kind {
        case .text(let text):
            result.message = text
        default:
            break
        }
        
        PersistentStorage.shared.saveContext()
        return true
        
    }
    
    func delete(msg: FormattedMessage) -> Bool {
        guard let result = getCDMessage(byIdentifier: msg.messageId) else {
            return false
        }
        
        PersistentStorage.shared.context.delete(result)
        return true
    }
    
    private func getCDMessage(byIdentifier id: String) -> CDFormattedMessage? {
        let fetchRequest = NSFetchRequest<CDFormattedMessage>(entityName: "CDFormattedMessage")
        let perdicate = NSPredicate(format: "messageId==%@", id as CVarArg )
        fetchRequest.predicate = perdicate
        
        do {
            let result = try PersistentStorage.shared.context.fetch(fetchRequest).first
            return result
        } catch let error {
            debugPrint(error)
        }
        return nil
    }
    
    private func getMessageWithStatus(withStatus status: Bool) -> [CDFormattedMessage]? {
        let fetchRequest = NSFetchRequest<CDFormattedMessage>(entityName: "CDFormattedMessage")
        let perdicate = NSPredicate(format: "isSent==%@", status as CVarArg )
        fetchRequest.predicate = perdicate
        
        do {
            let result = try PersistentStorage.shared.context.fetch(fetchRequest)
            return result
        } catch let error {
            debugPrint(error)
        }
        return nil
    }
    
    
}
