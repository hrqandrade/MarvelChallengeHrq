//
//  MarvelReponseModel.swift
//  MarvelChallenge
//
//  Created by c80256a on 11/01/21.
//  Copyright © 2021 Henrique Silva. All rights reserved.
//

import Foundation

public struct MarvelReponse {
    public let data: Data?
    public let error: Error?
    public let statusCode: Int?

    public init(data: Data?, error: Error?, statusCode: Int) {
        self.data = data
        self.error = error
        self.statusCode = statusCode
    }
}
