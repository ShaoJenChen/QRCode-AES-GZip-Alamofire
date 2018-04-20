//
//  AWSConnector.swift
//  photoLibraryAndQRcode
//
//  Created by ShaoJen Chen on 2018/4/19.
//  Copyright © 2018年 ShaoJenChen. All rights reserved.
//

import UIKit
import Alamofire

private let _connector = AWSConnector()

private let _cameraCheckSumCodeKey = "CAMERA_CHECK_SUM_CODE_KEY"

class AWSConnector: NSObject {
    
    public class var connector: AWSConnector {
        
        return _connector
        
    }
    
    public class var cameraCheckSumCodeKey: String {
        
        return _cameraCheckSumCodeKey
        
    }
    
    var sessionManager: SessionManager = {
        
        let configuration = URLSessionConfiguration.default
        
        configuration.timeoutIntervalForRequest = 30
        
        configuration.timeoutIntervalForResource = 30
        
        let sessionManager = Alamofire.SessionManager(configuration: configuration)
        
        sessionManager.delegate.sessionDidReceiveChallenge = { session, challenge in
            var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
            var credential: URLCredential?
            
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust, let trust = challenge.protectionSpace.serverTrust {
                disposition = URLSession.AuthChallengeDisposition.useCredential
                credential = URLCredential(trust: trust)
            } else {
                if challenge.previousFailureCount > 0 {
                    disposition = .cancelAuthenticationChallenge
                } else {
                    credential = sessionManager.session.configuration.urlCredentialStorage?.defaultCredential(for: challenge.protectionSpace)
                    
                    if credential != nil {
                        disposition = .useCredential
                    }
                }
            }
            
            return (disposition, credential)
        }
        
        return sessionManager
        
    }()
    
    func getJsonFileFromAWS(qrcode: String, completion: @escaping ([String:Any]) -> Void ) {
        
        sessionManager.request("https://6e6jakb3e1.execute-api.us-east-1.amazonaws.com/dev/getfile/\(qrcode)/").responseJSON(completionHandler: { response in
            if response.result.isSuccess {
                // convert data to dictionary array
                if let result = response.value as? [String: AnyObject] {
                    
                    completion(result)
                    
                }
            } else {
                
                print("error: \(String(describing: response.error))")
                
            }
        })
    }
    
    func setJsonFileToAWS(ciphertext: String, completion: @escaping ([String:Any]) -> Void) {
        
        let deviceInfo = UIDevice.current.name
        
        let deviceType = UIDevice.current.modelName
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        
        let parameters = [
            "file_data"    : ciphertext,
            "device_info"  : deviceInfo,
            "device_type"  : deviceType,
            "app_version"  : appVersion
            ]

        self.sessionManager.request("https://6e6jakb3e1.execute-api.us-east-1.amazonaws.com/dev/setfile/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response: DataResponse<Any>) in
            
            if response.result.isSuccess == true {
                
                if let result = response.value as? [String: AnyObject] {
                    
                    completion(result)
                    
                }
                
            }
            
        }
            
    }
        
}


public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad6,11", "iPad6,12":                    return "iPad 5"
        case "iPad7,5", "iPad7,6":                      return "iPad 6"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
        case "AppleTV5,3":                              return "Apple TV"
        case "AppleTV6,2":                              return "Apple TV 4K"
        case "AudioAccessory1,1":                       return "HomePod"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
}
