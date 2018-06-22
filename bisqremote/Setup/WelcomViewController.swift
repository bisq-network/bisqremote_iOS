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

class WelcomViewController: UIViewController {

    @IBOutlet weak var startButton: UIBarButtonItem!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        statusLabel.isHidden = false
        startButton.isEnabled = false
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(doYourStuff),
                                               name: NSNotification.Name.UIApplicationWillEnterForeground,
                                               object: nil)
    }
    
    @objc func doYourStuff() {
        isSetupCompleted()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !UserDefaults.standard.bool(forKey: userDefaultKeySetupDone) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                self.isSetupCompleted()
            })
        } else {
            self.startButton.isEnabled = true
            self.statusLabel.isHidden = true
        }
    }

    func isSetupCompleted() {
        if !UserDefaults.standard.bool(forKey: userDefaultKeySetupDone) {
            UIApplication.shared.registerForRemoteNotifications()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                let phone = Phone()
                if !phone.initialised {
                    self.startButton.isEnabled = false
                    self.statusLabel.isHidden = false
                    let x = UIAlertController(title: "Setup failed", message: "Something went wrong in the setup. Make sure you are connected to the internet.", preferredStyle: .actionSheet)
                    x.addAction(UIAlertAction(title: "try again", style: .default, handler: self.retry))
                    x.addAction(UIAlertAction(title: "cancel", style: .default, handler: nil))
                    self.present(x, animated: true) {}
                } else {
                    self.startButton.isEnabled = true
                    self.statusLabel.isHidden = true
                }
            })
        } else {
            self.startButton.isEnabled = true
            self.statusLabel.isHidden = true
        }
    }

    func retry(alert: UIAlertAction!) {
        isSetupCompleted()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webPagePressed(alert: UIAlertAction!) {
        if let url = NSURL(string: "https://bisq.network"){
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }

    @IBAction func helpPressed(_ sender: Any) {
        let x = UIAlertController(title: "Bisq", message: "Bisq is an open-source desktop application that allows you to buy and sell bitcoins in exchange for national currencies, or alternative crypto currencies.", preferredStyle: .actionSheet)
        x.addAction(UIAlertAction(title: "https://bisq.network", style: .default, handler: webPagePressed))
        x.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(x, animated: true) {}
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
