//
//  COTableRowView.swift
//  Concerto
//
//  Created by Christian Benincasa on 10/4/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Cocoa

class COTableRowView: NSTableRowView {

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
    }
    
    override func drawSelectionInRect(dirtyRect: NSRect) {
        NSColor.blueColor().setFill()
        NSRectFill(dirtyRect)
    }
}
