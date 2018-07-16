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

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var qrImage: UIImageView!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var instructionsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let d = Phone.instance.phoneID() {
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
            instructionsLabel.text = "Congratulations, you are all set."
            instructionsLabel.textAlignment = .center
            instructionsLabel.isHidden = false
            qrImage.isHidden = true
            statusLabel.text = ""
            instructionsButton.setTitle("Show notifications", for: .normal)
        } else {
            statusLabel.text = ""
        }
    }
    
    private func toggleInstructions() {
        if !Phone.instance.confirmed {
            if instructionsLabel.isHidden {
                instructionsLabel.isHidden = false
                qrImage.isHidden = true
                instructionsButton.setTitle("QR CODE", for: .normal)
            } else {
                instructionsLabel.isHidden = true
                qrImage.isHidden = false
                instructionsButton.setTitle("INSTRUCTIONS", for: .normal)
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        toggleInstructions()
    }

    @IBAction func instructionsPressed(_ sender: Any) {
        
//        let log = UserDefaults.standard.string(forKey: "logging")
//        let x = UIAlertController(title: "log", message: log, preferredStyle: .actionSheet)
//        x.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        self.present(x, animated: true) {}

        if Phone.instance.confirmed {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "listScreen") as? NotificationTableViewController {
                self.navigationController?.setViewControllers([vc], animated: true)
            }
        } else {
            toggleInstructions()
        }
    }
    
}
