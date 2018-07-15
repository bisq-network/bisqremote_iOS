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
    
//    func delay(_ delay:Double, closure:@escaping ()->()) {
//        let when = DispatchTime.now() + delay
//        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        update()
        instructionsLabel.highlightedTextColor = UIColor.green
    }
    
    func confirmed() {
        update()
    }

    func update() {
        if Phone.instance.confirmed {
            instructionsLabel.text = "Congratulations, you are all set."
            instructionsLabel.textAlignment = .center
            instructionsLabel.isHidden = false
            resendEmailButton.setTitle("SHOW NOTIFICATIONS", for: .normal)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func sendEmail() {
        if let phoneDescription = Phone.instance.phoneID() {
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setSubject("Bisq Phone ID")
                mail.title = "Send mail to yourself"
                var messageBody = "Please copy this Bisq Phone ID string into the field \"Bisq Phone ID\" in the Bisq App:\n\n"
                messageBody += phoneDescription+"\n\n"
                messageBody += "The Bisq Phone ID contains (1) your excryption key (AES/CBC/NOPadding with initialization vector) which is used by Bisq to encrypt the notifications for you and (2) a token from Apple that identifies this instance of the Bisq remote app."
                mail.setMessageBody(messageBody, isHTML: false)
                present(mail, animated: true)
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
