//
//  ListFlowLayout.swift
//  MarvelChallenge
//
//  Created by Henrique Silva on 07/01/21.
//  Copyright © 2021 Henrique Silva. All rights reserved.
//

import UIKit

final class ListFlowLayout: UICollectionViewFlowLayout {
    private enum Metrics {
        static let itemHeight: CGFloat = 95
        static let lineSpacing: CGFloat = 1
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
        let itemWidth = collectionView.bounds.width - sectionInset.left - sectionInset.right
        itemSize = CGSize(width: itemWidth, height: Metrics.itemHeight)
    }

    private func setupLayout() {
        minimumInteritemSpacing = 0
        minimumLineSpacing = Metrics.lineSpacing
        scrollDirection = .vertical
    }
}
