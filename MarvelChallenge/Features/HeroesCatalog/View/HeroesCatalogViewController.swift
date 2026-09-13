import UIKit

final class HeroesCatalogViewController: UIViewController {
    private let contentView = HeroesCatalogView()
    let viewModel: HeroesCatalogViewModel
    var onSelectCharacter: ((Character) -> Void)?
    var isGridLayout = true
    private var prefersGridLayout = true
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
        applyPreferredLayout(animated: false)
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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard previousTraitCollection?.preferredContentSizeCategory.isAccessibilityCategory
            != traitCollection.preferredContentSizeCategory.isAccessibilityCategory else { return }
        applyPreferredLayout(animated: false)
    }

    private func bindViewActions() {
        contentView.onRefresh = { [weak self] in self?.viewModel.reload() }
        contentView.onRetry = { [weak self] in
            guard let self else { return }
            if self.selectedSection == .favorites {
                self.viewModel.reloadFavorites()
            } else {
                self.viewModel.reload()
            }
        }
        contentView.onLayoutChange = { [weak self] in
            guard let self else { return }
            self.prefersGridLayout.toggle()
            self.applyPreferredLayout(animated: true)
        }
        contentView.onSectionChange = { [weak self] section in
            self?.selectedSection = section
            self?.viewModel.selectSection(section)
        }
    }

    private func applyPreferredLayout(animated: Bool) {
        let usesAccessibilityLayout = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        isGridLayout = prefersGridLayout && !usesAccessibilityLayout
        contentView.renderLayoutControl(isHidden: usesAccessibilityLayout)
        contentView.renderLayout(isGrid: isGridLayout, animated: animated)
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            switch state {
            case .initialLoading:
                self.contentView.renderLoading()
            case .refreshing:
                self.contentView.renderRefreshing()
            case .loadingNextPage:
                self.contentView.renderLoadingNextPage()
            case .idle:
                break
            case .loaded:
                self.contentView.renderLoaded()
            case .empty:
                self.contentView.renderEmpty(section: self.selectedSection)
            case let .failed(message):
                self.contentView.renderError(message: message)
            }
        }
        viewModel.onFeedback = { [weak self] feedback in
            switch feedback {
            case let .success(message):
                self?.contentView.showFeedback(message: message, isError: false)
            case let .error(message):
                self?.contentView.showFeedback(message: message, isError: true)
            }
        }
    }
}
