import MarvelDesignSystem
import UIKit

final class HeroesCatalogView: UIView {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: GridFlowLayout())
    let segmentedControl = UISegmentedControl(items: [Localizable.Catalog.characters, Localizable.Catalog.favorites])
    private let headerView = MarvelScreenHeaderView(title: Localizable.Catalog.characters)
    private let footerView = UIView()
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
    required init?(coder _: NSCoder) {
        nil
    }

    func renderLayout(isGrid: Bool, animated: Bool) {
        headerView.leadingButton.setImage(UIImage(named: isGrid ? "list" : "grid"), for: .normal)
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
        let label = section == .characters ? Localizable.Catalog.characters : Localizable.Catalog.favorites
        collectionView.backgroundView = MarvelEmptyStateView(
            image: UIImage(named: imageName),
            accessibilityLabel: label
        )
    }

    func renderLoading() {
        collectionView.backgroundView = MarvelLoadingView()
    }

    func endRefreshing() {
        refreshControl.endRefreshing()
    }

    private func configureView() {
        backgroundColor = DesignSystem.Color.accent
    }

    private func configureHeader() {
        headerView.leadingButton.accessibilityLabel = Localizable.Catalog.changeLayout
        headerView.leadingButton.addTarget(self, action: #selector(didTapLayout), for: .touchUpInside)
        headerView.trailingButton.isHidden = true
    }

    private func configureCollection() {
        collectionView.backgroundColor = DesignSystem.Color.backgroundPrimary
        collectionView.register(
            HeroesCollectionViewCell.self,
            forCellWithReuseIdentifier: HeroesCollectionViewCell.reuseIdentifier
        )
        collectionView.register(
            HeroesCollectionListCell.self,
            forCellWithReuseIdentifier: HeroesCollectionListCell.reuseIdentifier
        )
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
        for item in [headerView, collectionView, footerView, segmentedControl] {
            item.translatesAutoresizingMaskIntoConstraints = false
        }
        addSubview(headerView)
        addSubview(collectionView)
        addSubview(footerView)
        footerView.addSubview(segmentedControl)
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: MarvelComponentSize.navigationBarHeight),
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: footerView.topAnchor),
            footerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: MarvelComponentSize.navigationBarHeight),
            segmentedControl.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            segmentedControl.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
            segmentedControl.heightAnchor.constraint(equalToConstant: MarvelComponentSize.segmentedControlHeight),
        ])
    }

    @objc private func didRefresh() {
        onRefresh?()
    }

    @objc private func didTapLayout() {
        onLayoutChange?()
    }

    @objc private func didChangeSection() {
        let section: HeroesCatalogSection = segmentedControl.selectedSegmentIndex == 0 ? .characters : .favorites
        headerView.setTitle(section == .characters ? Localizable.Catalog.characters : Localizable.Catalog.favorites)
        onSectionChange?(section)
    }
}
