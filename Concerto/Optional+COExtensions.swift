//
//  Optional+COExtensions.swift
//  Concerto
//
//  Created by Christian Benincasa on 10/13/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Cocoa

extension Optional {
    func getOrElse(f: @autoclosure () -> T) -> T {
        switch (self) {
        case let .Some(x): return x
        case .None: return f()
        }
    }
    
    func orElse(f: @autoclosure () -> Optional<T>) -> Optional<T> {
        switch (self) {
        case .Some(_): return self
        case .None: return f()
        }
    }
    
    func isEmpty() -> Bool {
        return self == nil
    }
    
    func nonEmpty() -> Bool {
        return !self.isEmpty()
    }
}
