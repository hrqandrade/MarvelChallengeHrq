//
//  RequestManager.swift
//  MarvelChallenge
//
//  Created by Henrique Silva on 07/01/21.
//  Copyright © 2021 Henrique Silva. All rights reserved.
//

import Foundation
import Reachability

public enum RequestSuccess {
    case success(results: [Character])
}

public enum RequestError {
    case noConnection
    case errorGetHeroes
    case emptyList
}

public protocol RequestManagerDelegate: class {
    func handleSuccess(type: RequestSuccess)
    func handleError(type: RequestError)
}

public class RequestManager: NSObject {
    private weak var delegate: RequestManagerDelegate?
    private let  baseURL = URL(string: "https://gateway.marvel.com:443")!
    private let privateKey = "6ce74b1efa48747aabeef1cebb23f832b78c7c0e"
    private let apiKey = "c58f8821ff7ae5937dd9a95bd15d9ff2"
    public var fileName = "character"
    
    public init(delegate: RequestManagerDelegate) {
        self.delegate = delegate
    }
    
    func getHeroes(page: Int) {
        if Thread.current.isRunningXCTest {
            let filePath = fileName
            UnitTestFilesManager.getDataForFile(name: filePath) { resp in
                guard let jsonData = resp.data else {
                    self.delegate?.handleError(type: .errorGetHeroes)
                    return
                }
                
                guard let charactersModel = try? JSONDecoder().decode(CharacterData.self, from: jsonData), let results = charactersModel.data?.results else {
                    self.delegate?.handleError(type: .errorGetHeroes)
                    return
                }
                
                self.delegate?.handleSuccess(type: .success(results: results))
                return
            }
        }
        
        if let reachability = try? Reachability(), reachability.connection == .unavailable {
            delegate?.handleError(type: .noConnection)
            return
        }
        
        let limit = 20
        let timestamp = "\(Date().timeIntervalSince1970)"
        let dataHash = MD5(string: "\(timestamp)\(privateKey)\(apiKey)")
        let hash = dataHash.map { String(format: "%02hhx", $0) }.joined()
        
        var components = URLComponents(url: baseURL.appendingPathComponent("v1/public/characters"), resolvingAgainstBaseURL: true)
        var customQueryItems = [URLQueryItem]()
        
        customQueryItems.append(URLQueryItem(name: "offset", value: "\(page * limit)"))
        customQueryItems.append(URLQueryItem(name: "limit", value: "\(limit)"))
        customQueryItems.append(URLQueryItem(name: "orderBy", value: "name"))
        
        let commonQueryItems = [
            URLQueryItem(name: "ts", value: timestamp),
            URLQueryItem(name: "hash", value: hash),
            URLQueryItem(name: "apikey", value: apiKey)
        ]
        
        components?.queryItems = commonQueryItems + customQueryItems
        
        guard let url = components?.url else {
            return
        }
        
        var request  = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request as URLRequest) {
            data, _, error in
            
            if error != nil {
                self.delegate?.handleError(type: .errorGetHeroes)
                return
            }
            
            guard let jsonData = data else {
                self.delegate?.handleError(type: .errorGetHeroes)
                return
            }
            
            guard let charactersModel = try? JSONDecoder().decode(CharacterData.self, from: jsonData), let results = charactersModel.data?.results else {
                self.delegate?.handleError(type: .emptyList)
                return
            }
            
            self.delegate?.handleSuccess(type: .success(results: results))
            return
        }.resume()
        
    }
    
}
