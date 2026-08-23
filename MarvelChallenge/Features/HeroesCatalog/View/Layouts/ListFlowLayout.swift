//
//  ListFlowLayout.swift
//  MarvelChallenge
//
//  Created by Henrique Silva on 07/01/21.
//  Copyright © 2021 Henrique Silva. All rights reserved.
//

import UIKit

class ListFlowLayout: UICollectionViewFlowLayout {

    let itemHeight: CGFloat = 95

    override init() {
        super.init()
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }

    func setupLayout() {
        minimumInteritemSpacing = 0
        minimumLineSpacing = 1
        scrollDirection = .vertical

    }

    var itemWidth: CGFloat {
        return collectionView!.frame.width
    }

    override var itemSize: CGSize {
        set {
            self.itemSize = CGSize(width: itemWidth, height: itemHeight)
        }
        get {
            return CGSize(width: itemWidth, height: itemHeight)
        }
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        return collectionView!.contentOffset
    }
}
