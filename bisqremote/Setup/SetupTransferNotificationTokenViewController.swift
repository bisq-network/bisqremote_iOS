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

class SetupTransferNotificationTokenViewController: UIViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var qrImage: UIImageView!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var selectMethodControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let phone = Phone()
        if let d = phone.description() {
            qrImage.contentMode = .scaleAspectFit
            qrImage.image = generateQRCode(from: d)
        }
        setMethod(index: 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                let i = UIImage(ciImage: output)
                return i
            }
        }
        
        return nil
    }
    
    func setMethod(index: Int) {
        switch index {
        case 0:
            instructionLabel.text = "Press \"Use Webcam\" in Bisq"
            qrImage.isHidden = false
            emailButton.isHidden = true
        case 1:
            instructionLabel.text = "Email to yourself with instructions"
            qrImage.isHidden = true
            emailButton.isHidden = false
        default:
            fatalError("wrong segmentIndex")
        }
    }
    @IBAction func methodChanged(_ method: UISegmentedControl) {
        setMethod(index: method.selectedSegmentIndex)
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
                messageBody += "The Bisq phone ID string contains a token from Apple that identifies this instance of the Bisq remote app. The string also contains an excryption key (AES/CBC/NOPadding with initialization vector) which is used on the computer to encrypt the content of the notification."
                mail.setMessageBody(messageBody, isHTML: false)
                present(mail, animated: true)
            }
        } else {
            
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: userDefaultKeySetupDone)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "listScreen") as! NotificationTableViewController
        navigationController?.setViewControllers([vc], animated: true)
    }
    
//    func webPagePressed(alert: UIAlertAction!) {
//        if let url = NSURL(string: "https://developer.apple.com/documentation/usernotifications/registering_your_app_with_apns"){
//            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
//        }
//    }
    
//    @IBAction func helpPressed(_ sender: Any) {
//        let x = UIAlertController(title: "Register your phone", message: "If you register your phone with the Bisq desktop app, you will be able to receive iOS push notifications. The content of the notifications are encrypted by Bisq.", preferredStyle: .actionSheet)
////        x.addAction(UIAlertAction(title: "About the Apple Notification Token", style: .default, handler: webPagePressed))
//        x.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        self.present(x, animated: true) {}
//    }
    
}
