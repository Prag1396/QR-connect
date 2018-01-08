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
    private var _passportNumber: String
    
    var fullName: String {
        return _fullName
    }
    
    var phoneNumber: String {
        return _phonenumber
    }
    
    var cardNumber: String {
        return _cardNumber
    }
    
    var passportNumber: String {
        return _passportNumber
    }
    
    init(fullname: String, phoneNumber: String, cardNumber: String, passportNumber: String) {
        _fullName = fullname
        _phonenumber = phoneNumber
        _cardNumber = cardNumber
        _passportNumber = passportNumber
    }
    
    
    
}
