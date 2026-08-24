import UIKit
import MarvelImageLoader
import MarvelDesignSystem

final class HeroesDetailsViewController: UIViewController {
    let viewModel: HeroesDetailsViewModel
    var onClose: (() -> Void)?
    let comicCollectionView = HeroesDetailsViewController.makeCollectionView()
    let seriesCollectionView = HeroesDetailsViewController.makeCollectionView()
    private let heroImageView = UIImageView()
    private let descriptionLabel = UILabel()
    private let favoriteButton = UIButton(type: .system)
    private let comicLabel = UILabel()
    private let seriesLabel = UILabel()

    init(viewModel: HeroesDetailsViewModel) { self.viewModel = viewModel; super.init(nibName: nil, bundle: nil) }
    @available(*, unavailable) required init?(coder: NSCoder) { nil }

    override func viewDidLoad() { super.viewDidLoad(); configureView(); configureCollections(); render() }

    private func configureView() {
        view.backgroundColor = DesignSystem.Color.backgroundPrimary
        let closeButton = UIButton(type: .system); closeButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        closeButton.tintColor = DesignSystem.Color.onAccent; closeButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        favoriteButton.tintColor = DesignSystem.Color.onAccent; favoriteButton.addTarget(self, action: #selector(didTapFavorite), for: .touchUpInside)
        let titleLabel = UILabel(); titleLabel.font = DesignSystem.Typography.title; titleLabel.textColor = DesignSystem.Color.onAccent
        titleLabel.textAlignment = .center; titleLabel.text = viewModel.name
        let header = UIStackView(arrangedSubviews: [closeButton, titleLabel, favoriteButton])
        header.translatesAutoresizingMaskIntoConstraints = false; header.alignment = .center; header.spacing = DesignSystem.Spacing.small
        header.isLayoutMarginsRelativeArrangement = true; header.layoutMargins = UIEdgeInsets(top: 0, left: DesignSystem.Spacing.medium, bottom: 0, right: DesignSystem.Spacing.medium)
        header.backgroundColor = DesignSystem.Color.accent
        closeButton.widthAnchor.constraint(equalToConstant: 32).isActive = true; favoriteButton.widthAnchor.constraint(equalToConstant: 32).isActive = true

        heroImageView.contentMode = .scaleAspectFit; heroImageView.clipsToBounds = true
        descriptionLabel.font = DesignSystem.Typography.body; descriptionLabel.textColor = DesignSystem.Color.textSecondary; descriptionLabel.numberOfLines = 0
        [comicLabel, seriesLabel].forEach { $0.font = DesignSystem.Typography.titleSecondary; $0.textColor = DesignSystem.Color.textPrimary }
        comicLabel.text = Localizable.Details.comics; seriesLabel.text = Localizable.Details.series
        let contentStack = UIStackView(arrangedSubviews: [heroImageView, descriptionLabel, comicLabel, comicCollectionView, seriesLabel, seriesCollectionView])
        contentStack.translatesAutoresizingMaskIntoConstraints = false; contentStack.axis = .vertical; contentStack.spacing = DesignSystem.Spacing.small
        let scrollView = UIScrollView(); scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header); view.addSubview(scrollView); scrollView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor), header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor), header.heightAnchor.constraint(equalToConstant: 50),
            scrollView.topAnchor.constraint(equalTo: header.bottomAnchor), scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor), scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: DesignSystem.Spacing.medium),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: DesignSystem.Spacing.medium),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -DesignSystem.Spacing.medium),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -DesignSystem.Spacing.large),
            heroImageView.heightAnchor.constraint(equalToConstant: 200), comicCollectionView.heightAnchor.constraint(equalToConstant: 120),
            seriesCollectionView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }

    private func render() {
        descriptionLabel.text = viewModel.description; heroImageView.setImage(from: viewModel.imageURL, placeholder: UIImage(named: "MarvelLogo"))
        favoriteButton.setImage(UIImage(named: viewModel.isFavorite ? "likedStar" : "dislikedStar"), for: .normal)
    }
    private func configureCollections() {
        comicCollectionView.isHidden = viewModel.comics.isEmpty; comicLabel.isHidden = viewModel.comics.isEmpty
        seriesCollectionView.isHidden = viewModel.series.isEmpty; seriesLabel.isHidden = viewModel.series.isEmpty
        [comicCollectionView, seriesCollectionView].forEach {
            $0.dataSource = self; $0.delegate = self
            $0.register(DetailsCollectionViewCell.self, forCellWithReuseIdentifier: DetailsCollectionViewCell.reuseIdentifier)
        }
    }
    @objc private func didTapBack() { onClose?() }
    @objc private func didTapFavorite() {
        favoriteButton.isEnabled = false
        viewModel.toggleFavorite { [weak self] result in
            guard let self else { return }; self.favoriteButton.isEnabled = true
            switch result {
            case .success(let isFavorite): self.favoriteButton.setImage(UIImage(named: isFavorite ? "likedStar" : "dislikedStar"), for: .normal)
            case .failure(let message): self.presentAlert(withTitle: Localizable.Common.error, message: message)
            }
        }
    }
    private static func makeCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout(); layout.scrollDirection = .horizontal; layout.minimumLineSpacing = DesignSystem.Spacing.small
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout); view.backgroundColor = .clear; return view
    }
}
