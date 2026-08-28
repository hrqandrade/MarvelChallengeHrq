import UIKit

final class HeroesDetailsViewController: UIViewController {
    private let contentView = HeroesDetailsView()
    let viewModel: HeroesDetailsViewModel
    var onClose: (() -> Void)?

    var comicCollectionView: UICollectionView {
        contentView.comicCollectionView
    }

    var seriesCollectionView: UICollectionView {
        contentView.seriesCollectionView
    }

    init(viewModel: HeroesDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        nil
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }

    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollections()
        bindViewActions()
        render()
    }

    private func configureCollections() {
        for item in [comicCollectionView, seriesCollectionView] {
            item.dataSource = self
            item.delegate = self
        }
    }

    private func bindViewActions() {
        contentView.onClose = { [weak self] in self?.onClose?() }
        contentView.onFavorite = { [weak self] in self?.toggleFavorite() }
    }

    private func render() {
        contentView.render(.init(
            name: viewModel.name,
            description: viewModel.description,
            imageURL: viewModel.imageURL,
            isFavorite: viewModel.isFavorite,
            hasComics: !viewModel.comics.isEmpty,
            hasSeries: !viewModel.series.isEmpty
        ))
    }

    private func toggleFavorite() {
        contentView.setFavoriteEnabled(false)
        viewModel.toggleFavorite { [weak self] result in
            guard let self else { return }
            self.contentView.setFavoriteEnabled(true)
            switch result {
            case let .success(isFavorite):
                self.contentView.renderFavorite(isFavorite: isFavorite)
            case let .failure(message):
                self.presentAlert(withTitle: Localizable.Common.error, message: message)
            }
        }
    }
}
