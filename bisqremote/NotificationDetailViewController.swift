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
    @IBOutlet weak var priceInfoTextView: UITextView!
    @IBOutlet weak var actionTextview: UITextView!

    let BITCOINAVERAGE_URL = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTCEUR"
    var priceString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "" // empty navigationBar
        actionTextview.layer.cornerRadius = 7
        messageTextView.layer.cornerRadius = 7
        priceInfoTextView.layer.cornerRadius = 7
        dateformatterShort.dateFormat = BISQ_DATE_FORMAT
        if let n = notification {
            if n.type == NotificationType.MARKET.rawValue {
                priceInfoTextView.isHidden = false
                priceInfoTextView.text = "fetching..."
                getAveragePrice();
            } else {
                priceInfoTextView.isHidden = true
            }
            if n.title != nil && n.title!.count > 0 {
                titleLabel.text = n.title
                titleLabel.isHidden = false
            } else {
                titleLabel.isHidden = true
            }
            if n.message != nil && n.message!.count > 0 {
                messageTextView.text = n.message
                messageTextView.isHidden = false
            } else {
                messageTextView.isHidden = true
            }
            if n.sentDate != nil {
                let date = Date(timeIntervalSince1970: n.sentDate!*0.001)
                eventTimeLabel.text   = "event:    "+dateformatterShort.string(from: date)
                eventTimeLabel.isHidden = false
            } else {
                eventTimeLabel.isHidden = true
            }
            receiveTimelabel.text = "received: "+dateformatterShort.string(from: n.timestampReceived)
            if n.txId != nil {
                transactionID.text = "transaction ID: "+n.txId!
                transactionID.isHidden = false
            } else {
                transactionID.isHidden = true
            }
            if n.actionRequired != nil && n.actionRequired!.count > 0 {
                actionTextview.isHidden = false
                actionTextview.text = n.actionRequired
                actionTextview.layoutIfNeeded()
                actionTextview.backgroundColor = UIColor(red: 255.0/255.0, green: 126.0/255.0, blue: 121.0/255.0, alpha: 0.5)
            } else {
                actionTextview.isHidden = true
            }
        }
    }
    
    func getAveragePrice(){
        let url = NSURL(string: BITCOINAVERAGE_URL)
        URLSession.shared.dataTask(with: (url as URL?)!, completionHandler: {(data, response, error) -> Void in
            if let jsonObj = ((try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary) as NSDictionary??) {
                print(jsonObj!.value(forKey: "last")!)
                if let lastPrice = jsonObj!.value(forKey: "last") {
                    self.priceString = "Info: the current bitcoin average price is \(lastPrice) USD"
                }
                OperationQueue.main.addOperation({
                    self.showPrice()
                })
            }
        }).resume()
    }
    
    func showPrice(){
        self.priceInfoTextView.text = priceString
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        NotificationArray.shared.removeNotification(toBeDeleted: notification!)
        navigationController?.popViewController(animated: true)
    }
    
}
