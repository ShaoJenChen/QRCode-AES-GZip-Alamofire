//
//  ViewController.swift
//  photoLibraryAndQRcode
//
//  Created by ShaoJen Chen on 2018/4/18.
//  Copyright © 2018年 ShaoJenChen. All rights reserved.
//

import UIKit
import CoreData
import MBProgressHUD

class ViewController: UIViewController, UINavigationControllerDelegate{

    @IBOutlet var sourceImageView: UIImageView!
    @IBOutlet var qrCodeLabel: UILabel!
    @IBOutlet var jsonStringField: UITextField!
    @IBOutlet var jsonStringQRCode: UIImageView!
    @IBOutlet var qrCodeLabelFromCamera: UILabel!
    @IBOutlet var checkSumLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let key = AWSConnector.cameraCheckSumCodeKey
        
        guard let checksum = UserDefaults.standard.object(forKey: key) as? String else { return }
        
        self.checkSumLabel.text = checksum
        
        ///
        ///coredata
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        let engineer = NSEntityDescription.entity(forEntityName: "Engineer", in: context)
        
//        engineer.
        
        //insert
//        let man: Engineer = NSEntityDescription.insertNewObject(forEntityName: "Engineer", into: context) as! Engineer
//
//        man.attribute = "shaojen"
//        man.attribute1 = "李白"
//        man.attribute2 = true
        
//        do {
//            try context.save()
//        } catch {
//            fatalError("\(error)")
//        }
        
        // update
//        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Engineer")
//        request.predicate = nil
//        let name = "李白"
//        request.predicate =
//            NSPredicate(format: "attribute1 = '\(name)'")
//
//        do {
//            let results =
//                try context.fetch(request)
//                    as! [Engineer]
//
//            if results.count > 0 {
//                results[0].attribute2 = false
//                try context.save()
//            }
//        } catch {
//            fatalError("\(error)")
//        }
        
        
//        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func openAlbum(_ sender: UIButton) {
        
        self.sourceImageView.image = nil
        self.qrCodeLabel.text = ""
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func saveQRcode(_ sender: UIButton) {
        
//        let image = UIImage.init(view: self.view)
        
//        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
//        CustomPhotoAlbum.sharedInstance.saveImage(image: self.jsonStringQRCode.image!)
        
        UIImageWriteToSavedPhotosAlbum(self.jsonStringQRCode.image!, nil, nil, nil)
        
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        
        if let error = error {
            
            alert.title = "儲存失敗"
            
            alert.message = error.localizedDescription
            
        } else {
            
            alert.title = "已儲存"
            
            alert.message = "QR Code 已儲存到照片"
            
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert, animated: true)
    }
    
    
    @IBAction func generateQRcode(_ sender: UIButton) {
        
        self.generateQRCode(text: jsonStringField.text!)
        
    }
    
    @IBAction func encryptAndSetFileToAWS(_ sender: UIButton) {
        
        guard let jsonString = jsonStringField.text else { return }
        
        let alert = UIAlertController(title: "請輸入密碼", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Key"
        }
        
        let action_ok = UIAlertAction(title: "OK", style: .default) { (action) in
            
            guard let keyTextField = alert.textFields?.first else { return }
            
            guard let key = keyTextField.text else { return }
            
            if key.count > 0 {
                
                var key16bit = ""
                
                while key16bit.count < 16 {
                    
                    key16bit.append(key)
                    
                }
                
                let startIndex = key16bit.index(key16bit.startIndex, offsetBy: 0)
                
                let endIndex = key16bit.index(key16bit.startIndex, offsetBy: 16)
                
                key16bit = String(key16bit[startIndex ..< endIndex])
                
                guard let cipherText = AESManager.manager.aesEncrypt(plaintext: jsonString, key: key16bit) else { return }
                
                self.setJsonFileToAWS(ciphertext: cipherText)
                
            }
            
        }
        
        alert.addAction(action_ok)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func generateQRCode(text: String) {
        
        let data = text.data(using: .ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            let context = CIContext()
            
            if let output = filter.outputImage?.transformed(by: transform) {
                let cgimage = context.createCGImage(output, from: output.extent)
                self.jsonStringQRCode.image = UIImage(cgImage: cgimage!)
            }
        }
        
    }
    
    func detectQRCode(_ image: UIImage?) -> [CIFeature]? {
        if let image = image, let ciImage = CIImage(image: image){
            var options: [String: Any]
            let context = CIContext()
            options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
            let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
            if ciImage.properties.keys.contains((kCGImagePropertyOrientation as String)){
                options = [CIDetectorImageOrientation: ciImage.properties[(kCGImagePropertyOrientation as String)] ?? 1]
            }else {
                options = [CIDetectorImageOrientation: 1]
            }
            let features = qrDetector?.features(in: ciImage, options: options)
            return features
            
        }
        return nil
    }

    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func getJsonFileFromAWS(qrCode: String) {
        
        AWSConnector.connector.getJsonFileFromAWS(qrcode: qrCode) { (json) in
            
            guard let fileResponse = AWSGetFileResponse(JSON: json) else { return }
            
            guard let file_base64_string = fileResponse.file_base64_string else { return }
            
            let alert = UIAlertController(title: "請輸入密碼", message: "", preferredStyle: .alert)
            
            alert.addTextField { (textField) in
                textField.placeholder = "Key"
            }
            
            let action_ok = UIAlertAction(title: "OK", style: .default) { (action) in
                
                guard let keyTextField = alert.textFields?.first else { return }
                
                guard let key = keyTextField.text else { return }
                
                if key.count > 0 {
                    
                    var key16bit = ""
                    
                    while key16bit.count < 16 {
                        
                        key16bit.append(key)
                        
                    }
                    
                    let startIndex = key16bit.index(key16bit.startIndex, offsetBy: 0)
                    
                    let endIndex = key16bit.index(key16bit.startIndex, offsetBy: 16)
                    
                    key16bit = String(key16bit[startIndex ..< endIndex])
                    
                    guard let plaintext = AESManager.manager.aesDecrypt(ciphertext: file_base64_string, key: key16bit) else { return }
                    
                    fileResponse.file_base64_string = plaintext
                    
                    let jsonString = fileResponse.toJSONString(prettyPrint: true)
                    
                    print(jsonString!)
                    
                    guard let dic = self.convertToDictionary(text: plaintext) else { return }
                    
                    print(dic)
                }
                    
                else {
                    
                    
                }
                
            }
            
            alert.addAction(action_ok)
            
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    func setJsonFileToAWS(ciphertext: String) {
        
        AWSConnector.connector.setJsonFileToAWS(ciphertext: ciphertext) { (json) in
            
            guard let result = json["result"] as? String else { return }
            
            if result == "success" {
                
                let checksum = json["file_id"] as! String
                
                self.checkSumLabel.text = checksum
                
                self.generateQRCode(text: checksum)
                
                let key = AWSConnector.cameraCheckSumCodeKey
                
                UserDefaults.standard.set(checksum, forKey: key)
                
                UserDefaults.standard.synchronize()
            }
            
        }
        
    }
    
}

extension ViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("selected photo")
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        self.sourceImageView.image = image
        
        var qrcode = ""
        
        if let features = self.detectQRCode(image), !features.isEmpty{
            for case let row as CIQRCodeFeature in features{
//                print(row.messageString ?? "nope")
                qrcode = row.messageString!
            }
        }
        
//        print("QRcode is \(message)")
        self.qrCodeLabel.text = qrcode
        
        picker.dismiss(animated: true) {
            
            self.getJsonFileFromAWS(qrCode: qrcode)
            
        }
        
    }
}

extension ViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? QRCodeScannerViewController,
            segue.identifier == "presentQRCodeScanner" {
            
            viewController.delegate = self
        }
    }

}

extension ViewController: QRCodeDelegate {
    
    func didGetQRCodeString(_ result: String) {
        
        self.qrCodeLabelFromCamera.text = result
        
        self.getJsonFileFromAWS(qrCode: result)
        
    }
    
}

extension UIImage{
    convenience init(view: UIView) {
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
        
    }
}
