//
//  QRCodeScannerViewController.swift
//  TestJSInterface
//
//  Created by Chetan Raina on 29/08/22.
//

import UIKit
import AVFoundation

class QRCodeScannerViewController: UIViewController {

    var qrLink = ""
    var captureSession = AVCaptureSession()
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        initializeQRScanner()
    }

    private func initializeQRScanner() {

        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back)

        guard let captureDevice = discoverySession.devices.first else {
            print("No device found")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)

            let videoMetaDataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(videoMetaDataOutput)

            videoMetaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            videoMetaDataOutput.metadataObjectTypes = [.qr]

            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = .resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)

            captureSession.startRunning()
        } catch {
            print(error)
            return
        }

    }

}

extension QRCodeScannerViewController:AVCaptureMetadataOutputObjectsDelegate {

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {

        if (metadataObjects.count == 0) {
            print("No code found")
            return
        }

        let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject

        if (metadataObject.type == .qr) {
            if (metadataObject.stringValue != nil && metadataObject.stringValue != self.qrLink) {
                // if we get some value after qr scan and it is different from the value of any previous scan
                print("Code value is == \(metadataObject.stringValue ?? "none")")
                self.qrLink = metadataObject.stringValue!
                
                let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                storyboard.qrLink = metadataObject.stringValue ?? ""

                print("navigating to webview with qr link \(metadataObject.stringValue ?? "none")")
                self.navigationController?.pushViewController(storyboard, animated: true)
            } else {
                print("No string value found")
                return
            }
        }

    }

}
