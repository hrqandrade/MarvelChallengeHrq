//
//  HeroesDetailsDataSourceDelegate.swift
//  MarvelChallenge
//
//  Created by c80256a on 11/01/21.
//  Copyright © 2021 Henrique Silva. All rights reserved.
//

import UIKit

extension HeroesDetailsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == comicCollectionView {
            return characterObject?.comics?.items?.count ?? 0
        } else {
            return characterObject?.series?.items?.count ?? 0
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == comicCollectionView {
            let cell = comicCollectionView.dequeueReusableCell(withReuseIdentifier: cellComics, for: indexPath) as! DetailsCollectionViewCell
            
            cell.setupCell(description: characterObject?.comics?.items?[indexPath.row].name ?? "")
            return cell
        } else {
            let cell = seriesCollectionView.dequeueReusableCell(withReuseIdentifier: cellSeries, for: indexPath) as! DetailsCollectionViewCell
            
            cell.setupCell(description: characterObject?.comics?.items?[indexPath.row].name ?? "")
            return cell
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 120)
    }
}

