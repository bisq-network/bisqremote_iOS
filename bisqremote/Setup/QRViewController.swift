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

class QRViewController: UIViewController {

    @IBOutlet weak var confirmedImage: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var qrImage: UIImageView!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var waiting: UIActivityIndicatorView!
    @IBOutlet weak var instructionsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let d = Phone.instance.description() {
            qrImage.contentMode = .scaleAspectFit
            instructionsLabel.isHidden = true
            qrImage.image = generateQRCode(from: d)
        }
        update()
    }
    
    func confirmed() {
        update()
    }
    

    private func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                let i = UIImage(ciImage: output)
                return i
            }
        }
        
        return nil
    }
    
    private func update() {
        if Phone.instance.confirmed {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "listScreen") as? NotificationTableViewController {
                    self.navigationController?.setViewControllers([vc], animated: true)
                }
            })
            statusLabel.text = "confirmation received"
            instructionsLabel.isHidden = true
            confirmedImage.isHidden = false
            waiting.isHidden = false
            instructionsButton.isHidden = true
        } else {
            statusLabel.text = ""
            confirmedImage.isHidden = true
            waiting.isHidden = true
        }
    }
    
    
    @IBAction func instructionsPressed(_ sender: Any) {
        if instructionsLabel.isHidden {
            instructionsLabel.isHidden = false
            qrImage.isHidden = true
        } else {
            instructionsLabel.isHidden = true
            qrImage.isHidden = false
        }
    }
    
}
