//
/*
 * This file is part of Bisq.
 *
 * Bisq is free software: you can redistribute it and/or modify it
 * under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or (at
 * your option) any later version.
 *
 * Bisq is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public
 * License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with Bisq. If not, see <http://www.gnu.org/licenses/>.
 */


import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.zPosition = 2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func helpPressed(_ sender: Any) {
        let x = UIAlertController(title: "If you register your phone with the Bisq desktop app, you are transferring (1) the Apple Notification Service Token and (2) an encryption key for the symmetric AES/CBC/NOPadding algorithm with initialization vector. The Bisq desktop app will use this key to encrypt the messaged for your phone", message: nil, preferredStyle: .actionSheet)
        x.addAction(UIAlertAction(title: "About the Apple Notification Token", style: .default, handler: webPageApplePressed))
        x.addAction(UIAlertAction(title: "About the Encryption", style: .default, handler: webPageEncryptionPressed))
        x.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(x, animated: true) {}
    }

    func webPageApplePressed(alert: UIAlertAction!) {
        if let url = NSURL(string: "https://developer.apple.com/documentation/usernotifications/registering_your_app_with_apns"){
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "emailSeque" {
            guard let emailViewController = segue.destination as? EmailViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            emailViewController.sendEmail()
        }
    }

    func webPageEncryptionPressed(alert: UIAlertAction!) {
        if let url = NSURL(string: "https://en.wikipedia.org/wiki/Block_cipher_mode_of_operation"){
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }

}
