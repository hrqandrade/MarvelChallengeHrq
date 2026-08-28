import UIKit

final class HeroesCatalogViewController: UIViewController {
    private let contentView = HeroesCatalogView()
    let viewModel: HeroesCatalogViewModel
    var onSelectCharacter: ((Character) -> Void)?
    var isGridLayout = true
    private var selectedSection: HeroesCatalogSection = .characters
    private var hasRequestedInitialLoad = false

    var heroesCollectionView: UICollectionView {
        contentView.collectionView
    }

    init(viewModel: HeroesCatalogViewModel) {
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
        heroesCollectionView.dataSource = self
        heroesCollectionView.delegate = self
        bindViewActions()
        bindViewModel()
        contentView.renderLayout(isGrid: isGridLayout, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasRequestedInitialLoad else { return }
        hasRequestedInitialLoad = true
        viewModel.loadInitial()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reloadFavorites()
    }

    private func bindViewActions() {
        contentView.onRefresh = { [weak self] in self?.viewModel.reload() }
        contentView.onLayoutChange = { [weak self] in
            guard let self else { return }
            self.isGridLayout.toggle()
            self.contentView.renderLayout(isGrid: self.isGridLayout, animated: true)
        }
        contentView.onSectionChange = { [weak self] section in
            self?.selectedSection = section
            self?.viewModel.selectSection(section)
        }
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            switch state {
            case .initialLoading:
                self.contentView.renderLoading()
            case .refreshing, .loadingNextPage, .idle:
                break
            case .loaded:
                self.contentView.renderLoaded()
            case .empty:
                self.contentView.renderEmpty(section: self.selectedSection)
            case let .failed(message):
                self.contentView.endRefreshing()
                self.presentAlert(withTitle: Localizable.Common.error, message: message)
            }
        }
    }
}
