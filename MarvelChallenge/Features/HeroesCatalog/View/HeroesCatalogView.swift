import MarvelDesignSystem
import UIKit

final class HeroesCatalogView: UIView {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: GridFlowLayout())
    let segmentedControl = UISegmentedControl(items: [Localizable.Catalog.characters, Localizable.Catalog.favorites])
    private let headerView = MarvelScreenHeaderView(title: Localizable.Catalog.characters)
    private let footerView = UIView()
    private let refreshControl = UIRefreshControl()
    private let paginationIndicator = UIActivityIndicatorView(style: .medium)
    private let feedbackBanner = MarvelFeedbackBanner()
    private lazy var segmentedHeightConstraint = segmentedControl.heightAnchor.constraint(
        equalToConstant: MarvelComponentSize.segmentedControlHeight
    )

    var onRefresh: (() -> Void)?
    var onLayoutChange: (() -> Void)?
    var onSectionChange: ((HeroesCatalogSection) -> Void)?
    var onRetry: (() -> Void)?

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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory
        else { return }
        configureSegmentedControlTypography()
        segmentedHeightConstraint.constant = MarvelComponentSize.segmentedControlHeight
        collectionView.collectionViewLayout.invalidateLayout()
    }

    func renderLayout(isGrid: Bool, animated: Bool) {
        let imageName = isGrid ? "list.bullet" : "square.grid.2x2"
        let image = UIImage(systemName: imageName)?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: MarvelComponentSize.minimumTouchTarget / 2, weight: .semibold)
        )
        headerView.leadingButton.setImage(image, for: .normal)
        let layout: UICollectionViewLayout = isGrid ? GridFlowLayout() : ListFlowLayout()
        collectionView.setCollectionViewLayout(
            layout,
            animated: animated && !UIAccessibility.isReduceMotionEnabled
        )
    }

    func renderLayoutControl(isHidden: Bool) {
        headerView.leadingButton.isHidden = isHidden
    }

    func renderLoaded() {
        refreshControl.endRefreshing()
        paginationIndicator.stopAnimating()
        collectionView.backgroundView = nil
        collectionView.reloadData()
    }

    func renderRefreshing() {
        paginationIndicator.stopAnimating()
        if !refreshControl.isRefreshing {
            refreshControl.beginRefreshing()
        }
    }

    func renderLoadingNextPage() {
        refreshControl.endRefreshing()
        paginationIndicator.startAnimating()
    }

    func renderEmpty(section: HeroesCatalogSection) {
        refreshControl.endRefreshing()
        paginationIndicator.stopAnimating()
        collectionView.reloadData()
        let imageName = section == .characters ? "person.3.fill" : "star"
        let title = section == .characters
            ? Localizable.Catalog.emptyCharactersTitle
            : Localizable.Catalog.emptyFavoritesTitle
        let description = section == .characters
            ? Localizable.Catalog.emptyCharactersDescription
            : Localizable.Catalog.emptyFavoritesDescription
        collectionView.backgroundView = MarvelEmptyStateView(
            image: UIImage(systemName: imageName),
            title: title,
            description: description
        )
    }

    func renderLoading() {
        paginationIndicator.stopAnimating()
        collectionView.backgroundView = MarvelLoadingView()
    }

    func renderError(message: String) {
        refreshControl.endRefreshing()
        paginationIndicator.stopAnimating()
        collectionView.reloadData()
        let errorView = MarvelErrorStateView(message: message)
        errorView.onRetry = { [weak self] in self?.onRetry?() }
        collectionView.backgroundView = errorView
    }

    func showFeedback(message: String, isError: Bool) {
        feedbackBanner.show(message: message, isError: isError)
    }

    private func configureView() {
        backgroundColor = DesignSystem.Color.accent
    }

    private func configureHeader() {
        headerView.leadingButton.accessibilityIdentifier = AccessibilityIdentifier.Catalog.layoutButton
        headerView.leadingButton.accessibilityLabel = Localizable.Catalog.changeLayout
        headerView.leadingButton.addTarget(self, action: #selector(didTapLayout), for: .touchUpInside)
        headerView.trailingButton.isHidden = true
    }

    private func configureCollection() {
        collectionView.accessibilityIdentifier = AccessibilityIdentifier.Catalog.collection
        collectionView.backgroundColor = DesignSystem.Color.backgroundPrimary
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
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
        paginationIndicator.hidesWhenStopped = true
    }

    private func configureFooter() {
        segmentedControl.accessibilityIdentifier = AccessibilityIdentifier.Catalog.sectionControl
        footerView.backgroundColor = DesignSystem.Color.surface
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = DesignSystem.Color.accent.withAlphaComponent(0.12)
        segmentedControl.selectedSegmentTintColor = DesignSystem.Color.surface
        configureSegmentedControlTypography()
        segmentedControl.addTarget(self, action: #selector(didChangeSection), for: .valueChanged)
    }

    private func configureHierarchy() {
        for item in [headerView, collectionView, footerView, segmentedControl, paginationIndicator, feedbackBanner] {
            item.translatesAutoresizingMaskIntoConstraints = false
        }
        addSubview(headerView)
        addSubview(collectionView)
        addSubview(footerView)
        footerView.addSubview(segmentedControl)
        addSubview(paginationIndicator)
        addSubview(feedbackBanner)
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerView.heightAnchor.constraint(greaterThanOrEqualToConstant: MarvelComponentSize.navigationBarHeight),
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: footerView.topAnchor),
            footerView.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.bottomAnchor,
                constant: -MarvelComponentSize.tabBarHeight
            ),
            footerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            segmentedControl.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            segmentedControl.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -36),
            segmentedHeightConstraint,
            segmentedControl.leadingAnchor.constraint(
                greaterThanOrEqualTo: footerView.leadingAnchor,
                constant: DesignSystem.Spacing.large
            ),
            segmentedControl.trailingAnchor.constraint(
                lessThanOrEqualTo: footerView.trailingAnchor,
                constant: -DesignSystem.Spacing.large
            ),
            paginationIndicator.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            paginationIndicator.bottomAnchor.constraint(
                equalTo: collectionView.bottomAnchor,
                constant: -DesignSystem.Spacing.small
            ),
            feedbackBanner.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: DesignSystem.Spacing.small),
            feedbackBanner.leadingAnchor.constraint(equalTo: leadingAnchor, constant: DesignSystem.Spacing.medium),
            feedbackBanner.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -DesignSystem.Spacing.medium),
        ])
    }

    private func configureSegmentedControlTypography() {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: MarvelTypography.segmentedControlTitle,
            .foregroundColor: DesignSystem.Color.textPrimary,
        ]
        segmentedControl.setTitleTextAttributes(attributes, for: .normal)
        segmentedControl.setTitleTextAttributes(attributes, for: .selected)
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
