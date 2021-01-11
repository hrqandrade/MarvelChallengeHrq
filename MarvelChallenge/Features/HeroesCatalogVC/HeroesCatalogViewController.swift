//
//  ViewController.swift
//  MarvelChallenge
//
//  Created by Henrique Silva on 07/01/21.
//  Copyright © 2021 Henrique Silva. All rights reserved.
//

import UIKit

enum State {
    case realm
    case request
    case loading
}

class HeroesCatalogViewController: UIViewController {
    
    @IBOutlet weak var heroesCollectionView: UICollectionView!
    @IBOutlet weak var layoutButton: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    let loading: SimpleLoadingViewController = LoadingScreenManager.simpleLoading.viewController()
    lazy var managerRequest = RequestManager(delegate: self)
    lazy var managerRealm = RealmManager(delegate: self)
    var charactesResult: [Character] = []
    var charactersRealm: [CharacterRealm] = []
    var stateHeroes: State!
    var page = 0
    var lastItem = 0
    var refresher: UIRefreshControl!
    var isGridFlowLayoutUsed: Bool = true {
        didSet {
            self.updateButtonAppearance()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestHeroes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didChangeRequestHeroes()
    }
    
    @objc func loadData() {
        if charactesResult.count == 0 {
            self.heroesCollectionView.refreshControl?.beginRefreshing()
            self.managerRequest.getHeroes(page: 0)
        }
    }
    
    func stopRefresher() {
        DispatchQueue.main.async { self.heroesCollectionView.refreshControl?.endRefreshing()
            self.refresher?.endRefreshing()
            self.heroesCollectionView.backgroundView = nil
        }
    }
    
    func setupCollectionView() {
        self.stateHeroes = .loading
        heroesCollectionView.dataSource = self
        heroesCollectionView.delegate = self
        updateButtonAppearance()
    }
    
    func requestHeroes() {
        if charactesResult.isEmpty {
            self.present(self.loading, animated: true, completion: {
                self.managerRequest.getHeroes(page: self.page)
            })
        }
    }
    
    func didChangeRequestHeroes() {
        if MarvelSharedInstance.sharedInstance.needsReload && !charactesResult.isEmpty {
            MarvelSharedInstance.sharedInstance.needsReload = false
            self.reloadDataFromCollection()
        }
    }
    
    func inputPullRefresh() {
        self.refresher = UIRefreshControl()
        self.heroesCollectionView.alwaysBounceVertical = true
        self.refresher.tintColor = UIColor.white
        self.refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        self.heroesCollectionView.addSubview(refresher)
    }
    
    private func updateButtonAppearance() {
        layoutButton.setImage(UIImage(named: isGridFlowLayoutUsed ? "list" : "grid" ), for: .normal)
        let layout = isGridFlowLayoutUsed ? GridFlowLayout() : ListFlowLayout()
        UIView.animate(withDuration: 0.4) { () -> Void in
            self.heroesCollectionView.collectionViewLayout.invalidateLayout()
            self.heroesCollectionView.setCollectionViewLayout(layout, animated: true)
            self.reloadDataFromCollection()
        }
    }
    
    @IBAction func didTapLayout(_ sender: Any) {
        isGridFlowLayoutUsed = !isGridFlowLayoutUsed
    }
    
    func reloadDataFromCollection() {
        let indexSet = IndexSet(integer: 0)
        self.heroesCollectionView.reloadSections(indexSet)
    }
    
    func getHeroes() {
        self.charactersRealm = []
        self.managerRealm.getHeroes()
    }
    
    func setState(emptyList: Bool, needRemoveBg: Bool) {
        if needRemoveBg {
            self.heroesCollectionView.backgroundView = nil
            return
        }
        let bgImage = UIImageView()
        switch emptyList {
        case true: bgImage.image = UIImage(named: "emptyList")
        case false: bgImage.image = UIImage(named: "emptyFavorite")
        }
        bgImage.contentMode = .scaleToFill
        self.heroesCollectionView.backgroundView = bgImage
    }
    
    @IBAction func didChangeCategory(_ sender: Any) {
        self.setState(emptyList: true, needRemoveBg: true)
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            if charactesResult.isEmpty {
                self.setState(emptyList: true, needRemoveBg: false)
            }
            self.headerLabel.text = "Characters"
            self.stateHeroes = .request
        case 1:
            self.getHeroes()
            self.headerLabel.text = "Favorites"
        default:
            break
        }
        self.reloadDataFromCollection()
    }
}
