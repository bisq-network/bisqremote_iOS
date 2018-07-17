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

let userDefaultKeyPairingToken  = "PairingToken"
let userDefaultKeyNotifications = "Notifications"

let PAIRING_MAGIC_IOS_DEV:      String = "iOSDev"
let PAIRING_MAGIC_IOS:          String = "iOS"
let BISQ_CONFIRMATION_MESSAGE:  String = "confirmationNotification"
let BISQ_FACTORY_RESET_MESSAGE: String = "factoryResetNotification"
let BISQ_MESSAGE_IOS_MAGIC:     String = "BisqMessageiOS"

let BISQ_MESSAGE_SEPARATOR = "|" // must be a single character

let TINTCOLOR_GREEN = UIColor(red: 37.0/255.0, green: 177.0/255.0, blue: 53.0/255.0, alpha: 1.0)
let TINTCOLOR_BLUE = UIColor(red: 15.0/255.0, green: 134.0/255.0, blue: 195.0/255.0, alpha: 1.0)
let TINTCOLOR_BLUE_DISABLED = UIColor(red: 127.0/255.0, green: 181.0/255.0, blue: 213.0/255.0, alpha: 1.0)

let BISQ_DATE_FORMAT = "yyyy-MM-dd HH:mm:ss"

let ICON_TRADE   = "\u{f362}"
let ICON_OFFER   = "\u{f00c}"
let ICON_DISPUTE = "\u{f0e3}"
let ICON_PRICE   = "\u{f201}"//"\u{f0d6}"
let ICON_MARKET  = "\u{f007}"
