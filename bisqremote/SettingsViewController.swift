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
        let phone = Phone()
        if let k = phone.key {
            keyLabel.text   = "key   "+k.prefix(8)+"..."
        } else {
            keyLabel.text   = "key   missing"
        }
        if let a = phone.apsToken {
            tokenLabel.text = "token "+a.prefix(8)+"..."
        } else {
            tokenLabel.text = "token missing"
        }
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        versionLabel.text = "Version \(version) build \(build)"
    }
    
    @IBAction func resetPressed(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: userDefaultKeySetupDone)
        UserDefaults.standard.removeObject(forKey: userDefaultKeyPhone)
        UserDefaults.standard.removeObject(forKey: userDefaultKeyNotifications)
        updateFooter()
    }
    
    @IBAction func rerunSetupPressed(_ sender: Any) {
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
    }
    @IBAction func deleteAllPressed(_ sender: Any) {
        NotificationArray.shared.deleteAll()
    }
}
