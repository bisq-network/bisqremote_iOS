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

class NotificationDetailViewController: UIViewController {
    let dateformatterShort = DateFormatter()
    var index: Int = 0
    var notification: Notification?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var receiveTimelabel: UILabel!
    @IBOutlet weak var transactionID: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var actionTextview: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "" // empty navigationBar
        actionTextview.layer.cornerRadius = 7
        messageTextView.layer.cornerRadius = 7
        dateformatterShort.dateFormat = BISQ_DATE_FORMAT
        if let n = notification {
            titleLabel.text = n.title
            if n.message.count > 0 {
                messageTextView.isHidden = false
                messageTextView.text = n.message
                messageTextView.layoutIfNeeded()
            } else {
                messageTextView.isHidden = true
            }

            messageTextView.text = n.message
            let date = Date(timeIntervalSince1970: Double(n.sentDate))
            eventTimeLabel.text   = "event:    "+dateformatterShort.string(from: date)
            receiveTimelabel.text = "received: "+dateformatterShort.string(from: n.timestampReceived)
            transactionID.text = "transaction ID: "+n.txId
            if n.actionRequired.count > 0 {
                actionTextview.isHidden = false
                actionTextview.text = n.actionRequired
                actionTextview.layoutIfNeeded()
                actionTextview.backgroundColor = UIColor(red: 255.0/255.0, green: 126.0/255.0, blue: 121.0/255.0, alpha: 0.5)
            } else {
                actionTextview.isHidden = true
            }
        }
    }
    @IBAction func deletePressed(_ sender: Any) {
        NotificationArray.shared.remove(n: index)
        navigationController?.popViewController(animated: true)
    }
    
}
