import MarvelDesignSystem
import UIKit

final class HeroesCatalogViewController: UIViewController {
    private enum Metrics {
        static let barHeight: CGFloat = 50
        static let controlHeight: CGFloat = 40
        static let minimumTouchTarget: CGFloat = 44
    }

    // MARK: - UI

    let heroesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: GridFlowLayout())
    let layoutButton = UIButton(type: .system)
    let headerLabel = UILabel()
    let segmentedControl = UISegmentedControl(items: [Localizable.Catalog.characters, Localizable.Catalog.favorites])
    private let headerView = UIView()
    private let footerView = UIView()
    private let refreshControl = UIRefreshControl()

    // MARK: - Dependencies

    let viewModel: HeroesCatalogViewModel
    var onSelectCharacter: ((Character) -> Void)?
    var isGridLayout = true

    // MARK: - Initialization

    init(viewModel: HeroesCatalogViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { nil }

    // MARK: - Lifecycle

    override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureHeaderView()
        configureCollectionView()
        configureFooterView()
        configureHierarchy()
        configureConstraints()
        bindViewModel()
        updateLayout()
        viewModel.loadInitial()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reloadFavorites()
    }

    // MARK: - Configuration

    private func configureView() {
        view.backgroundColor = DesignSystem.Color.accent
    }

    private func configureHeaderView() {
        headerView.backgroundColor = DesignSystem.Color.accent

        headerLabel.font = DesignSystem.Typography.title
        headerLabel.textColor = DesignSystem.Color.onAccent
        headerLabel.text = Localizable.Catalog.characters
        headerLabel.textAlignment = .center

        layoutButton.tintColor = DesignSystem.Color.onAccent
        layoutButton.addTarget(self, action: #selector(didTapLayout), for: .touchUpInside)
    }

    private func configureCollectionView() {
        heroesCollectionView.backgroundColor = DesignSystem.Color.backgroundPrimary
        heroesCollectionView.dataSource = self
        heroesCollectionView.delegate = self
        heroesCollectionView.register(
            HeroesCollectionViewCell.self,
            forCellWithReuseIdentifier: HeroesCollectionViewCell.reuseIdentifier
        )
        heroesCollectionView.register(
            HeroesCollectionListCell.self,
            forCellWithReuseIdentifier: HeroesCollectionListCell.reuseIdentifier
        )

        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        heroesCollectionView.refreshControl = refreshControl
    }

    private func configureFooterView() {
        footerView.backgroundColor = DesignSystem.Color.accent
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.selectedSegmentTintColor = DesignSystem.Color.surface
        segmentedControl.addTarget(self, action: #selector(didChangeCategory), for: .valueChanged)
    }

    private func configureHierarchy() {
        [headerView, heroesCollectionView, footerView, layoutButton, headerLabel, segmentedControl].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        view.addSubview(headerView)
        view.addSubview(heroesCollectionView)
        view.addSubview(footerView)
        headerView.addSubview(layoutButton)
        headerView.addSubview(headerLabel)
        footerView.addSubview(segmentedControl)
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: Metrics.barHeight),

            layoutButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: DesignSystem.Spacing.medium),
            layoutButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            layoutButton.widthAnchor.constraint(equalToConstant: Metrics.minimumTouchTarget),
            layoutButton.heightAnchor.constraint(equalTo: layoutButton.widthAnchor),

            headerLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            headerLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            heroesCollectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            heroesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            heroesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            heroesCollectionView.bottomAnchor.constraint(equalTo: footerView.topAnchor),

            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: Metrics.barHeight),

            segmentedControl.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            segmentedControl.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
            segmentedControl.heightAnchor.constraint(equalToConstant: Metrics.controlHeight),
        ])
    }

    // MARK: - Binding

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            switch state {
            case .initialLoading:
                self.heroesCollectionView.backgroundView = nil
            case .refreshing, .loadingNextPage, .idle:
                break
            case .loaded:
                self.refreshControl.endRefreshing()
                self.heroesCollectionView.backgroundView = nil
                self.heroesCollectionView.reloadData()
            case .empty:
                self.refreshControl.endRefreshing()
                self.heroesCollectionView.reloadData()
                self.setEmptyBackground()
            case let .failed(message):
                self.refreshControl.endRefreshing()
                self.presentAlert(withTitle: Localizable.Common.error, message: message)
            }
        }
    }

    // MARK: - Rendering

    private func updateLayout() {
        layoutButton.setImage(UIImage(named: isGridLayout ? "list" : "grid"), for: .normal)
        let layout: UICollectionViewLayout = isGridLayout ? GridFlowLayout() : ListFlowLayout()
        heroesCollectionView.setCollectionViewLayout(layout, animated: true)
    }

    private func setEmptyBackground() {
        let imageName = segmentedControl.selectedSegmentIndex == 0 ? "emptyList" : "emptyFavorite"
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.contentMode = .scaleAspectFit
        heroesCollectionView.backgroundView = imageView
    }

    // MARK: - Actions

    @objc private func refresh() {
        viewModel.reload()
    }

    @objc private func didTapLayout() {
        isGridLayout.toggle()
        updateLayout()
    }

    @objc private func didChangeCategory() {
        let section: HeroesCatalogSection = segmentedControl.selectedSegmentIndex == 0 ? .characters : .favorites
        headerLabel.text = section == .characters ? Localizable.Catalog.characters : Localizable.Catalog.favorites
        viewModel.selectSection(section)
    }
}
