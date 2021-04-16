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
import MessageUI

class EmailViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var resendEmailButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        instructionsLabel.highlightedTextColor = UIColor.green
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func sendEmail() {
        if let phoneDescription = Phone.instance.pairingToken() {
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setSubject("Bisq Pairing token")
                mail.title = "Send mail to yourself"
                var messageBody = "Please open the Bisq desktop app on your computer and go to Account -> Notifications. Then copy this Pairing token into the field \"Pairing token\":\n\n"
                messageBody += phoneDescription+"\n\n"
                messageBody += "The Pairing token contains your encryption key (AES/CBC/NOPadding with initialization vector) which is used by Bisq to encrypt the notifications for you and a token from Apple that identifies this instance of the Bisq remote app."
                mail.setMessageBody(messageBody, isHTML: false)
                present(mail, animated: true)
            } else {
                let alert = UIAlertController(title: "Error", message: "Unable to send email. The default mail app may not be configured.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Copy Token to Clipboard", style: .default, handler{ action in
                    UIPasteboard.general.string = phoneDescription
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                present(alert, animated: true)
            }
        }
    }
    
    @IBAction func emailButtonPressed(_ sender: Any) {
        if Phone.instance.confirmed {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "listScreen") as? NotificationTableViewController {
                self.navigationController?.setViewControllers([vc], animated: true)
            }
        } else {
            sendEmail()
        }
    }
}
