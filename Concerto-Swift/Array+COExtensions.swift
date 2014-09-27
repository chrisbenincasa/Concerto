//
//  Array+COExtensions.swift
//  Concerto-Swift
//
//  Created by Christian Benincasa on 9/27/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Foundation

extension Array {
    func find(includedElement: T -> Bool) -> T? {
        for (idx, element) in enumerate(self) {
            if includedElement(element) {
                return element
            }
        }
        
        return nil
    }
}