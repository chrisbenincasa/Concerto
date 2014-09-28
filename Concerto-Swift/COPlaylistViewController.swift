//
//  COPlaylistViewController.swift
//  Concerto-Swift
//
//  Created by Christian Benincasa on 9/21/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Foundation
import Cocoa

class COPlaylistViewController : COViewController, COPlayQueueDelegate {
    
    @IBOutlet weak var playlistTable: NSTableView?
    @IBOutlet weak var pauseButton: NSButton?
    @IBOutlet weak var nextButton: NSButton?
    @IBOutlet weak var prevButton: NSButton?
    @IBOutlet weak var currentTime: NSTextField?
    @IBOutlet weak var totalTime: NSTextField?
    @IBOutlet weak var repeatCheckbox: NSButton?
    @IBOutlet weak var currentlyPlayingTitle: NSTextField?
    
    let playQueue = COPlayQueue.sharedInstance
    
    override init() {
        super.init()
        commonInitTasks()
    }
    
    override init(coder: NSCoder!) {
        super.init(coder: coder)
        commonInitTasks()
    }
    
    private func commonInitTasks() {
        playQueue.addDelegate(self)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "queueSongsDidChange:", name: nil, object: playQueue)
    }
    
    @IBAction func togglePlay(sender: AnyObject) {
        if playQueue.playing {
            playQueue.pause()
        } else {
            playQueue.resume()
        }
    }
    
    @IBAction func next(sender: AnyObject) {
        playQueue.next()
    }
    
    @IBAction func previous(sender: AnyObject) {
        playQueue.previous()
    }
    
    @IBAction func setRepeat(sender: AnyObject) {
        playQueue.repeat = !playQueue.repeat
    }
    
    @IBAction func toggleRepeat(sender: AnyObject) {
        if let button = sender as? NSButton {
            playQueue.repeat = button.state == NSOnState
        }
    }
    
    func queueDidStartPlaying(song: COSong) {
//        assert(NSThread.isMainThread())
        currentlyPlayingTitle?.stringValue = song.name
    }
    
    func queueSongsDidChange(notification: NSNotification) {
        playlistTable?.reloadData()
    }
}