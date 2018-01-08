//
//  User.swift
//  ComCard
//
//  Created by Pragun Sharma on 1/3/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit

struct User {
    
    private var _fullName: String
    private var _phonenumber: String
    private var _cardNumber: String
    private var _email: String
    
    var fullName: String {
        return _fullName
    }
    
    var phoneNumber: String {
        return _phonenumber
    }
    
    var cardNumber: String {
        return _cardNumber
    }
    
    var email: String {
        return _email
    }
    
    init(fullname: String, phoneNumber: String, cardNumber: String, email: String) {
        _fullName = fullname
        _phonenumber = phoneNumber
        _cardNumber = cardNumber
        _email = email
    }
    
    
    
}
