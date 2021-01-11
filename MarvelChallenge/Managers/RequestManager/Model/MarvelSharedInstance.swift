//
//  MarvelSharedInstance.swift
//  MarvelChallenge
//
//  Created by c80256a on 11/01/21.
//  Copyright © 2021 Henrique Silva. All rights reserved.
//

import UIKit

public class MarvelSharedInstance {
    public var characterSelect: Character?
    public var needsReload = false
    private static var _sharedInstance: MarvelSharedInstance?
    
    public static var sharedInstance: MarvelSharedInstance {
        guard let instance = _sharedInstance else {
            let newInstance = MarvelSharedInstance()
            _sharedInstance = newInstance
            return newInstance
        }
        return instance
    }
    
    init() {}
    
}
