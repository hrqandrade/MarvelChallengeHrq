//
//  RequestDelegateCopy.swift
//  MarvelChallengeTests
//
//  Created by c80256a on 11/01/21.
//  Copyright © 2021 Henrique Silva. All rights reserved.
//

import UIKit
@testable import MarvelChallenge

class RequestDelegateCopy: RequestManagerDelegate {
    var handledError: RequestError?
    var handledSuccess: RequestSuccess?
    
    func handleError(type: RequestError) {
        handledError = type
    }
    
    func handleSuccess(type: RequestSuccess) {
        handledSuccess = type
    }
}
