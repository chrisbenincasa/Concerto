//
//  COOperation.swift
//  Concerto-Swift
//
//  Created by Christian Benincasa on 9/21/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Cocoa

enum COState {
    case Success
    case Failed
    case Pending
}

class COPromise<T> : NSObject {
    var state: COState = .Pending
    var succeeded: Bool {
        get {
            return self.state == .Success
        }
    }
    
    var failed: Bool {
        get {
            return self.state == .Failed
        }
    }
    
    var fulfillments: [(T) -> ()] = []
    
    func then(cb: (T) -> ()) -> COPromise<T> {
        fulfillments.append(cb)
        return self
    }
    
    func complete(result: T) -> COPromise<T> {
        self.state = .Success
        
        for fulfillment in fulfillments {
            fulfillment(result)
        }
        
        return self
    }
}

class COOperation<T> : NSOperation {
    var op: () -> T
    let promise = COPromise<T>();
    
    init(op: () -> T) {
        self.op = op;
    }
    
    override func main() {
        var result = op()
        promise.complete(result)
    }
}