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
import UserNotifications

class WelcomViewController: UIViewController {

    @IBOutlet weak var registerButton: UIButton!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusLabel.isHidden = false

        registerButton.isEnabled = false
        
        #if targetEnvironment(simulator)
        registerButton.isEnabled = true
        #endif
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(checkForToken),
                                               name: NSNotification.Name.UIApplicationWillEnterForeground,
                                               object: nil)
        
        // Token needed?
        if UserDefaults.standard.string(forKey: userDefaultKeyToken) == nil {
            registerForPushNotifications()
        }
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("iOS Notification: permission granted: \(granted)")
            
            guard granted else {
                if error != nil {
                    print("iOS Notification: permission not granted: \(error.debugDescription)")
                }
                return
            }
            
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                print("Notification settings: \(settings)")
                guard settings.authorizationStatus == .authorized else { return }
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.backgroundColor = view.backgroundColor
        
        #if !targetEnvironment(simulator)
        if UserDefaults.standard.string(forKey: userDefaultKeyToken) == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
                self.checkForToken()
            })
        } else {
            self.registerButton.isEnabled = true
            self.statusLabel.isHidden = true
        }
        #endif

    }

    @objc func checkForToken() {
        if UserDefaults.standard.string(forKey: userDefaultKeyToken) == nil {
            UIApplication.shared.registerForRemoteNotifications()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.registerButton.isEnabled = false
                self.statusLabel.isHidden = false
                let x = UIAlertController(title: "Error", message: "Could not fetch the Apple notification token. Make sure you are connected to the internet.", preferredStyle: .actionSheet)
                x.addAction(UIAlertAction(title: "Try again", style: .default, handler: self.retry))
                x.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                self.present(x, animated: true) {}
            })
        } else {
            self.registerButton.isEnabled = true
            self.statusLabel.isHidden = true
        }
    }

    func retry(alert: UIAlertAction!) {
        checkForToken()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func bisqWebPagePressed(alert: UIAlertAction!) {
        if let url = NSURL(string: "https://bisq.network"){
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }

    func bisqMobileWebPagePressed(alert: UIAlertAction!) {
        if let url = NSURL(string: "https://bisq.network/bisqmobile"){
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }

    @IBAction func helpPressed(_ sender: Any) {
        let x = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        x.addAction(UIAlertAction(title: "About Bisq", style: .default, handler: bisqWebPagePressed))
        x.addAction(UIAlertAction(title: "About Bisq mobile", style: .default, handler: bisqMobileWebPagePressed))
        x.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(x, animated: true) {}
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}
