//
//  COSong+Extensions.swift
//  Concerto-Swift
//
//  Created by Christian Benincasa on 9/28/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Cocoa
import AVFoundation

extension COSong {    
    func setBookmarkFromPath(path: String) -> Bool {
        var error: NSError?
        let url = NSURL.fileURLWithPath(path, isDirectory: false)
        
        if url == nil {
            println("unable to make URL from path \(path)")
            return false
        }
        
        let bookmark = url?.bookmarkDataWithOptions(.MinimalBookmark, includingResourceValuesForKeys: nil, relativeToURL: nil, error: &error)
        
        if error != nil || bookmark == nil {
            println("error creating the bookmark from path \(path)")
            return false
        }
        
        self.bookmark = bookmark!
        
        return true
    }
    
    func url() -> NSURL? {
        if self.bookmark.length > 0 {
            var error: NSError?
            let url = NSURL(byResolvingBookmarkData: self.bookmark, options: .WithoutUI, relativeToURL: nil, bookmarkDataIsStale: nil, error: &error)
            
            if let returnedErr = error {
                println("error while attempting to resolve bookmark from song: \(returnedErr), \(returnedErr.userInfo)")
                return nil
            }
            
            return url
        }
        
        return nil
    }
}
