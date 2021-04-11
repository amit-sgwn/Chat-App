//
//  NetworkServices.swift
//  Chat
//
//  Created by Amit Kumar on 09/04/21.
//

import Foundation

//Utility for api call 
struct HttpUtility {
    
    func getApiData<T: Decodable>(requestURL: URL, resultType: T.Type,completionHandler: @escaping(_ result: T) -> Void) {
        debugPrint(requestURL)
        URLSession.shared.dataTask(with: requestURL){ (responseData, httpUrlResponse, error) in
            if error == nil && responseData != nil && responseData?.count != 0 {
                //Parsing data from response
                let decoder = JSONDecoder()
                do {
                    let result = try decoder.decode(T.self, from: responseData!)
                    completionHandler(result)
                } catch let error {
                    debugPrint(error.localizedDescription)
                }
            }
            
        }.resume()
    }
    
    func getApiData<T: Decodable>(requestURL: URLRequest, resultType: T.Type  ,completionHandler: @escaping(_ result: T) -> Void) {
        
        URLSession.shared.dataTask(with: requestURL){ (responseData, httpUrlResponse, error) in
            if error == nil && responseData != nil && responseData?.count != 0 {
                //Parsing data from response
                let decoder = JSONDecoder()
                do {
                    let result = try decoder.decode(T.self, from: responseData!)
                    completionHandler(result)
                } catch let error {
                    debugPrint(error.localizedDescription)
                }
            }
            
        }.resume()
    }
}




