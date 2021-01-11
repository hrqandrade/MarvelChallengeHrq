//
//  MarvelChallengeTests.swift
//  MarvelChallengeTests
//
//  Created by Henrique Silva on 07/01/21.
//  Copyright © 2021 Henrique Silva. All rights reserved.
//

import XCTest
@testable import MarvelChallenge

class MarvelChallengeTests: XCTestCase {
    let delegate = RequestDelegateCopy()
    var manager: RequestManager?

    override func setUp() {
    }

    override func tearDown() {
        manager = nil
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testeParseCharactersValue(){
        let expectation = self.expectation(description: "RequestCharacter")
        manager = RequestManager(delegate: delegate)
        manager?.getHeroes(page: 0)
        
        var isEqual = false
        if case .success(results: _) = delegate.handledSuccess {
            isEqual = true
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(isEqual, true)
    }
    
    func testeErrorDelegateValue() {
        let expectation = self.expectation(description: "RequestCharacter")
        let manager = RequestManager(delegate: delegate)
        manager.fileName = ""
        manager.getHeroes(page: 0)
        
        var isEqual = false
        if case .success(results: _) = delegate.handledSuccess {
            isEqual = false
            expectation.fulfill()
        }
        
        if case .errorGetHeroes = delegate.handledError {
            isEqual = true
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(isEqual, true)
    }

}
