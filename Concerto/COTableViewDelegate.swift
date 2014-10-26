//
//  COTableView.swift
//  Concerto
//
//  Created by Christian Benincasa on 9/21/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import AppKit
import Cocoa
import AVFoundation

class COTableViewDelegate : NSObject, NSTableViewDelegate, NSTableViewDataSource {
    private let rowIdentifier = "COTableRowView"
    
    @IBOutlet weak var myTableView: NSTableView!
    dynamic var somethingSelected: Bool = false
    
    let playQueue = COPlayQueue.sharedInstance
    var selectedRow: Int? = nil
    
    override func awakeFromNib() {
        myTableView.target = self
        myTableView.doubleAction = "onDoubleClick:"
        myTableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyle.Regular
    }
    
    func tableView(tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        var view = tableView.makeViewWithIdentifier(rowIdentifier, owner: self) as COTableRowView?
        if (view == nil) {
            view = COTableRowView()
            view!.identifier = rowIdentifier
        }
        
        return view
    }
    
    func tableView(tableView: NSTableView!, sortDescriptorsDidChange oldDescriptors: [AnyObject]!) {
        println(oldDescriptors)
    }
    
    func onDoubleClick(sender: AnyObject!) {
        if myTableView.clickedRow >= 0 {
            COPlayQueue.sharedInstance.play(index: myTableView.clickedRow)
        }
    }
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        // TODO send notification to update metadata window
        
        return true
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        self.somethingSelected = true
    }
}