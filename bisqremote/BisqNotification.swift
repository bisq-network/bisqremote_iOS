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

import Foundation
import UIKit // for setting the badge number
import AVFoundation // for sound

enum NotificationType: String {
    case SETUP_CONFIRMATION, ERASE, TRADE, DISPUTE, FINANCIAL, ERROR, PLACEHOLDER
}

// Datastructure as sent from the Bisq notification server
// This class does not have the variables timestampReceived and read.
// We need a class and custom encoder and decoder because we will inherit from this class
class RawNotification: Codable {
    var version: Int
    var notificationType: String
    var title: String
    var message: String
    var actionRequired: String
    var transactionID: String
    var timestampEvent: Date

    init() {
        version = 0
        notificationType = ""
        title = ""
        message = ""
        actionRequired = ""
        transactionID = ""
        timestampEvent = Date()
    }
    
    private enum CodingKeys: String, CodingKey {
        case version
        case notificationType
        case title
        case message
        case actionRequired
        case transactionID
        case timestampEvent
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decode(Int.self, forKey: .version)
        let t = try container.decode(String.self, forKey: .notificationType)

        let navigationController = UIApplication.shared.windows[0].rootViewController as? UINavigationController
        let visibleController = navigationController?.visibleViewController

        notificationType = t
        title = try container.decode(String.self, forKey: .title)
        message = try container.decode(String.self, forKey: .message)
        actionRequired = try container.decode(String.self, forKey: .actionRequired)
        transactionID = try container.decode(String.self, forKey: .transactionID)
        timestampEvent = try container.decode(Date.self, forKey: .timestampEvent)

        switch t {
        case NotificationType.SETUP_CONFIRMATION.rawValue:
            AudioServicesPlaySystemSound(1007) // see https://github.com/TUNER88/iOSSystemSoundsLibrary
            Phone.instance.confirmed = true
            
            // only confirmed phones are stored
            UserDefaults.standard.set(Phone.instance.phoneID(), forKey: userDefaultKeyPhoneID)
            UserDefaults.standard.synchronize()
            
            if let qr = visibleController as? QRViewController {
                qr.confirmed()
            }
            if let email = visibleController as? EmailViewController {
                email.confirmed()
            }
            break
        case NotificationType.ERASE.rawValue:
            Phone.instance.reset()
            if let vc = visibleController as? NotificationTableViewController {
                vc.reload()
            }
            if let _ = visibleController as? NotificationDetailViewController {
                navigationController?.popViewController(animated: true)
            }
            break
        case NotificationType.TRADE.rawValue,
             NotificationType.DISPUTE.rawValue,
             NotificationType.FINANCIAL.rawValue:
            break
        default:
            print("unknown notificationType \(t)")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(version, forKey: .version)
        try container.encode(notificationType, forKey: .notificationType)
        try container.encode(title, forKey: .title)
        try container.encode(message, forKey: .message)
        try container.encode(actionRequired, forKey: .actionRequired)
        try container.encode(transactionID, forKey: .transactionID)
        try container.encode(timestampEvent, forKey: .timestampEvent)
    }
}


// This class is stored persistently in the phone.
class Notification: RawNotification {
    var read: Bool
    let timestampReceived: Date

    private enum CodingKeys: String, CodingKey {
        case read
        case timestampReceived
    }
    
    override init() {
        read = false
        timestampReceived = Date()
        super.init()
    }
    
    convenience init(raw: RawNotification) {
        self.init()
        self.version = raw.version
        self.notificationType = raw.notificationType
        self.title = raw.title
        self.message = raw.message
        self.actionRequired = raw.actionRequired
        self.transactionID = raw.transactionID
        self.timestampEvent = raw.timestampEvent
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let superdecoder = try container.superDecoder()
        read = try container.decode(Bool.self, forKey: .read)
        timestampReceived = try container.decode(Date.self, forKey: .timestampReceived)
        try super.init(from: superdecoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(read, forKey: .read)
        try container.encode(timestampReceived, forKey: .timestampReceived)

        let superdecoder = container.superEncoder()
        try super.encode(to: superdecoder)
    }
}

// Singleton with the array of notifications
class NotificationArray {
    static let shared = NotificationArray()
    
    private let dateformatterLong = DateFormatter()
    private var array: [Notification] = [Notification]()
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private init() {
        // set date format to the javascript standard
        dateformatterLong.dateFormat = "yyyy-MM-dd HH:mm:ss"
        decoder.dateDecodingStrategy = .formatted(dateformatterLong)
        encoder.dateEncodingStrategy = .formatted(dateformatterLong)
        encoder.outputFormatting = .prettyPrinted
        load()
    }

    private struct APS : Codable {
        let alert: String
        let sound: String
        let bisqNotification: RawNotification
    }

    static func exampleAPS() -> String {
        // Normally, the badge number is managed on the server.
        // In our use case, the server (=bisq notification node) should have as
        // little knowledge as possible. Therefore, the badge is incremented
        // in the app and left out in the aps example
        // One drawback of thids approach is that the badge number is not
        // immediately updated when a notification arrives on the phone
        let aps = APS(
            alert: "Bisq Notification",
            sound: "default",
            bisqNotification: exampleRawNotification())
        let completeMessage = ["aps": aps]
        do {
            let jsonData = try NotificationArray.shared.encoder.encode(completeMessage)
            return String(data: jsonData, encoding: .utf8)!
        } catch {
            return("could not create example APS")
        }
    }

    static func exampleRawNotification() -> RawNotification {
        let r = RawNotification()
        r.version = 1
        r.notificationType = NotificationType.TRADE.rawValue
        r.title = "Added from Settings"
        r.message = "example message"
        r.actionRequired = "You need to make the bank transfer to receive your BTC"
        r.transactionID = "293842038402983"
        r.timestampEvent = Date()
        return r
    }
    
    func parseArray(json: String) {
        do {
            let data: Data? = json.data(using: .utf8)
            array = try decoder.decode([Notification].self, from: data!)
        } catch {
            array = [Notification]()
        }
    }

    func parse(json: String) -> Notification? {
        var ret: Notification?
        do {
            // add timestamp of reception
            let withReceptionTimestamp = json.replacingOccurrences(of: "}", with: ", \"timestampReceived\": \""+dateformatterLong.string(from: Date())+"\"}")
            let data: Data? = withReceptionTimestamp.data(using: .utf8)
            ret = try decoder.decode(Notification.self, from: data!)
        } catch {
            ret = nil
        }
        return ret
    }

    func save() {
        do {
            let jsonData = try encoder.encode(array)
            let toDefaults = String(data: jsonData, encoding: .utf8)!
            UserDefaults.standard.set(toDefaults, forKey: userDefaultKeyNotifications)
            UserDefaults.standard.synchronize()
            UIApplication.shared.applicationIconBadgeNumber = countUnread
        } catch {
            print("/n###/n### save failed/n###/n")
        }
    }
    
    private func load() {
        let fromDefaults = UserDefaults.standard.string(forKey: userDefaultKeyNotifications) ?? "[]"
        parseArray(json: fromDefaults)
        UIApplication.shared.applicationIconBadgeNumber = countUnread
    }
    
    var countAll: Int {
        return array.count
    }
    
    var countUnread: Int {
        var unread = 0
        for n in array {
            if !n.read { unread += 1 }
        }
        return unread
    }

    func at(n: Int) -> Notification {
        let x = array[n]
        return x
    }
    
    func addFromString(new: String) {
        // let test "{\"timestampEvent\" : \"2018-06-19 12:00:50\",\"transactionID\" : \"293842038402983\",\"title\" : \"example title\",\"message\" : \"example message\",\"notificationType\" : \"TRADE_ACCEPTED\",\"actionRequired\" : \"You need to make the bank transfer to receive your BTC\",\"version\" : 1}"
        if let data = new.data(using: .utf8) {
            do {
                let raw = try decoder.decode(RawNotification.self, from:data)
                if raw.version >= 1 {
                    switch raw.notificationType {
                    case NotificationType.SETUP_CONFIRMATION.rawValue,
                         NotificationType.ERASE.rawValue:
                        return // no need to add to array
                    default:
                        break
                    }
                    addNotification(new: Notification(raw: raw))
                }
            } catch {
                addError(title: "Could not decrypt", message: "Sorry\n\nSomething went wrong when decrypting this notification. You could try to delete the app and install it again.")
            }
        }
        return
    }

    func addError(title: String, message: String) {
        let raw = RawNotification()
        raw.title = title
        raw.notificationType = NotificationType.ERROR.rawValue
        raw.message = message
        addNotification(new: Notification(raw: raw))
    }
    
    func addFromJSON(new: AnyObject?) {
        if new != nil {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: new!)
                let raw = try decoder.decode(RawNotification.self, from: jsonData)
                if raw.version >= 1 {
                    addNotification(new: Notification(raw: raw))
                }
            } catch {
                print("could not add notification")
            }
        } else {
            print("missing object bisqNotification")
        }
    }

    func addNotification(new: Notification) {
        array.insert(new, at: 0)
        save()
    }
    
    func deleteAll() {
        array.removeAll()
        save()
    }
    
    func markAllAsRead() {
        for n in array {
            n.read = true
        }
    }
    
    func remove(n: Int) {
        array.remove(at: n)
        save()
    }
}

