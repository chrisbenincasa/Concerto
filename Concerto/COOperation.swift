//
//  COOperation.swift
//  Concerto
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
    var rejections: [(NSError) -> ()] = []
    
    func then(cb: (T) -> ()) -> COPromise<T> {
        fulfillments.append(cb)
        return self
    }
    
    func catch(cb: (NSError) -> ()) -> COPromise<T> {
        rejections.append(cb)
        return self
    }
    
    func complete(result: T) -> COPromise<T> {
        if self.state == .Pending {
            self.state = .Success
            
            for fulfillment in fulfillments { fulfillment(result) }
        }
        
        return self
    }
    
    func reject(error: NSError) -> COPromise<T> {
        if self.state == .Pending {
            self.state = .Failed
            
            for rejection in rejections { rejection(error) }
        }
        
        return self
    }
}

class COOperation<T> {
    var op: () -> T // TODO make this except an Either
    let promise = COPromise<T>();
    
    init(op: () -> T) {
        self.op = op;
    }
    
    func getBlock() -> (() -> Void) {
        return { () -> Void in
            let result = self.op()
            if result is NSError {
                self.promise.reject(result as NSError)
            } else {
                self.promise.complete(result)
            }
        }
    }
}
