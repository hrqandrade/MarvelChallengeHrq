//
//  HeroesCatalogRealmDelegate.swift
//  MarvelChallenge
//
//  Created by Henrique Silva on 11/01/21.
//  Copyright © 2021 Henrique Silva. All rights reserved.
//

import UIKit

extension HeroesCatalogViewController: RealmManagerDelegate {
    func handleSuccess(type: RealmSuccess) {
        switch type {
        case .success(characters: let characters):
            self.stateHeroes = .realm
            self.charactersRealm = characters
            self.reloadDataFromCollection()
            self.setState(emptyList: false, needRemoveBg: true)
        case .successDelete:
            self.managerRealm.getHeroes()
            self.setState(emptyList: false, needRemoveBg: true)
        }
    }
    
    func handleError(type: RealmError) {
        switch type {
        case .emptyList:
            self.charactersRealm = []
            self.stateHeroes = .realm
            self.reloadDataFromCollection()
            self.setState(emptyList: false, needRemoveBg: false)
        default:
            break
        }
    }
}
