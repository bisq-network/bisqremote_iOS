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
import os

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var navigationController: UINavigationController?
    var rawNotification: String?
    var applicationCanShowAlert: Bool = false
    var appIsStarting: Bool = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        registerSettingsBundle()
        rawNotification = nil

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        navigationController = application.windows[0].rootViewController as? UINavigationController

        window?.tintColor =  TINTCOLOR_GREEN

        // Check if launched from a notification
        if let message = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            if UserDefaults.standard.bool(forKey: "showRawNotifications") {
                let alert = UIAlertController(title: "Bisq notificaton", message: "message received while not in foreground", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil))
                self.window?.rootViewController?.present(alert, animated: true, completion: nil)
            }

            processNotification(application: application, n: message)
            ("launchOptions "+message.description).bisqLog()
        }

        #if targetEnvironment(simulator)
        Phone.instance.key = "A4C595428CAA4C768F60AE7EBFF85852"
        Phone.instance.token = "d45161df3d172837f1b83bb3e411d5a63120de6b435ff9235adb70d619d162a1"
        Phone.instance.confirmed = true
        let vc = storyboard.instantiateViewController(withIdentifier: "listScreen") as! NotificationTableViewController
        navigationController?.setViewControllers([vc], animated: false)
        #endif
        
        // No Setup needed? --> List of Notifications
        if UserDefaults.standard.string(forKey: userDefaultKeyPairingToken) != nil {
            let vc = storyboard.instantiateViewController(withIdentifier: "listScreen") as! NotificationTableViewController
            navigationController?.setViewControllers([vc], animated: false)
        }
        
        return true
    }
    
    func registerSettingsBundle(){
        let appDefaults = [String:AnyObject]()
        UserDefaults.standard.register(defaults: appDefaults)
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        if UserDefaults.standard.bool(forKey: "showRawNotifications") {
            let alert = UIAlertController(title: "Bisq notificaton", message: "Token received from Apple", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil))
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        let token = deviceToken.hexDescription
        Phone.instance.newToken(t: token)
        if let welcomeVC = navigationController?.topViewController as? WelcomViewController {
            welcomeVC.checkForToken()
        }
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        failedToRegisterAlert()
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if UserDefaults.standard.bool(forKey: "showRawNotifications") {
            let alert = UIAlertController(title: "Bisq notificaton", message: "message received in foreground", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil))
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }

        ("didReceiveRemoteNotification "+userInfo.description).bisqLog()
        processNotification(application: application, n: userInfo)

    }

    func receivedAlert(state: UIApplication.State) {
        var sateString = "unknown"
        if state == UIApplication.State.background {sateString = "background"}
        if state == UIApplication.State.inactive {sateString = "inactive"}
        if state == UIApplication.State.active {sateString = "active"}
        var b = "false"
        if appIsStarting {b = "true"}
        let m = "I have received something, state="+sateString+" appIsStarting="+b
        let alert = UIAlertController(title: "Notification", message: m, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func failedToRegisterAlert() {
        let alert = UIAlertController(title: "Registration failed", message: "Could not register with Apple Push notifications", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func rawNotificationAlert() {
        if UserDefaults.standard.bool(forKey: "showRawNotifications") {
            if rawNotification != nil {
                let paragraph = NSMutableParagraphStyle()
                paragraph.alignment = .left
                let attributedMessage = NSAttributedString(string: rawNotification!,
                                                           attributes: [.paragraphStyle: paragraph])
                let alert = UIAlertController(title: "raw notificaton", message: "", preferredStyle: UIAlertController.Style.alert)
                alert.setValue(attributedMessage, forKey: "attributedMessage")
                alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil))
                self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                rawNotification = nil
            }
        }
    }
    
    func processNotification(application: UIApplication, n: [AnyHashable : Any]) {
        "--> processNotification".bisqLog()
        let state = application.applicationState
        if state == UIApplication.State.background {"state background".bisqLog()}
        if state == UIApplication.State.inactive {"inactive".bisqLog()}
        if state == UIApplication.State.active {"active".bisqLog()}
        if appIsStarting {"appIsStarting = true".bisqLog()}
        if !appIsStarting {"appIsStarting = false".bisqLog()}

        rawNotification = n.description
        rawNotificationAlert()

        if state == UIApplication.State.inactive && appIsStarting {
            "--> processNotification RETURN".bisqLog()
            return
        }

        ("processNotification "+n.description).bisqLog()
        if let message = n as? [String: AnyObject] {
            if let encrypted = message["encrypted"] as? String {
                let x = encrypted.split(separator: Character(BISQ_MESSAGE_SEPARATOR))
                guard x.count == 3                   else { return }
                guard x[0] == BISQ_MESSAGE_IOS_MAGIC else { return }
                var success: String?
                guard x[1].count == 16 else { return }
                CryptoHelper.iv = String(x[1])
                if let k = Phone.instance.key {
                    CryptoHelper.key = k
                    let enc = String(x[2])
                    success = CryptoHelper.decrypt(input:enc);
                    if success != nil {
                        print("decrypted json: "+success!)
                        ("processNotification_decrypted "+success!).bisqLog()
                        NotificationArray.shared.addFromString(new: success!)
                    } else {
                        let alert = UIAlertController(title: "ERROR", message: "COULD NOT DECRYPT", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    }
                    let navigationController = application.windows[0].rootViewController as! UINavigationController
                    if let topController = navigationController.topViewController {
                        if let vc = topController as? NotificationTableViewController {
                            vc.reload()
                        }
                    }
                }
            }
        }
    }

    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        appIsStarting = false
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        appIsStarting = false
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        appIsStarting = true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        //This method is called when the rootViewController is set and the view.
        // And the View controller is ready to get touches or events.
        appIsStarting = false
        applicationCanShowAlert = true
        rawNotificationAlert()
    }


    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}

extension String {
    func bisqLog() {
//        let old = UserDefaults.standard.string(forKey: "logging")
//        let new: String
//        if let o = old {
//            new = o + "\n"+self
//        } else {
//            new = self
//        }
//        UserDefaults.standard.set(new, forKey: "logging")
    }
}

extension Data {
    var utf8String: String? {
        return string()
    }
    
    func string() -> String? {
        return String(data: self, encoding: .utf8)
    }
    
}
extension Data {
    var hexDescription: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
}

