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

class SettingsViewController: UIViewController {

    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var tokenLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var platformLabel: UILabel!
    @IBOutlet weak var addNotificationButton: UIButton!
    @IBOutlet weak var markAllAsReadButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch (Config.appConfiguration) {
        case .Debug:
            markAllAsReadButton.isHidden = false
            addNotificationButton.isHidden = false
        case .TestFlight:
            markAllAsReadButton.isHidden = false
            addNotificationButton.isHidden = false
        case .AppStore:
            markAllAsReadButton.isHidden = true
            addNotificationButton.isHidden = true
        }
        updateFooter()
    }
    
    func updateFooter() {
        var s = ""
        if let k = Phone.instance.key {
            s = k.prefix(10)+"..."
        }
        keyLabel.text   = "key   "+s

        s = ""
        if let t = Phone.instance.token {
            s = t.prefix(10)+"..."
        }
        tokenLabel.text = "token "+s
        
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
    static var typeIndex = 0
    @IBAction func addNotificationPressed(_ sender: Any) {
        let new = Notification(raw: NotificationArray.exampleRawNotification())
        if (SettingsViewController.typeIndex % 5) == 0 {
            new.type = "TRADE"
            new.title = "(example) Trade confirmed"
            new.message = "The trade with ID 38765384 is confirmed."
        }
        if (SettingsViewController.typeIndex % 5) == 1 {
            new.type = "OFFER"
            new.title = "(example) Offer taken"
            new.message = "Your offer with ID 39847534 was taken"
        }
        if (SettingsViewController.typeIndex % 5) == 2 {
            new.type = "DISPUTE"
            new.title = "(example) Dispute message"
            new.actionRequired = "Please contact the arbitrator"
            new.message = "You received a dispute message for trade with ID 34059340"
        }
        if (SettingsViewController.typeIndex % 5) == 3 {
            new.type = "PRICE"
            new.title = "(example) Price below 5000 Euro"
            new.message = "Your price alert got triggered. The current Euro price is below 5000"
        }
        if (SettingsViewController.typeIndex % 5) == 4 {
            new.type = "MARKET"
            new.title = "(example) New offer"
            new.message = "A new offer offer with price 5600 Euro (5% below market price) and payment method SEPA was published to the Bisq offerbook.\nThe offer ID is 34534"
        }
        SettingsViewController.typeIndex += 1
        NotificationArray.shared.addNotification(new: new)
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
        if let url = NSURL(string: "https://bisq.network"){
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func aboutMobileNotificationsPressed(_ sender: Any) {
        if let url = NSURL(string: "https://bisq.network/mobile-notifications"){
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
}
