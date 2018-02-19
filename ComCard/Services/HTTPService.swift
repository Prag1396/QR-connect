//
//  HTTPService.swift
//  ComCard
//
//  Created by Pragun Sharma on 2/18/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import Foundation

class HTTPService {
    static let instance = HTTPService()
    
    func uploadtoSpreadsheet(firstName: String, lastName: String, street1: String, street2: String, city: String, state: String, country: String, zipcode: String, quantity: String, onUploadToSpreadSheetComplete: @escaping (_ status: Bool, _ error: Error?)->()) {
        
        onUploadToSpreadSheetComplete(true, nil)
    }
}
