//
//  Extensions.swift
//  MarvelChallenge
//
//  Created by Henrique Silva on 07/01/21.
//  Copyright © 2021 Henrique Silva. All rights reserved.
//

import UIKit
extension UIViewController {

  func presentAlert(withTitle title: String, message : String) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let OKAction = UIAlertAction(title: Localizable.Common.ok, style: .default)
    alertController.addAction(OKAction)
    self.present(alertController, animated: true, completion: nil)
  }
}
