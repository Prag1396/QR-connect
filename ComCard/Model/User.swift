//
//  User.swift
//  ComCard
//
//  Created by Pragun Sharma on 1/3/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit

struct User {
    
    private var _phonenumber: String
    private var _email: String
    
    var phoneNumber: String {
        return _phonenumber
    }
    
    var email: String {
        return _email
    }
    
    init(phoneNumber: String, email: String) {
        _phonenumber = phoneNumber
        _email = email
    }
    
    
    
}
