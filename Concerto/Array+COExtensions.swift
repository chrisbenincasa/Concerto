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
    
    func indexOf(includedElement: T -> Bool) -> Int? {
        for (idx, element) in enumerate(self) {
            if includedElement(element) {
                return idx
            }
        }
        
        return nil
    }
    
    func foreach(f: T -> ()) {
        for element in self { f(element) }
    }
    
    func mkString(sep: String) -> String {
        var first = true
        return self.reduce("", combine: { (accum, elem) -> String in
            if (first) {
                first = false
                return "\(elem)"
            } else {
                return "\(accum)\(sep)\(elem)"
            }
        })
    }
}

func removeObjectIdenticalTo<T: AnyObject>(value: T, #fromArray: [T]) -> [T] {
    return fromArray.filter({
        $0 === value
    })
}