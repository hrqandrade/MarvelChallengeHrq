import UIKit

extension HeroesDetailsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        if collectionView == comicCollectionView {
            return viewModel.comics.count
        } else {
            return viewModel.series.count
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let isComicsCollection = collectionView == comicCollectionView
        let item = isComicsCollection ? viewModel.comics[indexPath.row] : viewModel.series[indexPath.row]
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DetailsCollectionViewCell.reuseIdentifier,
            for: indexPath
        )
        (cell as? DetailsCollectionViewCell)?.setupCell(description: item.name)
        return cell
    }

    func numberOfSections(in _: UICollectionView) -> Int {
        1
    }
}

extension HeroesDetailsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        CGSize(width: MarvelComponentSize.detailsCarouselHeight, height: MarvelComponentSize.detailsCarouselHeight)
    }
}
