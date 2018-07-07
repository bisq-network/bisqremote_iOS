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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    @IBAction func emailButtonPressed(_ sender: Any) {
        let phone = Phone()
        if let phoneDescription = phone.description() {
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setSubject("Register your phone with Bisq")
                
                var messageBody = "Please copy this Bisq Phone ID string into the field \"Bisq Phone ID\" in the Bisq App:\n\n"
                messageBody += phoneDescription+"\n\n"
                messageBody += "The Bisq Phone ID contains (1) your excryption key (AES/CBC/NOPadding with initialization vector) which is used by Bisq to encrypt the notifications for you and (2) a token from Apple that identifies this instance of the Bisq remote app."
                mail.setMessageBody(messageBody, isHTML: false)
                present(mail, animated: true)
            }
        } else {
        }
    }
}
