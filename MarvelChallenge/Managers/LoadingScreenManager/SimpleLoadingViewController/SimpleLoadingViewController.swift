//
//  SimpleLoadingViewController.swift
//  MarvelChallenge
//
//  Created by Henrique Silva on 10/01/21.
//  Copyright © 2021 Henrique Silva. All rights reserved.
//

import UIKit

class SimpleLoadingViewController: UIViewController {
    @IBOutlet weak var loadingTitleLabel: UILabel!
    @IBOutlet weak var loadingDescriptionLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var loadingTitle: String = "Please wait…"
    var loadingDescription: String = "Hi, soon everything will be ready ;)"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingTitleLabel.text = loadingTitle
        loadingDescriptionLabel.text = loadingDescription
    }
}
