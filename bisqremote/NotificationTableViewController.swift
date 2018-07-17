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

class NotificationTableViewController: UITableViewController {
    let dateformatterShort = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateformatterShort.dateFormat = "yyyy-MM-dd HH:mm"
    }

    func reload() {
        tableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        reload()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var n = NotificationArray.shared.countAll
        if n == 0 { n = 1 } // show placeholder
        return n
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "NotificationTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? NotificationTableViewCell  else {
            fatalError("The dequeued cell is not an instance of NotificationTableViewCell.")
        }
        var notification: Notification
        if NotificationArray.shared.countAll > 0 {
            notification = NotificationArray.shared.at(n:indexPath.row)
            cell.comment.text = "\(notification.title)"
            cell.timeEvent.text = String(notification.sentDate)
            cell.iconLabel.isHidden = false
        } else {
            notification = Notification()
            notification.type = NotificationType.PLACEHOLDER.rawValue
        }
        
        if notification.read {
            cell.comment.textColor = UIColor.gray
            cell.iconLabel.textColor = TINTCOLOR_BLUE_DISABLED
        } else {
            cell.comment.textColor = UIColor.black
            cell.iconLabel.textColor = TINTCOLOR_BLUE
        }
        switch notification.type {
        case NotificationType.TRADE.rawValue:
            cell.iconLabel.text = ICON_TRADE
        case NotificationType.OFFER.rawValue:
            cell.iconLabel.text = ICON_OFFER
        case NotificationType.DISPUTE.rawValue:
            cell.iconLabel.text = ICON_DISPUTE
        case NotificationType.PRICE.rawValue:
            cell.iconLabel.text = ICON_PRICE
        case NotificationType.MARKET.rawValue:
            cell.iconLabel.text = ICON_MARKET
        case NotificationType.PLACEHOLDER.rawValue:
            cell.comment.textColor = UIColor.gray
            cell.comment.text = "No notifications yet"
            cell.comment.textAlignment = .center
            // cell.comment.backgroundColor = UIColor.yellow
            cell.timeEvent.text = ""
            cell.selectionStyle = .none
            cell.titleLeadingConstraint.constant = -40
            cell.iconLabel.isHidden = true
        default:
            cell.iconLabel.isHidden = true
        }
        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            NotificationArray.shared.remove(n: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch(identifier) {
        case "showDetail":
            return NotificationArray.shared.countAll > 0
        default:
            return true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch(segue.identifier ?? "") {
        case "showDetail":
            guard let detailViewController = segue.destination as? NotificationDetailViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedNotificationTableViewCell = sender as? NotificationTableViewCell else {
                fatalError("Unexpected sender: \(sender ?? "missing sender")")
            }
            guard let indexPath = tableView.indexPath(for: selectedNotificationTableViewCell) else {
                fatalError("the selected cell is not being displayed in the table")
            }
            let selectedNotification = NotificationArray.shared.at(n: indexPath.row)
            detailViewController.notification = selectedNotification
            detailViewController.index = indexPath.row
            selectedNotification.read = true
            NotificationArray.shared.save()
            
            tableView.reloadRows(at: [indexPath], with: .top)
        default:
            break
        }
    }
    
}


extension Dictionary {
    var prettyPrintedJSON: String {
        do {
            let data: Data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            let s = String(data: data, encoding: .utf8)!
            return s
        } catch _ {
            return "could not prettyPrint"
        }
    }
}
