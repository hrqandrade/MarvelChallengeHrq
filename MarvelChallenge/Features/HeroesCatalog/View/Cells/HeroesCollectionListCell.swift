import UIKit
import MarvelImageLoader
import MarvelDesignSystem

final class HeroesCollectionListCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: HeroesCollectionListCell.self)
    private let heroImageView = UIImageView()
    private let nameLabel = UILabel()
    private let cardView = UIView()
    private let favoriteButton = UIButton(type: .system)
    private var onFavorite: (() -> Void)?

    override init(frame: CGRect) { super.init(frame: frame); configureView() }
    @available(*, unavailable) required init?(coder: NSCoder) { nil }
    override func prepareForReuse() {
        super.prepareForReuse(); heroImageView.cancelImageLoad(); heroImageView.image = nil; nameLabel.text = nil
        favoriteButton.setImage(nil, for: .normal); onFavorite = nil
    }
    func configure(character: Character, isFavorite: Bool, onFavorite: @escaping () -> Void) {
        configure(name: character.name, imageURL: character.imageURL, isFavorite: isFavorite, onFavorite: onFavorite)
    }
    func configure(favorite: FavoriteCharacter, onFavorite: @escaping () -> Void) {
        configure(name: favorite.name, imageURL: favorite.imageURL, isFavorite: true, onFavorite: onFavorite)
    }

    private func configureView() {
        cardView.translatesAutoresizingMaskIntoConstraints = false; cardView.backgroundColor = DesignSystem.Color.surface
        cardView.layer.cornerRadius = DesignSystem.Radius.medium; cardView.layer.apply(.card)
        heroImageView.contentMode = .scaleAspectFit; heroImageView.layer.cornerRadius = DesignSystem.Radius.small; heroImageView.clipsToBounds = true
        nameLabel.font = DesignSystem.Typography.headline; nameLabel.textColor = DesignSystem.Color.textPrimary; nameLabel.numberOfLines = 2
        favoriteButton.addTarget(self, action: #selector(didTapFavorite), for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [heroImageView, nameLabel, favoriteButton])
        stack.translatesAutoresizingMaskIntoConstraints = false; stack.alignment = .center; stack.spacing = DesignSystem.Spacing.small
        contentView.addSubview(cardView); cardView.addSubview(stack)
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: DesignSystem.Spacing.small),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DesignSystem.Spacing.small),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DesignSystem.Spacing.small),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -DesignSystem.Spacing.small),
            stack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: DesignSystem.Spacing.small),
            stack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: DesignSystem.Spacing.small),
            stack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -DesignSystem.Spacing.small),
            stack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -DesignSystem.Spacing.small),
            heroImageView.widthAnchor.constraint(equalToConstant: 63), heroImageView.heightAnchor.constraint(equalTo: heroImageView.widthAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: 32), favoriteButton.heightAnchor.constraint(equalTo: favoriteButton.widthAnchor)
        ])
    }
    private func configure(name: String, imageURL: URL?, isFavorite: Bool, onFavorite: @escaping () -> Void) {
        nameLabel.text = name; heroImageView.setImage(from: imageURL, placeholder: UIImage(named: "MarvelLogo"))
        favoriteButton.setImage(UIImage(named: isFavorite ? "likedStar" : "dislikedStar"), for: .normal); self.onFavorite = onFavorite
    }
    @objc private func didTapFavorite() { onFavorite?() }
}
