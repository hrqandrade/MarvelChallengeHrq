//
//  RealmManager.swift
//  MarvelChallenge
//
//  Created by Henrique Silva on 07/01/21.
//  Copyright © 2021 Henrique Silva. All rights reserved.
//

import Foundation
import RealmSwift

public enum RealmSuccess {
    case success(characters: [CharacterRealm])
    case successDelete
}

public enum RealmError {
    case errorGetHeroes
    case emptyList
    case errorToDelete
}

public protocol RealmManagerDelegate: class {
    func handleSuccess(type: RealmSuccess)
    func handleError(type: RealmError)
}

public class RealmManager: NSObject {
    private weak var delegate: RealmManagerDelegate?
    
    public init(delegate: RealmManagerDelegate?) {
        self.delegate = delegate
    }
    
    public func getHeroes(){
        var array: [CharacterRealm] = []
        do {
            let realm = try Realm()
            let heroes = realm.objects(CharacterRealm.self).sorted(byKeyPath: "name", ascending: true)
            for hero in heroes {
                array.append(hero)
            }
            if array.count > 0 {
                self.delegate?.handleSuccess(type: .success(characters: array))
            } else {
                self.delegate?.handleError(type: .emptyList)
            }
        } catch {
            self.delegate?.handleError(type: .errorGetHeroes)
        }
        
    }
    
    public func validateHero(object: Character) -> Bool {
        var validateHero = false
        do {
            let realm = try Realm()
            let heroes = realm.objects(CharacterRealm.self)
            for hero in heroes {
                if hero.id == object.id {
                    validateHero = true
                }
            }
        } catch {
            print("error")
        }
        return validateHero
    }
    
    public func save(object: CharacterRealm, image: UIImage) {
        DispatchQueue.main.async {
            autoreleasepool {
                do {
                    let realm = try Realm()
                    let characterRealm = CharacterRealm()
                    characterRealm.id = object.id
                    characterRealm.name = object.name
                    characterRealm.urlImage = image.toBase64() ?? ""
                    
                    realm.beginWrite()
                    realm.add(characterRealm)
                    try realm.commitWrite()
                } catch {
                    print("Não foi possível salvar no momento")
                }
            }
        }
    }
    
    func delete(id: Int) {
        DispatchQueue.main.async {
            autoreleasepool {
                do {
                    let realm = try Realm()
                    realm.beginWrite()
                    let object = realm.objects(CharacterRealm.self).filter("id = %@", id)
                    realm.delete(object)
                    try realm.commitWrite()
                    self.delegate?.handleSuccess(type: .successDelete)
                } catch {
                    print("Não foi possível apagar no momento")
                }
            }
        }
    }
}

extension UIImage {
    func toBase64() -> String? {
        guard let imageData = self.pngData() else { return nil }
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
}
