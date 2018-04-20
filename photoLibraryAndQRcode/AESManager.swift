//
//  AESManager.swift
//  photoLibraryAndQRcode
//
//  Created by ShaoJen Chen on 2018/4/19.
//  Copyright © 2018年 ShaoJenChen. All rights reserved.
//

import CryptoSwift

private let _manager = AESManager()

class AESManager: NSObject {

    public class var manager: AESManager {
        
        return _manager
        
    }
    
    /// AES加密
    func aesEncrypt(plaintext: String, key: String) -> String? {
        
        var result: String?
        do {
            // 用UTF8的编碼方式將字串轉成Data
            let data: Data = plaintext.data(using: String.Encoding.utf8, allowLossyConversion: true)!
            
            // 用AES的方式將Data加密
            let aecEnc: AES = try AES(key: Array(key.utf8), blockMode: .ECB)
            let enc = try aecEnc.encrypt(data.bytes)
            
            // 使用Base64編碼方式將Data轉回字串
            let encData: Data = Data(bytes: enc, count: enc.count)
            result = encData.base64EncodedString()
        } catch {
            print("\(error.localizedDescription)")
        }
        
        return result
    }
    
    /// AES解密
    func aesDecrypt(ciphertext: String, key: String) -> String? {
        var result: String?
        do {
            // 使用Base64的解碼方式將字串解碼後再轉换Data
            let data = Data(base64Encoded: ciphertext, options: .ignoreUnknownCharacters)!
            
            // 用AES方式將Data解密
            let aesDec: AES = try AES(key: Array(key.utf8), blockMode: .ECB)
            let dec = try aesDec.decrypt(data.bytes)
            
            // 用UTF8的編碼方式將解完密的Data轉回字串
            let desData: Data = Data(bytes: dec, count: dec.count)
            result = String(data: desData, encoding: .utf8)
        } catch {
            print("\(error.localizedDescription)")
        }
        
        return result
    }
}
