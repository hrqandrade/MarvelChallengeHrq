import MarvelDesignSystem
import UIKit

final class HeroesCatalogView: UIView {
    private enum Metrics {
        static let barHeight: CGFloat = 50
        static let controlHeight: CGFloat = 40
        static let minimumTouchTarget: CGFloat = 44
    }

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: GridFlowLayout())
    let segmentedControl = UISegmentedControl(items: [Localizable.Catalog.characters, Localizable.Catalog.favorites])
    private let headerView = UIView()
    private let footerView = UIView()
    private let layoutButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let refreshControl = UIRefreshControl()

    var onRefresh: (() -> Void)?
    var onLayoutChange: (() -> Void)?
    var onSectionChange: ((HeroesCatalogSection) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        configureHeader()
        configureCollection()
        configureFooter()
        configureHierarchy()
        configureConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { nil }

    func renderLayout(isGrid: Bool, animated: Bool) {
        layoutButton.setImage(UIImage(named: isGrid ? "list" : "grid"), for: .normal)
        let layout: UICollectionViewLayout = isGrid ? GridFlowLayout() : ListFlowLayout()
        collectionView.setCollectionViewLayout(layout, animated: animated)
    }

    func renderLoaded() {
        refreshControl.endRefreshing()
        collectionView.backgroundView = nil
        collectionView.reloadData()
    }

    func renderEmpty(section: HeroesCatalogSection) {
        refreshControl.endRefreshing()
        collectionView.reloadData()
        let imageName = section == .characters ? "emptyList" : "emptyFavorite"
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.contentMode = .scaleAspectFit
        imageView.isAccessibilityElement = true
        imageView.accessibilityLabel = section == .characters ? Localizable.Catalog.characters : Localizable.Catalog.favorites
        collectionView.backgroundView = imageView
    }

    func clearBackground() {
        collectionView.backgroundView = nil
    }

    private func configureView() {
        backgroundColor = DesignSystem.Color.accent
    }

    private func configureHeader() {
        headerView.backgroundColor = DesignSystem.Color.accent
        titleLabel.font = DesignSystem.Typography.title
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = DesignSystem.Color.onAccent
        titleLabel.text = Localizable.Catalog.characters
        titleLabel.textAlignment = .center
        layoutButton.tintColor = DesignSystem.Color.onAccent
        layoutButton.accessibilityLabel = Localizable.Catalog.changeLayout
        layoutButton.addTarget(self, action: #selector(didTapLayout), for: .touchUpInside)
    }

    private func configureCollection() {
        collectionView.backgroundColor = DesignSystem.Color.backgroundPrimary
        collectionView.register(HeroesCollectionViewCell.self, forCellWithReuseIdentifier: HeroesCollectionViewCell.reuseIdentifier)
        collectionView.register(HeroesCollectionListCell.self, forCellWithReuseIdentifier: HeroesCollectionListCell.reuseIdentifier)
        refreshControl.addTarget(self, action: #selector(didRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }

    private func configureFooter() {
        footerView.backgroundColor = DesignSystem.Color.accent
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.selectedSegmentTintColor = DesignSystem.Color.surface
        segmentedControl.addTarget(self, action: #selector(didChangeSection), for: .valueChanged)
    }

    private func configureHierarchy() {
        [headerView, collectionView, footerView, layoutButton, titleLabel, segmentedControl].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        addSubview(headerView)
        addSubview(collectionView)
        addSubview(footerView)
        headerView.addSubview(layoutButton)
        headerView.addSubview(titleLabel)
        footerView.addSubview(segmentedControl)
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: Metrics.barHeight),
            layoutButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: DesignSystem.Spacing.medium),
            layoutButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            layoutButton.widthAnchor.constraint(equalToConstant: Metrics.minimumTouchTarget),
            layoutButton.heightAnchor.constraint(equalTo: layoutButton.widthAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: footerView.topAnchor),
            footerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: Metrics.barHeight),
            segmentedControl.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            segmentedControl.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
            segmentedControl.heightAnchor.constraint(equalToConstant: Metrics.controlHeight),
        ])
    }

    @objc private func didRefresh() { onRefresh?() }
    @objc private func didTapLayout() { onLayoutChange?() }

    @objc private func didChangeSection() {
        let section: HeroesCatalogSection = segmentedControl.selectedSegmentIndex == 0 ? .characters : .favorites
        titleLabel.text = section == .characters ? Localizable.Catalog.characters : Localizable.Catalog.favorites
        onSectionChange?(section)
    }
}
