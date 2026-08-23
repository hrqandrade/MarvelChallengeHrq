import UIKit
import MarvelImageLoader
import MarvelDesignSystem

final class HeroesCollectionListCell: UICollectionViewCell {
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var label: UILabel!
    @IBOutlet private var cardView: UIView!
    @IBOutlet private var favButton: UIButton!
    private var onFavorite: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.cornerRadius = DesignSystem.Radius.small
        imageView.layer.masksToBounds = true
        label.font = DesignSystem.Typography.headline
        label.textColor = DesignSystem.Color.textPrimary
        cardView.backgroundColor = DesignSystem.Color.surface
        cardView.layer.cornerRadius = DesignSystem.Radius.medium
        cardView.layer.apply(.card)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.cancelImageLoad()
        imageView.image = nil
        label.text = nil
        favButton.setImage(nil, for: .normal)
        onFavorite = nil
    }

    func configure(character: Character, isFavorite: Bool, onFavorite: @escaping () -> Void) {
        configure(name: character.name ?? "", imageURL: character.imageURL, isFavorite: isFavorite, onFavorite: onFavorite)
    }

    func configure(favorite: FavoriteCharacter, onFavorite: @escaping () -> Void) {
        configure(name: favorite.name, imageURL: favorite.imageURL, isFavorite: true, onFavorite: onFavorite)
    }

    private func configure(name: String, imageURL: URL?, isFavorite: Bool, onFavorite: @escaping () -> Void) {
        label.text = name
        imageView.setImage(from: imageURL, placeholder: UIImage(named: "MarvelLogo"))
        favButton.setImage(UIImage(named: isFavorite ? "likedStar" : "dislikedStar"), for: .normal)
        self.onFavorite = onFavorite
    }

    @IBAction private func didTapFavorite(_ sender: Any) { onFavorite?() }
}
