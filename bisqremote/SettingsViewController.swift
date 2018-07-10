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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateFooter()
    }
    
    func updateFooter() {
        keyLabel.text   = "key   "+Phone.instance.key.prefix(8)+"..."
        tokenLabel.text = "token "+Phone.instance.apsToken.prefix(8)+"..."
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        var configuration: String
        switch (Config.appConfiguration) {
        case .Debug:
            configuration = " (from Xcode)"
        case .TestFlight:
            configuration = " (TestFlight)"
        case .AppStore:
            configuration = ""
        }
        versionLabel.text = "Version \(version) build \(build)"+configuration
    }
    
    @IBAction func rerunSetupPressed(_ sender: Any) {
        NotificationArray.shared.deleteAll()
        Phone.instance.reset()
        updateFooter()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "welcomeScreen")
        navigationController?.setViewControllers([vc], animated: true)
    }
    
    @IBAction func addNotificationPressed(_ sender: Any) {
        let x = Notification(raw: NotificationArray.exampleRawNotification())
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
