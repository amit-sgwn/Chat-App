//
//  ViewController.swift
//  Chat
//
//  Created by Amit Kumar on 09/04/21.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import JGProgressHUD


class ViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    private var _chatViewModel: ChatViewModel?
    private var currentUser: Sender?
    
    private(set) lazy var refreshControl: UIRefreshControl = {
           let control = UIRefreshControl()
           control.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
           return control
       }()

    
    func currentSender() -> SenderType {
       return currentUser ?? Sender(senderId: "24234", displayName: "Amit")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return _chatViewModel![indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return _chatViewModel!.messageCount
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        currentUser = Sender(senderId: "24234", displayName: "Amit")
        _chatViewModel = ChatViewModel(currentUser: currentUser!, delegate: self)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.refreshControl = refreshControl

        configureMessageInputBar()
        // Do any additional setup after loading the view.
    }
    
    func configureMessageInputBar() {
          messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = .black
          messageInputBar.sendButton.setTitleColor(.black, for: .normal)
          messageInputBar.sendButton.setTitleColor(
              UIColor.black.withAlphaComponent(0.3),
              for: .highlighted
          )
      }
    
    @objc func loadMoreMessages() {
//          DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1) {
//              SampleData.shared.getMessages(count: 20) { messages in
//                  DispatchQueue.main.async {
//                      self.messageList.insert(contentsOf: messages, at: 0)
//                      self.messagesCollectionView.reloadDataAndKeepOffset()
//                      self.refreshControl.endRefreshing()
//                  }
//              }
//          }
      }
      
}

extension ViewController: ChatableProtocol {
    func noInternetView() {
        let hud = JGProgressHUD()
        hud.textLabel.text = "No InterNet"
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 3.0)
    }
    
    func reloadData() {
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
            self.messagesCollectionView.reloadData()
        }
    }
    
}



extension ViewController: InputBarAccessoryViewDelegate {

    @objc
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        processInputBar(messageInputBar)
    }

    func processInputBar(_ inputBar: InputBarAccessoryView) {
        // Here we can parse for which substrings were autocompleted
        let attributedText = inputBar.inputTextView.attributedText!
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { (_, range, _) in

            let substring = attributedText.attributedSubstring(from: range)
            let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
            print("Autocompleted: `", substring, "` with context: ", context ?? [])
        }

        let components = inputBar.inputTextView.components
        inputBar.inputTextView.text = String()
        inputBar.invalidatePlugins()
        // Send button activity animation
        inputBar.sendButton.startAnimating()
        inputBar.inputTextView.placeholder = "Sending..."
        // Resign first responder for iPad split view
        inputBar.inputTextView.resignFirstResponder()
        DispatchQueue.global(qos: .default).async {
            // fake send request task
            sleep(1)
            DispatchQueue.main.async { [weak self] in
                inputBar.sendButton.stopAnimating()
                inputBar.inputTextView.placeholder = "Aa"
                self?.insertMessages(components)
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
    }

    private func insertMessages(_ data: [Any]) {
        for component in data {
          //  let user = SampleData.shared.currentSender
            if let str = component as? String {
                refreshControl.beginRefreshing()
                _chatViewModel!.sendMessage(msg: str)
                
//                let message = Message(text: str, user: currentUser!, messageId: UUID().uuidString, date: Date())
//                insertMessage(message)
            }
//            else if let img = component as? UIImage {
//                let message = MockMessage(image: img, user: user, messageId: UUID().uuidString, date: Date())
//                insertMessage(message)
//            }
        }
    }
}
