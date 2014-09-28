//
//  COMainMenuController.swift
//  Concerto-Swift
//
//  Created by Christian Benincasa on 9/27/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Foundation
import Cocoa
import AVFoundation

class COMainMenuController {
    
    @IBAction func openFile(sender: AnyObject!) {
        let panel: NSOpenPanel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        if NSFileHandlingPanelOKButton == panel.runModal() {
            let urls: NSArray = panel.URLs
            
            if let urlArr = urls as? [NSURL] {
                let songs = urlArr.map({ (url: NSURL) -> COSong in
                    let s = COSong()
                    let a = COArtist()
                    
                    let asset = AVURLAsset(URL: url, options: nil)
                    let titles = AVMetadataItem.metadataItemsFromArray(asset.commonMetadata, withKey: AVMetadataCommonKeyTitle, keySpace: AVMetadataKeySpaceCommon) as [AVMetadataItem]
                    let artists = AVMetadataItem.metadataItemsFromArray(asset.commonMetadata, withKey: AVMetadataCommonKeyArtist, keySpace: AVMetadataKeySpaceCommon) as [AVMetadataItem]
                    
                    s.artist = a
                    
                    if let title = titles.first {
                        s.name = title.stringValue
                    }
                    if let artist = artists.first {
                        a.name = artist.stringValue
                    }
                    
                    s.url = url.absoluteString!
                    return s
                })
                
                COPlayQueue.sharedInstance.enqueue(songs)
//                if let tv = tableSource.myTableView {
//                    tv.reloadData()
//                }
            }
        }
    }

}