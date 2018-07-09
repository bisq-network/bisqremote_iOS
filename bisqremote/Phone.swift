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
import UIKit


class Phone {
    
    static var instance = Phone()

    var key: String
    var apsToken: String
    var confirmed = false // confirmation-notification received?
    
    private init() {
        key = ""
        apsToken = ""
        confirmed = false

        // try reading from UserDefaults
        var phoneIDExists = false
        if let s = UserDefaults.standard.string(forKey: userDefaultKeyPhoneID) {
            let a = s.split(separator: Character(BISQ_MESSAGE_SEPARATOR))
            var ok = true
            if a.count != 3 { ok = false }
            if ok && (a[0] != Phone.magic()) { ok = false }
            if ok && (a[1].count != 32) { ok = false }
            if ok && (a[2].count != 64) { ok = false }
            if ok {
                key = String(a[1])
                apsToken = String(a[2])
                confirmed = true // only confirmed phone IDs are saved into UserDefaults
                phoneIDExists = true
            }
        }
        if !phoneIDExists {
            UserDefaults.standard.removeObject(forKey: userDefaultKeyPhoneID) // just to be safe
            if let t = UserDefaults.standard.string(forKey: userDefaultKeyToken) {
                newToken(token: t)
            }
        }
    }
    
    func newToken(token: String) {
        key = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        apsToken = token
        confirmed = false
        UserDefaults.standard.set(token, forKey: userDefaultKeyToken)
        UserDefaults.standard.synchronize()
    }
    
    
    func reset() {
        UserDefaults.standard.removeObject(forKey: userDefaultKeyToken)        
        UserDefaults.standard.removeObject(forKey: userDefaultKeyPhoneID)
        UserDefaults.standard.removeObject(forKey: userDefaultKeyNotifications)
        key = ""
        apsToken = ""
        confirmed = false
    }
    
    func description() -> String? {
        return Phone.magic()+BISQ_MESSAGE_SEPARATOR+key+BISQ_MESSAGE_SEPARATOR+apsToken
    }
    
    static func magic() -> String {
        switch (Config.appConfiguration) {
        case .Debug:
            return PHONE_MAGIC_IOS_DEV
        case .TestFlight:
            return PHONE_MAGIC_IOS
        case .AppStore:
            return PHONE_MAGIC_IOS
        }
    }
    
    static func amIBeingDebugged() -> Bool {
        var info = kinfo_proc()
        var mib : [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout<kinfo_proc>.stride
        let junk = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
        assert(junk == 0, "sysctl failed")
        return (info.kp_proc.p_flag & P_TRACED) != 0
    }

}
