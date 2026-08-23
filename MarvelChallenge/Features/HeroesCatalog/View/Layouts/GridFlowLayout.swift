//
//  GridFlowLayout.swift
//  MarvelChallenge
//
//  Created by Henrique Silva on 07/01/21.
//  Copyright © 2021 Henrique Silva. All rights reserved.
//

import UIKit

class GridFlowLayout: UICollectionViewFlowLayout {

    let itemHeight: CGFloat = 190

    override init() {
        super.init()
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }

    func setupLayout() {
        minimumInteritemSpacing = 1
        minimumLineSpacing = 1
        scrollDirection = .vertical
    }

    var itemWidth: CGFloat {
        return collectionView!.frame.width / 2 - 1
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
