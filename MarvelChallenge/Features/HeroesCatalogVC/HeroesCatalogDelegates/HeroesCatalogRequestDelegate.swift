//
//  HeroesCatalogRequestDelegate.swift
//  MarvelChallenge
//
//  Created by Henrique Silva on 11/01/21.
//  Copyright © 2021 Henrique Silva. All rights reserved.
//

import UIKit

extension HeroesCatalogViewController: RequestManagerDelegate {
    func handleSuccess(type: RequestSuccess) {
        switch type {
        case .success(results: let results):
            self.stopRefresher()
            self.charactesResult += results
            self.stateHeroes = .request
            DispatchQueue.main.async {
                self.loading.dismiss(animated: true, completion: nil)
                self.heroesCollectionView.reloadData()
                self.setState(emptyList: true, needRemoveBg: true)
            }
        }
    }
    
    func handleError(type: RequestError) {
        DispatchQueue.main.async {
            self.loading.dismiss(animated: true) {
                switch type {
                case .noConnection:
                    self.presentAlert(withTitle: "Network connection error", message: "Try again later")
                case .errorGetHeroes:
                    break
                case .emptyList:
                    self.setState(emptyList: true, needRemoveBg: false)
                }
                self.inputPullRefresh()
            }
        }
    }
}
