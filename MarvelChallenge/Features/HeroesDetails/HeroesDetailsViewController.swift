import UIKit
import MarvelImageLoader

final class HeroesDetailsViewController: UIViewController {
    @IBOutlet private weak var labelHeader: UILabel!
    @IBOutlet private weak var comicLabel: UILabel!
    @IBOutlet private weak var seriesLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var favoriteButton: UIButton!
    @IBOutlet weak var comicCollectionView: UICollectionView!
    @IBOutlet weak var seriesCollectionView: UICollectionView!

    var viewModel: HeroesDetailsViewModel!
    let cellComics = "DetailsComicCell"
    let cellSeries = "DetailsSeriesCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil, "HeroesDetailsViewModel must be injected by the coordinator")
        configureCollections()
        render()
    }

    private func render() {
        labelHeader.text = viewModel.name
        descriptionLabel.text = viewModel.description
        imageView.setImage(from: viewModel.imageURL, placeholder: UIImage(named: "MarvelLogo"))
        favoriteButton.setImage(UIImage(named: viewModel.isFavorite ? "likedStar" : "dislikedStar"), for: .normal)
    }

    private func configureCollections() {
        comicCollectionView.isHidden = viewModel.comics.isEmpty
        comicLabel.isHidden = viewModel.comics.isEmpty
        seriesCollectionView.isHidden = viewModel.series.isEmpty
        seriesLabel.isHidden = viewModel.series.isEmpty
        comicCollectionView.dataSource = self
        comicCollectionView.delegate = self
        seriesCollectionView.dataSource = self
        seriesCollectionView.delegate = self
    }

    @IBAction private func didTapBack(_ sender: Any) { dismiss(animated: true) }

    @IBAction private func didTapFavorite(_ sender: Any) {
        viewModel.toggleFavorite()
        favoriteButton.setImage(UIImage(named: viewModel.isFavorite ? "likedStar" : "dislikedStar"), for: .normal)
    }
}
