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
    var key: String?
    var apsToken: String?
    var initialised = false
    
    init() {
        // read the data from UserDefaults
        if let s = UserDefaults.standard.string(forKey: userDefaultKeyPhone) {
            let a = s.split(separator: Character(BISQ_MESSAGE_SEPARATOR))
            if (a.count != 3) {
                UserDefaults.standard.set(false, forKey: userDefaultKeyPhone)
                key = nil
                apsToken = nil
                initialised = false
            } else {
                assert (a[0] == magic())
                assert (a[1].count == 32)
                assert (a[2].count == 64)
                key = String(a[1])
                apsToken = String(a[2])
                initialised = true
            }
        }
    }
    
    init(token: String) {
        apsToken = token
        // create key and store to Userdefaults
        key = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        initialised = true
        if let d = description() {
            UserDefaults.standard.set(d, forKey: userDefaultKeyPhone)
        }
    }
    
    func description() -> String? {
        if initialised {
            if let k = key {
                if let a = apsToken {
                    return magic()+BISQ_MESSAGE_SEPARATOR+k+BISQ_MESSAGE_SEPARATOR+a
                }
            }
        }
        return nil
    }
    
    func magic() -> String {
        if amIBeingDebugged() {
            return PHONE_MAGIC_IOS_DEV
        } else {
            return PHONE_MAGIC_IOS
        }
    }
    func amIBeingDebugged() -> Bool {
        var info = kinfo_proc()
        var mib : [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout<kinfo_proc>.stride
        let junk = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
        assert(junk == 0, "sysctl failed")
        return (info.kp_proc.p_flag & P_TRACED) != 0
    }

}
