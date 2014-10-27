//
//  COTableCellView.swift
//  Concerto
//
//  Created by Christian Benincasa on 10/4/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Cocoa

class COTableCellView: NSTableCellView {
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
//        self.textField?.sizeToFit() // Increase size of internal text field to fit the width of the column
        
    }
}
