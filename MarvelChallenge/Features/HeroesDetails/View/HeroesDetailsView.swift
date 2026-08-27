import MarvelDesignSystem
import MarvelImageLoader
import UIKit

final class HeroesDetailsView: UIView {
    let comicCollectionView = HeroesDetailsView.makeCollectionView()
    let seriesCollectionView = HeroesDetailsView.makeCollectionView()
    private let headerView = MarvelScreenHeaderView(title: "")
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let heroImageView = UIImageView()
    private let descriptionLabel = UILabel()
    private let comicLabel = UILabel()
    private let seriesLabel = UILabel()

    var onClose: (() -> Void)?
    var onFavorite: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        configureHeader()
        configureContent()
        configureHierarchy()
        configureConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { nil }

    func render(
        name: String,
        description: String,
        imageURL: URL?,
        isFavorite: Bool,
        hasComics: Bool,
        hasSeries: Bool
    ) {
        headerView.setTitle(name)
        descriptionLabel.text = description
        heroImageView.setImage(from: imageURL, placeholder: UIImage(named: "MarvelLogo"))
        comicLabel.isHidden = !hasComics
        comicCollectionView.isHidden = !hasComics
        seriesLabel.isHidden = !hasSeries
        seriesCollectionView.isHidden = !hasSeries
        renderFavorite(isFavorite: isFavorite)
    }

    func renderFavorite(isFavorite: Bool) {
        headerView.trailingButton.setImage(UIImage(named: isFavorite ? "likedStar" : "dislikedStar"), for: .normal)
        headerView.trailingButton.accessibilityLabel = isFavorite ? Localizable.Details.removeFavorite : Localizable.Details.addFavorite
    }

    func setFavoriteEnabled(_ isEnabled: Bool) {
        headerView.trailingButton.isEnabled = isEnabled
    }

    private func configureView() {
        backgroundColor = DesignSystem.Color.accent
        scrollView.backgroundColor = DesignSystem.Color.backgroundPrimary
    }

    private func configureHeader() {
        headerView.leadingButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        headerView.leadingButton.accessibilityLabel = Localizable.Details.back
        headerView.leadingButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        headerView.trailingButton.addTarget(self, action: #selector(didTapFavorite), for: .touchUpInside)
    }

    private func configureContent() {
        heroImageView.contentMode = .scaleAspectFit
        heroImageView.clipsToBounds = true
        descriptionLabel.font = DesignSystem.Typography.body
        descriptionLabel.adjustsFontForContentSizeCategory = true
        descriptionLabel.textColor = DesignSystem.Color.textSecondary
        descriptionLabel.numberOfLines = 0
        comicLabel.font = DesignSystem.Typography.titleSecondary
        comicLabel.adjustsFontForContentSizeCategory = true
        comicLabel.textColor = DesignSystem.Color.textPrimary
        comicLabel.text = Localizable.Details.comics
        seriesLabel.font = DesignSystem.Typography.titleSecondary
        seriesLabel.adjustsFontForContentSizeCategory = true
        seriesLabel.textColor = DesignSystem.Color.textPrimary
        seriesLabel.text = Localizable.Details.series
        contentStack.axis = .vertical
        contentStack.spacing = DesignSystem.Spacing.small
        [heroImageView, descriptionLabel, comicLabel, comicCollectionView, seriesLabel, seriesCollectionView].forEach(contentStack.addArrangedSubview)
    }

    private func configureHierarchy() {
        [headerView, scrollView, contentStack].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        addSubview(headerView)
        addSubview(scrollView)
        scrollView.addSubview(contentStack)
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: MarvelComponentSize.navigationBarHeight),
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: DesignSystem.Spacing.medium),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: DesignSystem.Spacing.medium),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -DesignSystem.Spacing.medium),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -DesignSystem.Spacing.large),
            heroImageView.heightAnchor.constraint(equalToConstant: MarvelComponentSize.heroImageHeight),
            comicCollectionView.heightAnchor.constraint(equalToConstant: MarvelComponentSize.detailsCarouselHeight),
            seriesCollectionView.heightAnchor.constraint(equalToConstant: MarvelComponentSize.detailsCarouselHeight),
        ])
    }

    @objc private func didTapClose() { onClose?() }
    @objc private func didTapFavorite() { onFavorite?() }

    private static func makeCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = DesignSystem.Spacing.small
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(DetailsCollectionViewCell.self, forCellWithReuseIdentifier: DetailsCollectionViewCell.reuseIdentifier)
        return collectionView
    }
}
