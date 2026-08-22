import UIKit

final class HeroesCollectionListCell: UICollectionViewCell {
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var label: UILabel!
    @IBOutlet private var cardView: UIView!
    @IBOutlet private var favButton: UIButton!
    private var onFavorite: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        [imageView, label, cardView].forEach { $0?.layer.cornerRadius = 3; $0?.layer.masksToBounds = true }
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
