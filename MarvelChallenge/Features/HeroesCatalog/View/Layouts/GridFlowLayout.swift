//
//  GridFlowLayout.swift
//  MarvelChallenge
//
//  Created by Henrique Silva on 07/01/21.
//  Copyright © 2021 Henrique Silva. All rights reserved.
//

import UIKit

final class GridFlowLayout: UICollectionViewFlowLayout {
    private enum Metrics {
        static let itemHeight: CGFloat = 190
        static let spacing: CGFloat = 1
        static let columns: CGFloat = 2
    }

    override init() {
        super.init()
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }

    override func prepare() {
        super.prepare()
        guard let collectionView else { return }
        let availableWidth = collectionView.bounds.width - sectionInset.left - sectionInset.right
        let totalSpacing = Metrics.spacing * (Metrics.columns - 1)
        let itemWidth = (availableWidth - totalSpacing) / Metrics.columns
        itemSize = CGSize(width: itemWidth, height: Metrics.itemHeight)
    }

    private func setupLayout() {
        minimumInteritemSpacing = Metrics.spacing
        minimumLineSpacing = Metrics.spacing
        scrollDirection = .vertical
    }
}
