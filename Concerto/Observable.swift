//
//  Observable.swift
//  Concerto
//
//  Created by Christian Benincasa on 9/27/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Foundation

protocol Observable {
    typealias ObserverType
    
    var observers: [ObserverType] { get set }
    
    func addDelegate(d: ObserverType)
    func removeDelegate(d: ObserverType)
}