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
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var navigationController: UINavigationController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        navigationController = application.windows[0].rootViewController as? UINavigationController

        window?.tintColor = UIColor(red: 37.0/255.0, green: 177.0/255.0, blue: 53.0/255.0, alpha: 1.0)

        // Check if launched from a notification
        if let message = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            processNotification(app: application, n: message)
        }

        #if targetEnvironment(simulator)
        Phone.instance.key = "A4C595428CAA4C768F60AE7EBFF85852"
        Phone.instance.apsToken = "d45161df3d172837f1b83bb3e411d5a63120de6b435ff9235adb70d619d162a1"
        Phone.instance.confirmed = true
        #endif
        
        // No Setup needed? --> List of Notifications
        if UserDefaults.standard.string(forKey: userDefaultKeyPhoneID) != nil {
            let vc = storyboard.instantiateViewController(withIdentifier: "listScreen") as! NotificationTableViewController
            navigationController?.setViewControllers([vc], animated: false)
        }
        return true
    }
    
    func fetchToken() {
        
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        let token = deviceToken.hexDescription
        Phone.instance.newToken(token: token)
        if let welcomeVC = navigationController?.topViewController as? WelcomViewController {
            welcomeVC.checkForToken()
        }
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }


    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        processNotification(app: application, n: userInfo)
    }

    func processNotification(app: UIApplication, n: [AnyHashable : Any]) {

        if let message = n as? [String: AnyObject] {
            if let encrypted = message["encrypted"] as? String {
                let x = encrypted.split(separator: Character(BISQ_MESSAGE_SEPARATOR))
                guard x.count == 3                   else { return }
                guard x[0] == BISQ_MESSAGE_IOS_MAGIC else { return }
                let category = String(x[2])
                switch category {
                case BISQ_CONFIRMATION_MESSAGE:
                    AudioServicesPlaySystemSound(1007) // see https://github.com/TUNER88/iOSSystemSoundsLibrary
                    Phone.instance.confirmed = true
                    UserDefaults.standard.set(Phone.instance.description(), forKey: userDefaultKeyPhoneID) // only confirmed phones are stored
                    UserDefaults.standard.synchronize()
                    
                    if let visibleController = navigationController?.visibleViewController {
                        if let qr = visibleController as? QRViewController {
                            qr.confirmed()
                        }
                        if let email = visibleController as? EmailViewController {
                            email.confirmed()
                        }
                    }
                case BISQ_DELETE_MESSAGE:
                    Phone.instance.reset()
                    if let visibleController = navigationController?.visibleViewController {
                        if let vc = visibleController as? NotificationTableViewController {
                            vc.reload()
                        }
                        if let _ = visibleController as? NotificationDetailViewController {
                            navigationController?.popViewController(animated: true)
                        }
                    }
                default:
                    var success: String?
                    var ok = false
                    guard x[1].count == 16 else { return }
                    CryptoHelper.iv = String(x[1])
                    CryptoHelper.key  = Phone.instance.key
                    let enc = String(x[2])
                    success = CryptoHelper.decrypt(input:enc);
                    if success != nil {
                        print("decrypted json: "+success!)
                        ok = NotificationArray.shared.addFromString(new: success!)
                    }
                    if !ok {
                        NotificationArray.shared.addError(title: "Could not decrypt", message: "Sorry\n\nSomething went wrong when decrypting this notification. You could try to delete the app and install it again.")
                    }
                    let navigationController = app.windows[0].rootViewController as! UINavigationController
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
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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

