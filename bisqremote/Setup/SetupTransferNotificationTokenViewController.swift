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
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            if let temp = UserDefaults.standard.string(forKey: userDefaultApsToken) {
                qrImage.contentMode = .scaleAspectFill
                qrImage.image = generateQRCode(from: "BisqToken "+bundleIdentifier+" "+temp)
                qrImage.contentMode = .scaleAspectFill
            }
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
            instructionLabel.text = "Use the camera of your computer"
            qrImage.isHidden = false
            emailButton.isHidden = true
        case 1:
            instructionLabel.text = "Email to yourself, then copy&paste"
            qrImage.isHidden = true
            emailButton.isHidden = false
        case 2:
            instructionLabel.text = "Type this into the Bisq desktop app:"
            qrImage.isHidden = true
            emailButton.isHidden = true
        default:
            print("wrong segmentIndex")
        }
    }
    @IBAction func methodChanged(_ method: UISegmentedControl) {
        setMethod(index: method.selectedSegmentIndex)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    
    @IBAction func emailButtonPressed(_ sender: Any) {
        if let temp = UserDefaults.standard.string(forKey: userDefaultApsToken) {
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setSubject("Apple notification service token")
                mail.setMessageBody("Your Apple Notifications Token is:\n\n\(temp)", isHTML: false)
                present(mail, animated: true)
            }
        } else {
            // show failure alert
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: userDefaultKeySetupDone)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "listScreen") as! NotificationTableViewController
        navigationController?.setViewControllers([vc], animated: true)
    }
    
    func webPagePressed(alert: UIAlertAction!) {
        if let url = NSURL(string: "https://developer.apple.com/documentation/usernotifications/registering_your_app_with_apns"){
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func helpPressed(_ sender: Any) {
        let x = UIAlertController(title: "iOS Notification Service", message: "This app can receive iOS notifications from Apple, whihc are triggered by the Bisq desktop app. In order to identify your phone to the Bisq desktop app, the Bisq desktop app needs to know the notification token, which the mobile app has already received from the Apple Notification Service.", preferredStyle: .actionSheet)
        x.addAction(UIAlertAction(title: "About the Apple Notification Token", style: .default, handler: webPagePressed))
        x.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(x, animated: true) {}
    }
    
}
