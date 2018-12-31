//
//  BarcodeReaderView.swift
//  Pods
//
//  Created by Twaha Mukammel on 8/15/17.
//
//

import UIKit
import AVFoundation

@objc public protocol BarcodeReaderDelegate: NSObjectProtocol {
    func barcodeOutput(string: String?)
}

open class BarcodeReaderView: UIView, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var barcodeFrameLayer: CALayer?
    
    let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                              AVMetadataObject.ObjectType.code39,
                              AVMetadataObject.ObjectType.code39Mod43,
                              AVMetadataObject.ObjectType.code93,
                              AVMetadataObject.ObjectType.code128,
                              AVMetadataObject.ObjectType.ean8,
                              AVMetadataObject.ObjectType.ean13,
                              AVMetadataObject.ObjectType.aztec,
                              AVMetadataObject.ObjectType.pdf417,
                              AVMetadataObject.ObjectType.qr]
    
    public var showBarcodeFrame: Bool = true
    
    public var delegate: BarcodeReaderDelegate? = nil
    
    public func startReader() {
        
        let captureDevice = AVCaptureDevice.default(for: .video)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            
            captureSession = AVCaptureSession()
            
            captureSession?.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = layer.bounds
            layer.addSublayer(videoPreviewLayer!)
            
            captureSession?.startRunning()
            
            if showBarcodeFrame == true {
                barcodeFrameLayer = CALayer()
                
                if let frameLayer = barcodeFrameLayer {
                    frameLayer.borderColor = UIColor.green.cgColor
                    frameLayer.borderWidth = 2
                    
                    layer.addSublayer(frameLayer)
                }
            }
            
        } catch {
            print(error)
            return
        }
        
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate Methods
    
    public func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        if metadataObjects == nil || metadataObjects.count == 0 {
            barcodeFrameLayer?.frame = CGRect.zero
            
            delegate?.barcodeOutput(string: nil)
            
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            barcodeFrameLayer?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                delegate?.barcodeOutput(string: metadataObj.stringValue)
            }
        }
    }
    
}
