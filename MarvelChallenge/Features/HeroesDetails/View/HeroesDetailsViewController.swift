import MarvelDesignSystem
import MarvelImageLoader
import UIKit

final class HeroesDetailsViewController: UIViewController {
    private enum Metrics {
        static let headerHeight: CGFloat = 50
        static let iconSize: CGFloat = 32
        static let imageHeight: CGFloat = 200
        static let collectionHeight: CGFloat = 120
    }

    // MARK: - UI

    let comicCollectionView = HeroesDetailsViewController.makeCollectionView()
    let seriesCollectionView = HeroesDetailsViewController.makeCollectionView()
    private let headerView = UIStackView()
    private let closeButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let favoriteButton = UIButton(type: .system)
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let heroImageView = UIImageView()
    private let descriptionLabel = UILabel()
    private let comicLabel = UILabel()
    private let seriesLabel = UILabel()

    // MARK: - Dependencies

    let viewModel: HeroesDetailsViewModel
    var onClose: (() -> Void)?

    // MARK: - Initialization

    init(viewModel: HeroesDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { nil }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureHeaderView()
        configureHeroImageView()
        configureDescriptionLabel()
        configureSectionLabels()
        configureCollections()
        configureContentStack()
        configureHierarchy()
        configureConstraints()
        render()
    }

    // MARK: - Configuration

    private func configureView() {
        view.backgroundColor = DesignSystem.Color.backgroundPrimary
    }

    private func configureHeaderView() {
        headerView.axis = .horizontal
        headerView.alignment = .center
        headerView.spacing = DesignSystem.Spacing.small
        headerView.isLayoutMarginsRelativeArrangement = true
        headerView.layoutMargins = UIEdgeInsets(
            top: .zero,
            left: DesignSystem.Spacing.medium,
            bottom: .zero,
            right: DesignSystem.Spacing.medium
        )
        headerView.backgroundColor = DesignSystem.Color.accent

        closeButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        closeButton.tintColor = DesignSystem.Color.onAccent
        closeButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)

        titleLabel.font = DesignSystem.Typography.title
        titleLabel.textColor = DesignSystem.Color.onAccent
        titleLabel.textAlignment = .center
        titleLabel.text = viewModel.name

        favoriteButton.tintColor = DesignSystem.Color.onAccent
        favoriteButton.addTarget(self, action: #selector(didTapFavorite), for: .touchUpInside)

        headerView.addArrangedSubview(closeButton)
        headerView.addArrangedSubview(titleLabel)
        headerView.addArrangedSubview(favoriteButton)
    }

    private func configureHeroImageView() {
        heroImageView.contentMode = .scaleAspectFit
        heroImageView.clipsToBounds = true
    }

    private func configureDescriptionLabel() {
        descriptionLabel.font = DesignSystem.Typography.body
        descriptionLabel.textColor = DesignSystem.Color.textSecondary
        descriptionLabel.numberOfLines = 0
    }

    private func configureSectionLabels() {
        comicLabel.font = DesignSystem.Typography.titleSecondary
        comicLabel.textColor = DesignSystem.Color.textPrimary
        comicLabel.text = Localizable.Details.comics

        seriesLabel.font = DesignSystem.Typography.titleSecondary
        seriesLabel.textColor = DesignSystem.Color.textPrimary
        seriesLabel.text = Localizable.Details.series
    }

    private func configureCollections() {
        comicCollectionView.isHidden = viewModel.comics.isEmpty
        comicLabel.isHidden = viewModel.comics.isEmpty
        seriesCollectionView.isHidden = viewModel.series.isEmpty
        seriesLabel.isHidden = viewModel.series.isEmpty

        [comicCollectionView, seriesCollectionView].forEach {
            $0.dataSource = self
            $0.delegate = self
            $0.register(
                DetailsCollectionViewCell.self,
                forCellWithReuseIdentifier: DetailsCollectionViewCell.reuseIdentifier
            )
        }
    }

    private func configureContentStack() {
        contentStack.axis = .vertical
        contentStack.spacing = DesignSystem.Spacing.small
        [heroImageView, descriptionLabel, comicLabel, comicCollectionView, seriesLabel, seriesCollectionView].forEach {
            contentStack.addArrangedSubview($0)
        }
    }

    private func configureHierarchy() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: Metrics.headerHeight),

            closeButton.widthAnchor.constraint(equalToConstant: Metrics.iconSize),
            favoriteButton.widthAnchor.constraint(equalToConstant: Metrics.iconSize),

            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: DesignSystem.Spacing.medium),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: DesignSystem.Spacing.medium),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -DesignSystem.Spacing.medium),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -DesignSystem.Spacing.large),

            heroImageView.heightAnchor.constraint(equalToConstant: Metrics.imageHeight),
            comicCollectionView.heightAnchor.constraint(equalToConstant: Metrics.collectionHeight),
            seriesCollectionView.heightAnchor.constraint(equalToConstant: Metrics.collectionHeight),
        ])
    }

    // MARK: - Rendering

    private func render() {
        descriptionLabel.text = viewModel.description
        heroImageView.setImage(from: viewModel.imageURL, placeholder: UIImage(named: "MarvelLogo"))
        updateFavoriteButton(isFavorite: viewModel.isFavorite)
    }

    private func updateFavoriteButton(isFavorite: Bool) {
        let imageName = isFavorite ? "likedStar" : "dislikedStar"
        favoriteButton.setImage(UIImage(named: imageName), for: .normal)
    }

    // MARK: - Actions

    @objc private func didTapBack() {
        onClose?()
    }

    @objc private func didTapFavorite() {
        favoriteButton.isEnabled = false
        viewModel.toggleFavorite { [weak self] result in
            guard let self else { return }
            self.favoriteButton.isEnabled = true
            switch result {
            case let .success(isFavorite):
                self.updateFavoriteButton(isFavorite: isFavorite)
            case let .failure(message):
                self.presentAlert(withTitle: Localizable.Common.error, message: message)
            }
        }
    }

    // MARK: - Factory

    private static func makeCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = DesignSystem.Spacing.small

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        return collectionView
    }
}
