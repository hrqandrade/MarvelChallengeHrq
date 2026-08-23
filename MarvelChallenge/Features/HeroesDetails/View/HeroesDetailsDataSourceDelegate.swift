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
            return viewModel.comics.count
        } else {
            return viewModel.series.count
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let isComicsCollection = collectionView == comicCollectionView
        let reuseIdentifier = isComicsCollection ? cellComics : cellSeries
        let item = isComicsCollection ? viewModel.comics[indexPath.row] : viewModel.series[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        (cell as? DetailsCollectionViewCell)?.setupCell(description: item.name ?? "")
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 120)
    }
}
