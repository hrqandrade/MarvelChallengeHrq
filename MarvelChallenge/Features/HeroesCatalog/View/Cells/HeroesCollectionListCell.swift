import MarvelDesignSystem
import MarvelImageLoader
import UIKit

final class HeroesCollectionListCell: UICollectionViewCell {
    private enum Metrics {
        static let imageSize: CGFloat = 63
        static let minimumTouchTarget: CGFloat = 44
    }

    // MARK: - UI

    static let reuseIdentifier = String(describing: HeroesCollectionListCell.self)
    private let heroImageView = UIImageView()
    private let nameLabel = UILabel()
    private let cardView = UIView()
    private let favoriteButton = UIButton(type: .system)
    private var onFavorite: (() -> Void)?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCardView()
        configureImageView()
        configureNameLabel()
        configureFavoriteButton()
        configureHierarchy()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { nil }

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
        heroImageView.cancelImageLoad()
        heroImageView.image = nil
        nameLabel.text = nil
        favoriteButton.setImage(nil, for: .normal)
        onFavorite = nil
    }

    func configure(character: Character, isFavorite: Bool, onFavorite: @escaping () -> Void) {
        configure(name: character.name, imageURL: character.imageURL, isFavorite: isFavorite, onFavorite: onFavorite)
    }

    func configure(favorite: FavoriteCharacter, onFavorite: @escaping () -> Void) {
        configure(name: favorite.name, imageURL: favorite.imageURL, isFavorite: true, onFavorite: onFavorite)
    }

    // MARK: - Configuration

    private func configureCardView() {
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = DesignSystem.Color.surface
        cardView.layer.cornerRadius = DesignSystem.Radius.medium
        cardView.layer.apply(.card)
    }

    private func configureImageView() {
        heroImageView.contentMode = .scaleAspectFit
        heroImageView.layer.cornerRadius = DesignSystem.Radius.small
        heroImageView.clipsToBounds = true
    }

    private func configureNameLabel() {
        nameLabel.font = DesignSystem.Typography.headline
        nameLabel.textColor = DesignSystem.Color.textPrimary
        nameLabel.numberOfLines = 2
    }

    private func configureFavoriteButton() {
        favoriteButton.addTarget(self, action: #selector(didTapFavorite), for: .touchUpInside)
    }

    private func configureHierarchy() {
        let stack = UIStackView(arrangedSubviews: [heroImageView, nameLabel, favoriteButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .center
        stack.spacing = DesignSystem.Spacing.small

        contentView.addSubview(cardView)
        cardView.addSubview(stack)
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: DesignSystem.Spacing.small),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DesignSystem.Spacing.small),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DesignSystem.Spacing.small),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -DesignSystem.Spacing.small),
            stack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: DesignSystem.Spacing.small),
            stack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: DesignSystem.Spacing.small),
            stack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -DesignSystem.Spacing.small),
            stack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -DesignSystem.Spacing.small),
            heroImageView.widthAnchor.constraint(equalToConstant: Metrics.imageSize),
            heroImageView.heightAnchor.constraint(equalTo: heroImageView.widthAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: Metrics.minimumTouchTarget),
            favoriteButton.heightAnchor.constraint(equalTo: favoriteButton.widthAnchor),
        ])
    }

    private func configure(name: String, imageURL: URL?, isFavorite: Bool, onFavorite: @escaping () -> Void) {
        nameLabel.text = name
        heroImageView.setImage(from: imageURL, placeholder: UIImage(named: "MarvelLogo"))
        favoriteButton.setImage(UIImage(named: isFavorite ? "likedStar" : "dislikedStar"), for: .normal)
        self.onFavorite = onFavorite
    }

    // MARK: - Actions

    @objc private func didTapFavorite() {
        onFavorite?()
    }
}
