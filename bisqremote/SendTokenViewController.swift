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
import MessageUI

class SendTokenViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var instructionsLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        instructionsLabel.highlightedTextColor = UIColor.green
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        #if targetEnvironment(simulator)
        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: {
            UserDefaults.standard.set(Phone.instance.pairingToken(), forKey: userDefaultKeyPairingToken)
            UserDefaults.standard.synchronize()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "congratulationsScreen")
            self.navigationController?.setViewControllers([vc], animated: true)
        })
        #endif
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        if let phoneDescription = Phone.instance.pairingToken() {
            let text = phoneDescription
            let textToShare = [ text ]
            let activityViewController = UIActivityViewController(activityItems: textToShare as [Any], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            activityViewController.excludedActivityTypes = [
                UIActivity.ActivityType.airDrop,
                UIActivity.ActivityType.postToFacebook,
                UIActivity.ActivityType.postToTwitter,
                UIActivity.ActivityType.addToReadingList,
                UIActivity.ActivityType.assignToContact
            ]
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
}
