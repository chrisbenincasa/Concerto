//
//  COTableHeaderView.swift
//  Concerto
//
//  Created by Christian Benincasa on 10/26/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Cocoa

enum SortableField: Int {
    case ArtistName = 0
    case AlbumName
    case Year
    
    static func stringForField(field: SortableField) -> String? {
        switch (field) {
        case .AlbumName: return "Album"
        case .ArtistName: return "Artist"
        case .Year: return "Year"
        default: return nil
        }
    }
}

class COTableHeaderView: NSTableHeaderView {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
    }
    
    override func rightMouseDown(theEvent: NSEvent) {
        let menu = self.menuForEvent(theEvent)
        NSMenu.popUpContextMenu(menu!, withEvent: theEvent, forView: self)
    }
    
    override func menuForEvent(event: NSEvent) -> NSMenu? {
        let menu = super.menuForEvent(event)
        
        var i = 0
        while let field = SortableField(rawValue: i) {
            if let title = SortableField.stringForField(field) {
                let item = NSMenuItem(title: title, action: Selector("test:"), keyEquivalent: "")
                menu?.addItem(item)
            }
            i++
        }
        
        return menu
    }
    
    func test(sender: AnyObject?) {
        println("clicked the test button, \(sender)")
    }
}
