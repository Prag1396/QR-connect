//
//  Message.swift
//  ComCard
//
//  Created by Pragun Sharma on 1/24/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit

struct Message {
    
    private var _fromUID: String?
    private var _toID: String?
    private var _messagetext: String?
    private var _timeStamp: NSNumber?
    
    
    var fromUID: String {
        return _fromUID!
    }
    
    var toID: String {
        return _toID!
    }
    
    var messageText: String {
        return _messagetext!
    }
    
    var timeStamp: NSNumber {
        return _timeStamp!
    }
    
    init(fromUID: String, toUID: String, messageText: String, timeStamp: NSNumber) {
        _fromUID = fromUID
        _toID = toUID
        _messagetext = messageText
        _timeStamp = timeStamp
    }
    
    
    
    
    
}
