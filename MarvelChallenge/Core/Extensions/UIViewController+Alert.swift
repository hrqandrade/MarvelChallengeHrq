import UIKit

extension UIViewController {
    func presentAlert(withTitle title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Localizable.Common.ok, style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}
