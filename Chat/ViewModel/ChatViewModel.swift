//
//  ChatViewModel.swift
//  Chat
//
//  Created by Amit Kumar on 09/04/21.
//

import Foundation
import MessageKit

class ChatViewModel {
    
    weak var delegate: ChatableProtocol?
    var messageRepository: MessageDataRepository
    
    private let _chatMessageFetcher: ChatMessageFetcher!
    private var _messageList: [FormattedMessage] = [] {
        didSet {
            delegate?.reloadData()
        }
    }
    
    //MARK: Computed Property to set sender and reciever
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
    
    
    init(currentUser: Sender, delegate: ChatableProtocol) {
        
        self.delegate = delegate
        self._currentUser = currentUser//
        self._otherUser = Sender(senderId: "63906", displayName: "ChatBot")
        self._chatMessageFetcher = ChatMessageFetcher(httpUtility: HttpUtility())
        self.messageRepository = MessageDataRepository()
        
        //If there are messages to send
        if Reachability.isConnectedToNetwork() {
            pushAllMessage()
        }
        getObjects()
    }
    
    //Push to api when network is back
    func pushAllMessage() {
        guard let messages = self.messageRepository.getAll(isSent: false) else {
            return
        }
        if messages.count == 0 {
            return
        }
        //Dispatch group for all api
        let dispatchGroup = DispatchGroup()
        let queue = DispatchQueue(label: "push.all.data")
        
        //Queue fro core data operations
        let coreDataQueue = DispatchQueue(label: "coreData.store")
        
        queue.async {
            for mssg in messages {
                var messageStr = ""
                switch mssg.kind {
                case .text(let text):
                    messageStr = text
                default:
                    break;
                }
                dispatchGroup.enter()
                debugPrint("dispatch enter ")

                self._chatMessageFetcher.getChats(message: messageStr, chatBotId: 63906, userId: mssg.sender.senderId) { [weak self] (msg) in
                    
                    guard let weakself = self else {
                        return
                    }
                    let recievedMessage = FormattedMessage(sender: weakself.otherUser, messageId: UUID().uuidString, sentDate: Date(), kind: .text(msg.message.message))
                    //Dumping to coredata when api success
                    coreDataQueue.async {
                        weakself.messageRepository.createMessag(msg: recievedMessage)
                        weakself.messageRepository.update(isSent: true, msg: mssg)
                    }
                    debugPrint("dispatch leave ")
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            debugPrint("notifiy ")
            self.getObjects()
        }
    }
    
    //Push data to api if there is network other dump in DB
    func sendMessage(msg: String){
        
        if !Reachability.isConnectedToNetwork() {
            pushForOffline(msg: msg)
            self.delegate?.noInternetView()
            return
        } else {
            pushAllMessage()
        }
        
        let currentMessage = FormattedMessage(sender: _currentUser, messageId: UUID().uuidString, sentDate: Date(), kind: .text(msg))
        self._chatMessageFetcher.getChats(message: msg, chatBotId: 63906, userId: currentUser.senderId) { [weak self] (msg) in
            
            guard let weakself = self else {
                return
            }
            weakself._messageList.append(currentMessage)
            let recievedMessage = FormattedMessage(sender: weakself.otherUser, messageId: UUID().uuidString, sentDate: Date(), kind: .text(msg.message.message))
          //  weakself._messageList.append(recievedMessage)
            weakself.messageRepository.createMessag(msg: currentMessage)
            weakself.messageRepository.createMessag(msg: recievedMessage)
            weakself.getObjects()
        }
    }
    
    //Demp data to DB  when offline
    func pushForOffline(msg: String) {
        let currentMessage = FormattedMessage(sender: _currentUser, messageId: UUID().uuidString, sentDate: Date(), kind: .text(msg))
        messageRepository.createMessag(isSent: false,msg: currentMessage)
        getObjects()
    }
    
    //Fetch all data from DB
    func getObjects() {
        guard var messages = messageRepository.getAll() else {
            return
        }
        messages = messages.sorted { $0.sentDate < $1.sentDate
        }
        _messageList = messages
    }
    
    //Return object with index
    subscript(index: Int) -> FormattedMessage {
        get {
            return _messageList[index]
        }
    }
    
    var messageCount: Int {
        return _messageList.count
    }

}


protocol ChatableProtocol: class {
    func reloadData()
    func noInternetView()
}
