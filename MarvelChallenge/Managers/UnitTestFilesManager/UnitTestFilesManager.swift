//
//  UnitTestFilesManager.swift
//  MarvelChallenge
//
//  Created by c80256a on 11/01/21.
//  Copyright © 2021 Henrique Silva. All rights reserved.
//

import Foundation

open class UnitTestFilesManager {
    static func getJsonDataFromFile(name: String) -> Data? {
        let bundle = Bundle(for: UnitTestFilesManager.self)
        if let path = bundle.path(forResource: name, ofType: "json") {
            return try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        }
        return nil
    }

    static func getDataForFile(name: String, response: @escaping (MarvelReponse) -> Void) {

        if let dataForResponse = getJsonDataFromFile(name: name), name != "" {
            response(MarvelReponse(data: dataForResponse,error: nil, statusCode: 200))
        } else {
            response(MarvelReponse(data: nil, error: nil, statusCode: 401))
        }
    }
}

extension Thread {
    var isRunningXCTest: Bool {
        for key in threadDictionary.allKeys {
            guard let keyAsString = key as? String else {
                continue
            }
            if keyAsString.split(separator: ".").contains("xctest") {
                return true
            }
        }
        return false
    }
}
