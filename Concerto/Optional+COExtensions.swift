//
//  Optional+COExtensions.swift
//  Concerto
//
//  Created by Christian Benincasa on 10/13/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Cocoa

extension Optional {
    func orElse(f: @autoclosure () -> Optional<T>) -> Optional<T> {
        switch (self) {
        case .Some(_): return self
        case .None: return f()
        }
    }
}
