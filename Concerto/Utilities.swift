//
//  Utilities.swift
//  Concerto
//
//  Created by Christian Benincasa on 9/27/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Foundation

class Utilities {
    class func identity<T>(i: T) -> T {
        return i
    }
    
    class func log(logMessage: String, functionName: String = __FUNCTION__) {
        println("\(functionName): \(logMessage)")
    }
}