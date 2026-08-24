import UIKit
import MarvelDesignSystem

final class HeroesCatalogViewController: UIViewController {
    let heroesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: GridFlowLayout())
    let layoutButton = UIButton(type: .system)
    let headerLabel = UILabel()
    let segmentedControl = UISegmentedControl(items: [Localizable.Catalog.characters, Localizable.Catalog.favorites])
    let viewModel: HeroesCatalogViewModel
    var onSelectCharacter: ((Character) -> Void)?
    var isGridLayout = true
    private let refreshControl = UIRefreshControl()

    init(viewModel: HeroesCatalogViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView(); configureCollectionView(); bindViewModel(); viewModel.loadInitial()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated); viewModel.reloadFavorites()
    }

    private func configureView() {
        view.backgroundColor = DesignSystem.Color.backgroundPrimary
        headerLabel.font = DesignSystem.Typography.title
        headerLabel.textColor = DesignSystem.Color.onAccent
        headerLabel.text = Localizable.Catalog.characters
        headerLabel.textAlignment = .center
        layoutButton.tintColor = DesignSystem.Color.onAccent
        layoutButton.addTarget(self, action: #selector(didTapLayout), for: .touchUpInside)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.selectedSegmentTintColor = DesignSystem.Color.surface
        segmentedControl.addTarget(self, action: #selector(didChangeCategory), for: .valueChanged)

        let header = UIView(); header.translatesAutoresizingMaskIntoConstraints = false; header.backgroundColor = DesignSystem.Color.accent
        let footer = UIView(); footer.translatesAutoresizingMaskIntoConstraints = false; footer.backgroundColor = DesignSystem.Color.accent
        [layoutButton, headerLabel, segmentedControl, heroesCollectionView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        view.addSubview(header); view.addSubview(heroesCollectionView); view.addSubview(footer)
        header.addSubview(layoutButton); header.addSubview(headerLabel); footer.addSubview(segmentedControl)
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor), header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor), header.heightAnchor.constraint(equalToConstant: 50),
            layoutButton.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: DesignSystem.Spacing.medium),
            layoutButton.centerYAnchor.constraint(equalTo: header.centerYAnchor), layoutButton.widthAnchor.constraint(equalToConstant: 32), layoutButton.heightAnchor.constraint(equalTo: layoutButton.widthAnchor),
            headerLabel.centerXAnchor.constraint(equalTo: header.centerXAnchor), headerLabel.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            heroesCollectionView.topAnchor.constraint(equalTo: header.bottomAnchor), heroesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            heroesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor), heroesCollectionView.bottomAnchor.constraint(equalTo: footer.topAnchor),
            footer.leadingAnchor.constraint(equalTo: view.leadingAnchor), footer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor), footer.heightAnchor.constraint(equalToConstant: 50),
            segmentedControl.centerXAnchor.constraint(equalTo: footer.centerXAnchor), segmentedControl.centerYAnchor.constraint(equalTo: footer.centerYAnchor),
            segmentedControl.heightAnchor.constraint(equalToConstant: 40)
        ])
        updateLayout()
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            switch state {
            case .initialLoading: self.heroesCollectionView.backgroundView = nil
            case .refreshing, .loadingNextPage, .idle: break
            case .loaded:
                self.refreshControl.endRefreshing(); self.heroesCollectionView.backgroundView = nil; self.heroesCollectionView.reloadData()
            case .empty:
                self.refreshControl.endRefreshing(); self.heroesCollectionView.reloadData(); self.setEmptyBackground()
            case .failed(let message):
                self.refreshControl.endRefreshing(); self.presentAlert(withTitle: Localizable.Common.error, message: message)
            }
        }
    }

    private func configureCollectionView() {
        heroesCollectionView.backgroundColor = DesignSystem.Color.backgroundPrimary
        heroesCollectionView.dataSource = self; heroesCollectionView.delegate = self
        heroesCollectionView.register(HeroesCollectionViewCell.self, forCellWithReuseIdentifier: HeroesCollectionViewCell.reuseIdentifier)
        heroesCollectionView.register(HeroesCollectionListCell.self, forCellWithReuseIdentifier: HeroesCollectionListCell.reuseIdentifier)
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged); heroesCollectionView.refreshControl = refreshControl
    }

    @objc private func refresh() { viewModel.reload() }
    private func updateLayout() {
        layoutButton.setImage(UIImage(named: isGridLayout ? "list" : "grid"), for: .normal)
        if isViewLoaded { heroesCollectionView.setCollectionViewLayout(isGridLayout ? GridFlowLayout() : ListFlowLayout(), animated: true) }
    }
    private func setEmptyBackground() {
        let imageView = UIImageView(image: UIImage(named: segmentedControl.selectedSegmentIndex == 0 ? "emptyList" : "emptyFavorite"))
        imageView.contentMode = .scaleAspectFit; heroesCollectionView.backgroundView = imageView
    }
    @objc private func didTapLayout() { isGridLayout.toggle(); updateLayout() }
    @objc private func didChangeCategory() {
        let section: HeroesCatalogSection = segmentedControl.selectedSegmentIndex == 0 ? .characters : .favorites
        headerLabel.text = section == .characters ? Localizable.Catalog.characters : Localizable.Catalog.favorites
        viewModel.selectSection(section)
    }
}
