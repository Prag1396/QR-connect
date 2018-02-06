//
//  NSDictionaryFindKey.swift
//  ComCard
//
//  Created by Pragun Sharma on 2/6/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit

extension Dictionary where Value: Equatable {
    func someKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.key
    }
}
