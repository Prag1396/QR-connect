//
//  StringSpaces.swift
//  ComCard
//
//  Created by Pragun Sharma on 1/24/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import Foundation

extension String {
    func condenseWhitespace() -> String {
        let components = self.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
}


