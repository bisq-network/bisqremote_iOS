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
    @IBOutlet weak var addNotificationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        #if targetEnvironment(simulator)
        #else
            addNotificationButton.isHidden = true
        #endif
        updateFooter()
    }
    
    func updateFooter() {
        var s = ""
        if let k = Phone.instance.key {
            s = k.prefix(8)+"..."
        }
        keyLabel.text   = "key   "+s

        s = ""
        if let t = Phone.instance.token {
            s = t.prefix(8)+"..."
        }
        tokenLabel.text = "token "+s
        
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        var configuration: String
        switch (Config.appConfiguration) {
        case .Debug:
            configuration = "Xcode "
        case .TestFlight:
            configuration = "TestFlight "
        case .AppStore:
            configuration = ""
        }
        versionLabel.text = "Version \(version) (\(build)) \(configuration+Phone.instance.descriptor)"
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
        let x = Notification(raw: NotificationArray.exampleRawNotification())
        if (SettingsViewController.typeIndex % 5) == 0 {
            x.type = "TRADE"
            x.title = "Trade confirmed"
            x.message = "The trade with ID 38765384 is confirmed."
        }
        if (SettingsViewController.typeIndex % 5) == 1 {
            x.type = "OFFER"
            x.title = "Offer taken"
            x.message = "Your offer with ID 39847534 was taken"
        }
        if (SettingsViewController.typeIndex % 5) == 2 {
            x.type = "DISPUTE"
            x.title = "Dispute message"
            x.message = "You received a dispute message for trade with ID 34059340"
        }
        if (SettingsViewController.typeIndex % 5) == 3 {
            x.type = "PRICE"
            x.title = "Price below 5000 Euro"
            x.message = "Your price alert got triggered. The current Euro price is below 5000"
        }
        if (SettingsViewController.typeIndex % 5) == 4 {
            x.type = "MARKET"
            x.title = "New offer"
            x.message = "A new offer offer with price 5600 Euro (5% below market price) and payment method SEPA was published to the Bisq offerbook.\nThe offer ID is 34534"
        }
        SettingsViewController.typeIndex += 1
        NotificationArray.shared.addNotification(new: x)
    }
    
    @IBAction func markAllAsReadPressed(_ sender: Any) {
        NotificationArray.shared.markAllAsRead()
        navigationController?.popViewController(animated: true)
    }
    @IBAction func deleteAllPressed(_ sender: Any) {
        NotificationArray.shared.deleteAll()
        navigationController?.popViewController(animated: true)
    }
}
