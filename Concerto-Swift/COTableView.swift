//
//  COTableView.swift
//  Concerto-Swift
//
//  Created by Christian Benincasa on 9/21/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Foundation
import Cocoa
import AVFoundation

class COTableView : NSObject, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet weak var myTableView: NSTableView!
    let playQueue = COPlayQueue.sharedInstance
    
    override func awakeFromNib() {
        myTableView.target = self
        myTableView.doubleAction = "onDoubleClick:"
    }
    
    func numberOfRowsInTableView(aTableView: NSTableView!) -> Int {
        return playQueue.songs.count
    }

    func tableView(tableView: NSTableView!, viewForTableColumn tableColumn: NSTableColumn!, row: Int) -> NSView! {
        let oCell: NSTableCellView? = tableView.makeViewWithIdentifier(tableColumn.identifier, owner: self) as? NSTableCellView
        
        if let cell = oCell {
            let value: COSong = playQueue.songs[row]
            switch tableColumn.identifier {
                case "Name":
                    cell.textField.stringValue = value.name
                    break
                case "Artist":
                    cell.textField.stringValue = value.artist.name
                    break
                default: break
            }
            return cell
        } else {
            return nil
        }
    }
    
    func tableView(tableView: NSTableView!, sortDescriptorsDidChange oldDescriptors: [AnyObject]!) {
        println(oldDescriptors)
    }
    
    func onDoubleClick(sender: AnyObject!) {
        if myTableView.clickedRow >= 0 {
            COPlayQueue.sharedInstance.play(index: myTableView.clickedRow)
        }
    }
}