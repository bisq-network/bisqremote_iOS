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
import CryptoSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window?.tintColor = UIColor(red: 37.0/255.0, green: 177.0/255.0, blue: 53.0/255.0, alpha: 1.0)
        
        // Setup needed?
        if !UserDefaults.standard.bool(forKey: userDefaultKeySetupDone) {
            registerForPushNotifications()
        }
        return true
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("iOS Notification: permission granted: \(granted)")
            
            guard granted else {
                if (error != nil) {
                    print("iOS Notification: permission not granted: \(error.debugDescription)")
                }
                return
            }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Setup completed
        let token = deviceToken.hexDescription
        
        // create a new key and save the phone persistently
        _ = Phone(token: token)
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }

//        // Check if launched from a notification
//        if let message = launchOptions?[.remoteNotification] as? [String: AnyObject] {
//            var success: String?
//            if let temp = message["bisqNotification"] as? String {
//                success = temp
//                if success != nil {
//                    print("json: "+success!)
//                }
//            }
//            if let encrypted = message["encrypted"] as? String {
//                let x = encrypted.split(separator: " ")
//                assert (x.count == 3)
//                assert (x[0] == BISQ_MESSAGE_MAGIC)
//                assert (x[1].count == 16)
//                CryptoHelper.iv = String(x[1])
//                if let s = UserDefaults.standard.string(forKey: userDefaultSymmetricKey) {
//                    CryptoHelper.key = s
//                } else {
//                    CryptoHelper.key = ""
//                }
//                let enc = String(x[2])
//                success = CryptoHelper.decrypt(input:enc)!;
//                if success != nil {
//                    print("decrypted json: "+success!)
//                }
//            }
//            if success != nil {
//                NotificationArray.shared.addFromString(new: success!)
//                let navigationController = application.windows[0].rootViewController as! UINavigationController
//                if let topController = navigationController.topViewController {
//                    if let vc = topController as? NotificationTableViewController {
//                        vc.reload()
//                    }
//                }
//            }
//        }
//
//        if UserDefaults.standard.bool(forKey: userDefaultKeySetupDone) {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let vc = storyboard.instantiateViewController(withIdentifier: "listScreen") as! NotificationTableViewController
//            let navigationController = application.windows[0].rootViewController as! UINavigationController
//            navigationController.setViewControllers([vc], animated: false)
//        }
//        return true
//    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
//        if application.applicationState == .active {
//            print ("active")
//        } else if application.applicationState == .background {
//            print ("background")
//        } else if application.applicationState == .inactive {
//            print ("inactive")
//        } else{
//            print ("message received in undefined strange state")
//        }
//        
//        if let message = userInfo as? [String: AnyObject] {
//            var success: String?
//            if let temp = message["bisqNotification"] as? String {
//                success = temp
//                if success != nil {
//                    print("json: "+success!)
//                }
//            }
//            if let encrypted = message["encrypted"] as? String {
//                let x = encrypted.split(separator: " ")
//                guard x.count == 3               else { return }
//                guard x[0] == BISQ_MESSAGE_MAGIC else { return }
//                guard x[1].count == 16           else { return }
//                CryptoHelper.iv = String(x[1])
//                if let s = UserDefaults.standard.string(forKey: userDefaultSymmetricKey) {
//                    CryptoHelper.key = s
//                } else {
//                    CryptoHelper.key = ""
//                }
//                let enc = String(x[2])
//                success = CryptoHelper.decrypt(input:enc)!;
//                if success != nil {
//                    print("decrypted json: "+success!)
//                }
//            }
//            if success != nil {
//                NotificationArray.shared.addFromString(new: success!)
//                let navigationController = application.windows[0].rootViewController as! UINavigationController
//                if let topController = navigationController.topViewController {
//                    if let vc = topController as? NotificationTableViewController {
//                        vc.reload()
//                    }
//                }
//            }
//        }
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

//    func registerForPushNotifications() {
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
//            (granted, error) in
//            print("iOS Notification: permission granted: \(granted)")
//
//            guard granted else {
//                if (error != nil) {
//                    print("iOS Notification: permission not granted: \(error.debugDescription)")
//                }
//                return
//            }
//            self.getNotificationSettings()
//        }
//    }
//

    

//    func getTokenAndKey() {
//        if let phone = UserDefaults.standard.string(forKey: userDefaultKeyPhone) {
//            let phoneArray = phone.split(separator: " ")
//            assert (phoneArray.count == 3)
//            assert (phoneArray[0] == PHONE_MAGIC)
//            assert (phoneArray[1].count == 16)
//            assert (phoneArray[2].count == 32)
//            CryptoHelper.key = String(phoneArray[1])
//        }
//        if let s = UserDefaults.standard.string(forKey: userDefaultSymmetricKey) {
//            CryptoHelper.key = s
//        } else {
//            CryptoHelper.key = ""
//        }
//
//        CryptoHelper.key = "dfgdfgdf"
//        let apsToken = Base58.base58FromBytes([UInt8](deviceToken))
//        print("as    Hex: "+deviceToken.hexDescription)
//
//        UserDefaults.standard.set(apsToken, forKey: userDefaultApsToken)
//        print("as Base58: \(apsToken)")
//        print("\n### Example notification:\n")
//        print(NotificationArray.exampleAPS())
//    }
    
    
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

