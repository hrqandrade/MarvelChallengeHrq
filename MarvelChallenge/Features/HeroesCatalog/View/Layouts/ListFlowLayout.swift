import UIKit

final class ListFlowLayout: UICollectionViewFlowLayout {
    private enum Metrics {
        static let itemHeight: CGFloat = 104
        static let lineSpacing: CGFloat = 8
        static let horizontalInset: CGFloat = 8
        static let verticalInset: CGFloat = 12
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
        sectionInset = UIEdgeInsets(
            top: Metrics.verticalInset,
            left: Metrics.horizontalInset,
            bottom: Metrics.verticalInset,
            right: Metrics.horizontalInset
        )
        scrollDirection = .vertical
    }
}
