//
//  HeroesDetailsViewController.swift
//  MarvelChallenge
//
//  Created by c80256a on 11/01/21.
//  Copyright © 2021 Henrique Silva. All rights reserved.
//

import UIKit
import SDWebImage

class HeroesDetailsViewController: UIViewController {
    
    @IBOutlet weak var labelHeader: UILabel!
    @IBOutlet weak var comicLabel: UILabel!
    @IBOutlet weak var seriesLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var comicCollectionView: UICollectionView!
    @IBOutlet weak var seriesCollectionView: UICollectionView!
    
    lazy var manager = RealmManager(delegate: nil)
    var characterObject: Character?
    var fav = false
    
    let cellComics = "DetailsComicCell"
    let cellSeries = "DetailsSeriesCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        characterObject = MarvelSharedInstance.sharedInstance.characterSelect
        setCollectionView()
        setupView() 
    }
    
    func setupView() {
        guard let object = characterObject,
              let path = object.thumbnail?.path,
              let thumbExtension = object.thumbnail?.thumbnailExtension,
              let urlImage = URL(string: "\(path).\(thumbExtension)"),
              let name = object.name else {
            self.imageView.image = UIImage(named: "MarvelLogo")
            return
        }
        self.labelHeader.text = name
        self.imageView.sd_setImage(with: urlImage, placeholderImage: UIImage(named: "MarvelLogo"))
        if let text = characterObject?.resultDescription, text != "" {
            self.descriptionLabel.text = text
        } else {
            self.descriptionLabel.text = "Description not found"
        }
        let favoriteHero = manager.validateHero(object: object)
        fav = favoriteHero
        favoriteButton.setImage(UIImage(named: favoriteHero ? "likedStar": "dislikedStar"), for: .normal)
    }
    
    func setCollectionView(){
        guard characterObject != nil, let series = characterObject?.series?.items?.isEmpty, let comics = characterObject?.series?.items?.isEmpty else {
            comicCollectionView.isHidden = true
            seriesCollectionView.isHidden = true
            return
        }
        
        switch series {
        case true:
            comicCollectionView.isHidden = true
            seriesCollectionView.isHidden = true
        case false:
            seriesLabel.isHidden = true
            seriesCollectionView.delegate = self
            seriesCollectionView.dataSource = self
        }
        
        switch comics {
        case true:
            comicCollectionView.isHidden = true
            seriesCollectionView.isHidden = true
        case false:
            comicLabel.isHidden = true
            comicCollectionView.delegate = self
            comicCollectionView.dataSource = self
        }
    }
    
    func setFav() {
        switch fav {
        case true:
            guard let name = characterObject?.name, let id = characterObject?.id, let image = self.imageView.image else {
                return
            }
            let characterRealm = CharacterRealm()
            characterRealm.name = name
            characterRealm.id = id
            manager.save(object: characterRealm, image: image)
            favoriteButton.setImage(UIImage(named: "likedStar"), for: .normal)
        case false:
            guard let id = characterObject?.id else {
                return
            }
            favoriteButton.setImage(UIImage(named: "dislikedStar"), for: .normal)
            manager.delete(id: id)
        }
        MarvelSharedInstance.sharedInstance.needsReload = true
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapFavorite(_ sender: Any) {
        fav = !fav
        setFav()
    }
}
