//
//  WebViewController.swift
//  TestJSInterface
//
//  Created by Sachin Sharma on 23/07/22.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {
    var webView: WKWebView!
    var qrLink = ""
    
    public override func loadView() {
        print("webview got qr link \(self.qrLink)")
        
        let userController = WKUserContentController()
        userController.add(self, name: "iosBridge")
        
        // set variables in window object for the web app to use
        let script = """
            window.iosProps = {
                version: "1.0",
                cardActivationQrLink: "\(self.qrLink)",
            };
        """
        
        let userScript = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        userController.addUserScript(userScript)
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = userController;
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // get session token for web app
        Helper.getSessionToken(onSuccess: onSuccess)
        
        // on api success
        public func onSuccess (result: [String: Any]) {
            let sessionToken = result["token"] ?? ""
            
            if (sessionToken as! String != "") {
                let url = URL(string: "https://pwa-uat.hyperface.co?sessionToken=\(sessionToken)")!
                
                DispatchQueue.main.async {
                    // async code runs on separate thread but webView can be used in main thread only
                    self.webView.load(URLRequest(url: url))
                    self.webView.allowsBackForwardNavigationGestures = true
                    
//                    self.messageToWebview(msg: """
//                        { "type": "ACTIVATION_CODE", "payload": "123" }
//                    """)
                }
            } else {
                print("Error: failed to get session token")
            }
        }
    }
    
    // receive message from wkwebview
    public func userContentController( _ userContentController: WKUserContentController, didReceive message: WKScriptMessage ) {
        print("received message from webview \(message.body)")
        
        // parse message as json
        let jsonData = (message.body as! String).data(using: .utf8)!
        
        do {
            let action = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String:Any] as NSDictionary?
            
//            // for nested objects
//            print("value is - \((dictionary?["a"] as! NSDictionary)["b"]!)")
            
            let type = action?["type"] as! String
            
            if (type == "SESSION_EXPIRED") {
                let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                self.navigationController?.pushViewController(storyboard, animated: true)
            } else if (type == "CARD_ACTIVATION_QR_SCAN") {
                let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "QRCodeScannerViewController") as! QRCodeScannerViewController
                self.navigationController?.pushViewController(storyboard, animated: true)
            }
        } catch (let error as NSError) {
            print(error)
        }
    }
    
    public func messageToWebview(msg: String) {
        // has sync issues, message is sent even before browser sets callback method 'onMessage' in 'window.iosProps' object
        self.webView?.evaluateJavaScript("window.iosProps.onMessage('\(msg)')")
    }
}
