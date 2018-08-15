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
    var noContentView: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated:true);
        noContentView.frame = self.view.frame
        noContentView.backgroundColor = self.view.backgroundColor
        noContentView.isHidden = true
        let placeholder = UILabel()
        placeholder.text = "No notifications yet"
        placeholder.textAlignment = .center
        placeholder.font = UIFont.italicSystemFont(ofSize: 17)
        placeholder.textColor = UIColor.gray
        placeholder.frame = CGRect(x: 0, y: 0, width: noContentView.frame.width, height: 80)
        noContentView.addSubview(placeholder)
        self.view.addSubview(noContentView)
        dateformatterShort.dateFormat = BISQ_DATE_FORMAT
        reload()
    }

    func reload() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if NotificationArray.shared.countAll == 0 {
            noContentView.isHidden = false
        } else {
            noContentView.isHidden = true
        }
        return NotificationArray.shared.countAll
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell", for: indexPath) as! NotificationTableViewCell
        var notification: Notification
        notification = NotificationArray.shared.at(n:indexPath.row)
        cell.comment.text = notification.title
        if notification.sentDate != nil {
            let date = Date(timeIntervalSince1970: notification.sentDate!*0.001)
            cell.timeEvent.text = dateformatterShort.string(from: date)
        }
        cell.iconLabel.isHidden = false
        
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
        default:
            cell.iconLabel.isHidden = true
        }
        return cell
    }


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            NotificationArray.shared.remove(n: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.reloadData()
        }
    }

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
