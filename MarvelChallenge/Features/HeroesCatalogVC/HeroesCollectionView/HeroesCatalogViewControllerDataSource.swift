//
//  HeroesCatalogViewControllerDataSource.swift
//  MarvelChallenge
//
//  Created by Henrique Silva on 09/01/21.
//  Copyright © 2021 Henrique Silva. All rights reserved.
//

import UIKit

extension HeroesCatalogViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch stateHeroes  {
        case .loading: return 0
        case .request: lastItem = charactesResult.count
            return charactesResult.count
        case .realm: return charactersRealm.count
        case .none: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch (isGridFlowLayoutUsed, stateHeroes) {
        case (true,.request):
            return setGridCell(isRealm: false, collectionView: collectionView, indexPath: indexPath)
        case (false,.request):
            return setListCell(isRealm: false, collectionView: collectionView, indexPath: indexPath)
        case (true,.realm):
            return setGridCell(isRealm: true, collectionView: collectionView, indexPath: indexPath)
        case (false,.realm):
            return setListCell(isRealm: true, collectionView: collectionView, indexPath: indexPath)
        case (_, .none):
            return UICollectionViewCell()
        case (_, .some(.loading)):
            return UICollectionViewCell()
        }
    }
    
    func setListCell(isRealm: Bool, collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell{
        let cell: HeroesCollectionListCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeroesCollectionListCell", for: indexPath as IndexPath) as! HeroesCollectionListCell
        switch isRealm {
        case true: cell.setupWithRealm(object: charactersRealm[indexPath.row]) {
            self.managerRealm.delete(id: self.charactersRealm[indexPath.row].id)
        }
        case false: cell.setupWithRequest(object: charactesResult[indexPath.row])
        }
        return cell
    }
    
    func setGridCell(isRealm: Bool, collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell{
        let cell: HeroesCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeroesCollectionViewCell", for: indexPath as IndexPath) as! HeroesCollectionViewCell
        switch isRealm {
        case true: cell.setupWithRealm(object: charactersRealm[indexPath.row]) {
            self.managerRealm.delete(id: self.charactersRealm[indexPath.row].id)
        }
        case false: cell.setupWithRequest(object: charactesResult[indexPath.row])
        }
        return cell
    }
}

extension HeroesCatalogViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch stateHeroes {
        case .request:
            MarvelSharedInstance.sharedInstance.characterSelect = charactesResult[indexPath.row]
            self.performSegue(withIdentifier: "callDetails", sender: nil)
            break
        default:
            break
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch stateHeroes {
        case .request:
            if indexPath.row == lastItem-1 {
                page += 1
                self.managerRequest.getHeroes(page: page)
                
            }
        default:
            break
        }
    }
}
