import UIKit

final class HeroesCatalogViewController: UIViewController {
    @IBOutlet weak var heroesCollectionView: UICollectionView!
    @IBOutlet weak var layoutButton: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    var viewModel: HeroesCatalogViewModel!
    var onSelectCharacter: ((Character) -> Void)?
    var isGridLayout = true
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil, "HeroesCatalogViewModel must be injected by the coordinator")
        configureCollectionView()
        bindViewModel()
        viewModel.loadInitial()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reloadFavorites()
        heroesCollectionView.reloadData()
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
            self.heroesCollectionView.reloadData()
            switch state {
            case .empty: self.setEmptyBackground()
            case .failed(let message): self.presentAlert(withTitle: "Erro", message: message)
            case .loaded: self.heroesCollectionView.backgroundView = nil
            default: break
            }
        }
    }

    private func configureCollectionView() {
        heroesCollectionView.dataSource = self
        heroesCollectionView.delegate = self
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        heroesCollectionView.refreshControl = refreshControl
        updateLayout()
    }

    @objc private func refresh() {
        viewModel.reload()
    }

    private func updateLayout() {
        layoutButton.setImage(UIImage(named: isGridLayout ? "list" : "grid"), for: .normal)
        heroesCollectionView.setCollectionViewLayout(isGridLayout ? GridFlowLayout() : ListFlowLayout(), animated: true)
        heroesCollectionView.reloadData()
    }

    private func setEmptyBackground() {
        let imageName = segmentedControl.selectedSegmentIndex == 0 ? "emptyList" : "emptyFavorite"
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.contentMode = .scaleAspectFit
        heroesCollectionView.backgroundView = imageView
    }

    @IBAction private func didTapLayout(_ sender: Any) {
        isGridLayout.toggle()
        updateLayout()
    }

    @IBAction private func didChangeCategory(_ sender: Any) {
        let section: HeroesCatalogSection = segmentedControl.selectedSegmentIndex == 0 ? .characters : .favorites
        headerLabel.text = section == .characters ? "Characters" : "Favorites"
        viewModel.selectSection(section)
    }
}
