//
//  Contact.swift
//  ComCard
//
//  Created by Pragun Sharma on 2/13/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit

struct ContactStruct {
    private var _givenName: String
    private var _familyName: String
    private var _phoneNumber: String
    
    var givenName: String {
        return _givenName
    }
    
    var familyName: String {
        return _familyName
    }
    
    var phoneNumber: String {
        return _phoneNumber
    }
    
    init(givenName: String, familyName: String, phoneNumber: String) {
        _givenName = givenName
        _familyName = familyName
        _phoneNumber = phoneNumber
    }
    
}

