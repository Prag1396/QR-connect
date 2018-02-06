//
//  CountryCodesAndNames.swift
//  ComCard
//
//  Created by Pragun Sharma on 2/5/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit

var countries: [String: String] = [:]


extension NSLocale {
    
    func countryArrayPopulate() -> [String: String] {
        for code in NSLocale.isoCountryCodes as [String] {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en_US").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
            countries.updateValue(name, forKey: id)
            
        }
        return countries
    }
    
    
}
