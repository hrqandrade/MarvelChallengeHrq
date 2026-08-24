import UIKit

extension HeroesCatalogViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.itemCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = isGridLayout ? HeroesCollectionViewCell.reuseIdentifier : HeroesCollectionListCell.reuseIdentifier
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        if let character = viewModel.character(at: indexPath.item) {
            let action: () -> Void = { [weak self] in
                self?.viewModel.toggleFavorite(character)
            }
            (cell as? HeroesCollectionViewCell)?.configure(character: character, isFavorite: viewModel.isFavorite(character), onFavorite: action)
            (cell as? HeroesCollectionListCell)?.configure(character: character, isFavorite: viewModel.isFavorite(character), onFavorite: action)
        } else if let favorite = viewModel.favorite(at: indexPath.item) {
            let action = { [weak self] in
                guard let self = self, let index = self.viewModel.favoriteCharacters.firstIndex(of: favorite) else { return }
                self.viewModel.removeFavorite(at: index)
            }
            (cell as? HeroesCollectionViewCell)?.configure(favorite: favorite, onFavorite: action)
            (cell as? HeroesCollectionListCell)?.configure(favorite: favorite, onFavorite: action)
        }
        return cell
    }
}

extension HeroesCatalogViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let character = viewModel.character(at: indexPath.item) else { return }
        onSelectCharacter?(character)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.loadNextPageIfNeeded(index: indexPath.item)
    }
}
