//
//  HeroesCollectionListCell.swift
//  MarvelChallenge
//
//  Created by Henrique Silva on 09/01/21.
//  Copyright © 2021 Henrique Silva. All rights reserved.
//

import UIKit
import SDWebImage

class HeroesCollectionListCell: UICollectionViewCell {
    @IBOutlet weak var stackCardView: UIStackView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var imageViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var label: UILabel!
    @IBOutlet var cardView: UIView!
    @IBOutlet weak var favButton: UIButton!
    
    lazy var manager = RealmManager(delegate: nil)
    var fav = false
    var character: Character?
    var realmId = 0
    var favButtonAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.cornerRadius = 3
        imageView.layer.masksToBounds = true
        label.layer.cornerRadius = 3
        label.layer.masksToBounds = true
        cardView.layer.cornerRadius = 3
        cardView.layer.masksToBounds = true
    }
    
    func setupWithRequest(object: Character) {
        self.favButtonAction = nil
        self.character = object
        let favoriteHero = manager.validateHero(object: object)
        fav = favoriteHero
        favButton.setImage(UIImage(named: favoriteHero ? "likedStar": "dislikedStar"), for: .normal)
        self.label.text = object.name
        guard let path = object.thumbnail?.path,
              let thumbExtension = object.thumbnail?.thumbnailExtension,
              let urlImage = URL(string: "\(path).\(thumbExtension)") else {
            self.imageView.image = UIImage(named: "MarvelLogo")
            return
        }
        self.imageView.sd_setImage(with: urlImage, placeholderImage: UIImage(named: "MarvelLogo"))
    }
    
    func setupWithRealm(object: CharacterRealm, didTapFav: (() -> Void)?){
        self.character = nil
        self.favButtonAction = didTapFav
        self.realmId = object.id
        self.label.text = object.name
        fav = true
        favButton.setImage(UIImage(named: "likedStar"), for: .normal)
        if let decodedData = Data(base64Encoded: object.urlImage, options: .ignoreUnknownCharacters) {
            self.imageView.image = UIImage(data: decodedData)
        }
    }
    
    @IBAction func didTapFavorite(_ sender: Any) {
        fav = !fav
        setFav()
        self.favButtonAction?()
    }
    
    func setFav() {
        switch fav {
        case true:
            guard let name = character?.name, let id = character?.id, let image = self.imageView.image else {
                return
            }
            let characterRealm = CharacterRealm()
            characterRealm.name = name
            characterRealm.id = id
            manager.save(object: characterRealm, image: image)
            favButton.setImage(UIImage(named: "likedStar"), for: .normal)
        case false:
            guard let id = character?.id else {
                return
            }
            favButton.setImage(UIImage(named: "dislikedStar"), for: .normal)
            manager.delete(id: id)
        }
    }
}
