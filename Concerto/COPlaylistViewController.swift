//
//  COPlaylistViewController.swift
//  Concerto
//
//  Created by Christian Benincasa on 9/21/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import AppKit
import Cocoa

class COPlaylistViewController : COViewController, COPlayQueueDelegate {
    
    // MARK: Data Access
    var managedObjectContext: NSManagedObjectContext? {
        didSet {
            self.arrayController.managedObjectContext = self.managedObjectContext
        }
    }
    
    @IBOutlet var arrayController: NSArrayController! = nil
    
    @IBOutlet var sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor(key: "trackNumber", ascending: true), NSSortDescriptor(key: "artist.name", ascending: true)] {
        willSet(descriptors) {
            println("setting \(descriptors as NSArray) as new sort descriptors")
        }
        
        didSet {
            println(self.sortDescriptors as NSArray)
        }
    }
    
    // MARK: IBOutlets
    @IBOutlet weak var playlistTable: NSTableView?
    @IBOutlet weak var pauseButton: NSButton?
    @IBOutlet weak var nextButton: NSButton?
    @IBOutlet weak var prevButton: NSButton?
    @IBOutlet weak var playlistButton: NSButton?
    @IBOutlet weak var currentTime: NSTextField?
    @IBOutlet weak var totalTime: NSTextField?
    @IBOutlet weak var repeatCheckbox: NSButton?
    @IBOutlet weak var currentlyPlayingTitle: NSTextField?
    
    // MARK: Misc. objects
    let playQueue = COPlayQueue.sharedInstance

    // MARK: init and deinit
    override init() {
        super.init()
        commonInitTasks()
    }
    
    override init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInitTasks()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        // TODO remove KVO
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.arrayController.addObserver(self, forKeyPath: "arrangedObjects", options: NSKeyValueObservingOptions.New | NSKeyValueObservingOptions.Old, context: nil)
    }
    
    private func commonInitTasks() {
        playQueue.addDelegate(self)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "queueSongsDidChange:", name: nil, object: playQueue)
    }
    
    // MARK: Playlist functions
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
    
    @IBAction func showUpcomingSongs(sender: AnyObject) {
        // TODO replace with a custom menu view
        let event = NSApplication.sharedApplication().currentEvent
        NSMenu.popUpContextMenu(self.playlistButton!.menu!, withEvent: event!, forView: self.view)
    }
    
    // MARK: Call back listeners
    func queueDidStartPlaying(song: COSong) {
        currentlyPlayingTitle?.stringValue = song.title
    }
    
    func queueSongsDidChange(notification: NSNotification) {
        self.reloadData()
    }
    
    @IBAction func openGetInfoWindow(sender: AnyObject) {
        if let table = playlistTable {
            let thing = COPreferencesWindowController(windowNibName: "Preferences")
        }
    }
    
    func reloadData() {
        if let context = self.managedObjectContext {
            self.arrayController.sortDescriptors = self.sortDescriptors
            self.arrayController.fetch(nil)
        } else {
            println("don't have a managed object context...this is really bad")
        }
    }

    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        switch keyPath {
        case "arrangedObjects":
            playQueue.enqueue(self.arrayController.arrangedObjects as [COSong])
            break
        default: break
        }
    }
}