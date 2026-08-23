import UIKit
import MarvelImageLoader
import MarvelDesignSystem

final class HeroesDetailsViewController: UIViewController {
    @IBOutlet private weak var labelHeader: UILabel!
    @IBOutlet private weak var comicLabel: UILabel!
    @IBOutlet private weak var seriesLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var favoriteButton: UIButton!
    @IBOutlet weak var comicCollectionView: UICollectionView!
    @IBOutlet weak var seriesCollectionView: UICollectionView!

    private var configuredViewModel: HeroesDetailsViewModel?
    var viewModel: HeroesDetailsViewModel {
        get {
            guard let configuredViewModel else {
                preconditionFailure("HeroesDetailsViewModel must be injected by the coordinator")
            }
            return configuredViewModel
        }
        set { configuredViewModel = newValue }
    }
    let cellComics = "DetailsComicCell"
    let cellSeries = "DetailsSeriesCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DesignSystem.Color.backgroundPrimary
        labelHeader.font = DesignSystem.Typography.title
        labelHeader.textColor = DesignSystem.Color.textPrimary
        descriptionLabel.font = DesignSystem.Typography.body
        descriptionLabel.textColor = DesignSystem.Color.textSecondary
        comicLabel.font = DesignSystem.Typography.titleSecondary
        seriesLabel.font = DesignSystem.Typography.titleSecondary
        comicLabel.text = Localizable.Details.comics
        seriesLabel.text = Localizable.Details.series
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
