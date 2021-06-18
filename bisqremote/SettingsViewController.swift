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

class SettingsViewController: UIViewController {

    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var tokenLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var platformLabel: UILabel!
    @IBOutlet weak var addNotificationsButton: UIButton!
    @IBOutlet weak var markAllAsReadButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch (Config.appConfiguration) {
            case .Debug:
                addNotificationsButton.isHidden = false
            case .TestFlight:
                addNotificationsButton.isHidden = true
            case .AppStore:
                addNotificationsButton.isHidden = true
        }
        updateFooter()
    }
    
    func updateFooter() {
        var s = ""
        if let k = Phone.instance.key {
            s = k.prefix(10)+"..."
        }
        keyLabel.text = "Key   "+s

        s = ""
        if let t = Phone.instance.token {
            s = t.prefix(10)+"..."
        }
        tokenLabel.text = "Token "+s
        
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        var configuration: String
        versionLabel.text = "Version \(version) (\(build))"
        switch (Config.appConfiguration) {
            case .Debug:
                configuration = ": Xcode "
            case .TestFlight:
                configuration = ": TestFlight "
            case .AppStore:
                configuration = ""
        }
        platformLabel.text = Phone.instance.descriptor+configuration
    }
    
    @IBAction func rerunSetupPressed(_ sender: Any) {
        NotificationArray.shared.deleteAll()
        Phone.instance.reset()
        updateFooter()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "welcomeScreen")
        navigationController?.setViewControllers([vc], animated: true)
    }

    @IBAction func addNotificationsPressed(_ sender: Any) {
        for n in 0...4 {
            let new = Notification(raw: NotificationArray.exampleRawNotification())
            if (n % 5) == 0 {
                new.type = "TRADE"
                new.title = "(example) Trade confirmed"
                new.message = "The trade with ID 38765384 is confirmed."
            }
            if (n % 5) == 1 {
                new.type = "OFFER"
                new.title = "(example) Offer taken"
                new.message = "Your offer with ID 39847534 was taken"
            }
            if (n % 5) == 2 {
                new.type = "DISPUTE"
                new.title = "(example) Dispute message"
                new.actionRequired = "Please contact the arbitrator"
                new.message = "You received a dispute message for trade with ID 34059340"
            }
            if (n % 5) == 3 {
                new.type = "PRICE"
                new.title = "(example) Price below 5000 Euro"
                new.message = "Your price alert got triggered. The current Euro price is below 5000"
            }
            if (n % 5) == 4 {
                new.type = "MARKET"
                new.title = "(example) New offer"
                new.message = "A new offer offer with price 5600 Euro (5% below market price) and payment method SEPA was published to the Bisq offerbook.\nThe offer ID is 34534"
            }
            NotificationArray.shared.addNotification(new: new)
        }
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func markAllAsReadPressed(_ sender: Any) {
        NotificationArray.shared.markAllAsRead()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteAllPressed(_ sender: Any) {
        NotificationArray.shared.deleteAll()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func aboutBisqPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Warning", message: "This will load https://bisq.network. Do you want to proceed?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {_ in
            if let url = NSURL(string: "https://bisq.network"){
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {_ in
            
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func aboutMobileNotificationsPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Warning", message: "This will load https://bisq.network/mobile-notifications. Do you want to proceed?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {_ in
            if let url = NSURL(string: "https://bisq.network/mobile-notifications"){
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {_ in
            
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
