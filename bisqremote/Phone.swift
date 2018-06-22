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
    let PHONE_MAGIC: String = "BisqPhoneiOS"
    
    var key: String = ""
    var apsToken: String = ""
    var initialised = false
    
    init() {
        // read the data from UserDefaults
        if let s = UserDefaults.standard.string(forKey: userDefaultKeyPhone) {
            let a = s.split(separator: "@")
            assert (a.count == 3)
            assert (a[0] == PHONE_MAGIC)
            assert (a[1].count == 32)
            assert (a[2].count == 64)
            key = String(a[1])
            apsToken = String(a[2])
            initialised = true
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
            return PHONE_MAGIC+"@"+key+"@"+apsToken
        } else {
            return nil
        }
    }
}
