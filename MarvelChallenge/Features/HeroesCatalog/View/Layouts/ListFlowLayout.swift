import MarvelDesignSystem
import UIKit

final class ListFlowLayout: UICollectionViewFlowLayout {
    private enum Metrics {
        static let minimumItemHeight: CGFloat = 104
        static let imageHeight: CGFloat = 63
        static let minimumTouchTarget: CGFloat = 44
        static let verticalContentInset: CGFloat = 40
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
        let textHeight = ceil(DesignSystem.Typography.headline.lineHeight * 2)
        let contentHeight = max(Metrics.imageHeight, Metrics.minimumTouchTarget, textHeight)
        itemSize = CGSize(
            width: itemWidth,
            height: max(Metrics.minimumItemHeight, contentHeight + Metrics.verticalContentInset)
        )
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
