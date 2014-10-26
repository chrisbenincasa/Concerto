//
//  COWindowController.swift
//  Concerto
//
//  Created by Christian Benincasa on 9/27/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Cocoa

class COWindowController: NSWindowController {
    override func showWindow(sender: AnyObject?) {
        self.window?.makeKeyAndOrderFront(nil)
        super.showWindow(sender)
    }
}