//
//  ViewController.swift
//  TestJSInterface
//
//  Created by Sachin Sharma on 23/07/22.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func openPwaTapped(_sender: UIButton) {
        let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        self.navigationController?.pushViewController(storyboard, animated: true)
    }
    
    @IBAction func openQRScannerTapped(_sender: UIButton) {
        let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "QRCodeScannerViewController") as! QRCodeScannerViewController
        self.navigationController?.pushViewController(storyboard, animated: true)
    }
    
}
