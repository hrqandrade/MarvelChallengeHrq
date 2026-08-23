//
//  LoadingScreenManager.swift
//  MarvelChallenge
//
//  Created by Henrique Silva on 10/01/21.
//  Copyright © 2021 Henrique Silva. All rights reserved.
//

import UIKit

enum LoadingScreenManager {
    case simpleLoading

    var nibName: String {
        switch self {
        case .simpleLoading:
            return "SimpleLoadingViewController"
        }
    }

    func viewController <T> () -> T {

        return _viewController as! T //swiftlint:disable:this force_cast
    }

    private var _viewController: UIViewController {
        switch self {
        case .simpleLoading:
            let vc = SimpleLoadingViewController(nibName: nibName, bundle: nil)
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            return vc
        }
    }
}
