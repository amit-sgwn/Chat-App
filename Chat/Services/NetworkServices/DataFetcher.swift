//
//  DataFetcher.swift
//  Chat
//
//  Created by Amit Kumar on 09/04/21.
//

import Foundation
import MessageKit

//fetcher class
class ChatMessageFetcher {
    
    private let _apikey = "6nt5d1nJHkqbkphe"
    private let _httpUtility: HttpUtility
    
    init(httpUtility: HttpUtility) {
        self._httpUtility = httpUtility
    }
    
    func getChats(message: String, chatBotId: Int,userId: String, completionHandler: @escaping(_ chat: Message) -> Void) {
        var components = URLComponents(string: "https://www.personalityforge.com/api/chat/")!

        components.queryItems = [
            URLQueryItem(name: "apiKey", value: _apikey),
            URLQueryItem(name: "chatBotID", value: "\(chatBotId)"),
            URLQueryItem(name: "externalID", value: userId),
            URLQueryItem(name: "message", value: message)
        ]
        
        _httpUtility.getApiData(requestURL: components.url!, resultType: Message.self) { (chats) in
            completionHandler(chats)
        }
        
    }
}
