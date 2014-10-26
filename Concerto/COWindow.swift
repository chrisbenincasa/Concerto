//
//  COWindow.swift
//  Concerto
//
//  Created by Christian Benincasa on 10/1/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Cocoa

extension NSWindow {
    func fadeIn(sender: AnyObject!) {
        self.alphaValue = 0.5
        self.makeKeyAndOrderFront(sender)
        NSAnimationContext.beginGrouping()
        NSAnimationContext.currentContext().duration = 0.1
        self.animator().alphaValue = 1.0
        NSAnimationContext.endGrouping()
    }
}

class COWindow: NSWindow {

//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        self.titlebarAppearsTransparent = true
//    }
//    
//    override init(contentRect: NSRect, styleMask aStyle: Int, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
//        super.init(contentRect: contentRect, styleMask: aStyle, backing: bufferingType, defer: flag)
//        self.titlebarAppearsTransparent = true
//    }
}
