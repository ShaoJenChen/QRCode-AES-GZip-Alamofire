//
//  AWSFileResponse.swift
//  photoLibraryAndQRcode
//
//  Created by ShaoJen Chen on 2018/4/19.
//  Copyright © 2018年 ShaoJenChen. All rights reserved.
//

import ObjectMapper

class AWSGetFileResponse: Mappable {
    
    var result: String?
    
    var result_detail: String?
    
    var file_id: String?
    
    var file_base64_string: String?
    
    
    required convenience init?(map: Map) {
        
        self.init()
        
    }
    
    func mapping(map: Map) {
        
        self.result <- map["result"]
        
        self.result_detail <- map["result_detail"]
        
        self.file_id <- map["file_id"]
        
        self.file_base64_string <- map["file_base64_string"]
        
    }
    

}
