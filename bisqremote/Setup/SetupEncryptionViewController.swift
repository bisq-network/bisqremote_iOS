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

class SetupEncryptionViewController: UIViewController {

    @IBOutlet weak var encryptionKeyStatusImage: UIImageView!
    @IBOutlet weak var encryptionKeyStatusLabel: UILabel!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        #if targetEnvironment(simulator)
            // running in a simulator
            UserDefaults.standard.set("fake encryotion key", forKey: userDefaultSymmetricKey)
        #endif
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (UserDefaults.standard.string(forKey: userDefaultSymmetricKey) != nil) {
            nextButton.isEnabled = true
            encryptionKeyStatusImage.isHidden = false
            encryptionKeyStatusLabel.isHidden = false
        } else {
            nextButton.isEnabled = false
            encryptionKeyStatusImage.isHidden = true
            encryptionKeyStatusLabel.isHidden = true
        }
    }
    
    func webPagePressed(alert: UIAlertAction!) {
        if let url = NSURL(string: "https://en.wikipedia.org/wiki/Symmetric-key_algorithm"){
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func helpPressed(_ sender: Any) {
        let x = UIAlertController(title: "Encryption", message: "The notifications are encryped using symmetric encryption. The key is generated in the Bisq desktop app and you need to read it using the  QR code reader.", preferredStyle: .actionSheet)
        x.addAction(UIAlertAction(title: "about symmetric encryption", style: .default, handler: webPagePressed))
        x.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(x, animated: true) {}
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var title = "Decryption"
        if segue.identifier == "scanQRsegue" {
            // remove key before scanning a new one. If the scan fails, we want to have no key
            UserDefaults.standard.removeObject(forKey: userDefaultSymmetricKey)
            UserDefaults.standard.synchronize()
            title = "Cancel"
        }
        navigationItem.backBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
    }
    
}
