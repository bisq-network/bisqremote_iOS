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
import UIKit
import Device

class Phone {
    
    static var instance = Phone()
    var descriptor: String?
    var key: String?
    var token: String?
    var confirmed = false // confirmation-notification received?
    
    func pairingToken() -> String? {
        guard key != nil else { return ""}
        guard token != nil else { return ""}
        guard descriptor != nil else { return "" }
        return Phone.magic()+BISQ_MESSAGE_SEPARATOR+descriptor!+BISQ_MESSAGE_SEPARATOR+key!+BISQ_MESSAGE_SEPARATOR+token!
    }
    
    private init() {
        descriptor = UIDevice.current.deviceType.rawValue
        key = nil
        token = nil
        confirmed = false

        // try reading from UserDefaults
        if let s = UserDefaults.standard.string(forKey: userDefaultKeyPairingToken) {
            let a = s.split(separator: Character(BISQ_MESSAGE_SEPARATOR))
            guard a.count == 3 else { return }
            guard a[0] == Phone.magic() else { return }
            guard a[2].count == 32 else { return }
            guard a[3].count == 64 else { return }
            descriptor = String(a[1])
            key = String(a[2])
            token = String(a[3])
            confirmed = true // only confirmed pairing token is saved into UserDefaults
        }
    }
    
    func newToken(t: String) {
        token = t
        key = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        confirmed = false
    }
    
    
    func reset() {
        UserDefaults.standard.removeObject(forKey: userDefaultKeyPairingToken)
        UserDefaults.standard.removeObject(forKey: userDefaultKeyNotifications)
        NotificationArray.shared.deleteAll()
        key = ""
        token = ""
        confirmed = false
    }
    
    static func magic() -> String {
        switch (Config.appConfiguration) {
        case .Debug:
            return PAIRING_MAGIC_IOS_DEV
        case .TestFlight:
            return PAIRING_MAGIC_IOS
        case .AppStore:
            return PAIRING_MAGIC_IOS
        }
    }
    
}
