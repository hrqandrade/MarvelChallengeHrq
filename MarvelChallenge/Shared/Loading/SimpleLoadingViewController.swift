//
//  SimpleLoadingViewController.swift
//  MarvelChallenge
//
//  Created by Henrique Silva on 10/01/21.
//  Copyright © 2021 Henrique Silva. All rights reserved.
//

import UIKit
import MarvelDesignSystem

class SimpleLoadingViewController: UIViewController {
    @IBOutlet weak var loadingTitleLabel: UILabel!
    @IBOutlet weak var loadingDescriptionLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var loadingTitle: String = Localizable.Loading.title
    var loadingDescription: String = Localizable.Loading.description
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingTitleLabel.text = loadingTitle
        loadingDescriptionLabel.text = loadingDescription
        loadingTitleLabel.font = DesignSystem.Typography.headline
        loadingDescriptionLabel.font = DesignSystem.Typography.caption
        loadingTitleLabel.textColor = DesignSystem.Color.textPrimary
        loadingDescriptionLabel.textColor = DesignSystem.Color.textSecondary
        activityIndicatorView.color = DesignSystem.Color.accent
    }
}
