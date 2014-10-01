//
//  COPlaylistViewController.swift
//  Concerto-Swift
//
//  Created by Christian Benincasa on 9/21/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Cocoa

class COPlaylistViewController : COViewController, COPlayQueueDelegate {
    
    // MARK: Data Access
    var managedObjectContext: NSManagedObjectContext? = nil {
        didSet {
            self.arrayController.managedObjectContext = self.managedObjectContext
        }
    }
    
    @IBOutlet var arrayController: NSArrayController! = nil
    @IBOutlet var sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor(key: "title", ascending: true)] {
        didSet {
            println(self.sortDescriptors as NSArray)
        }
    }
    
    // MARK: IBOutlets
    @IBOutlet weak var playlistTable: NSTableView?
    @IBOutlet weak var pauseButton: NSButton?
    @IBOutlet weak var nextButton: NSButton?
    @IBOutlet weak var prevButton: NSButton?
    @IBOutlet weak var currentTime: NSTextField?
    @IBOutlet weak var totalTime: NSTextField?
    @IBOutlet weak var repeatCheckbox: NSButton?
    @IBOutlet weak var currentlyPlayingTitle: NSTextField?
    @IBOutlet weak var songThing: NSTextField?
    @IBOutlet weak var songThing2: NSTextField?
    
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
        currentlyPlayingTitle?.stringValue = song.title
    }
    
    func queueSongsDidChange(notification: NSNotification) {
        playlistTable?.reloadData()
    }
    
    func reloadData() {
        if let context = self.managedObjectContext {
            self.arrayController.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)] as NSArray
            self.arrayController.fetch(nil)
        } else {
            println("don't have a managed object context...this is really bad")
        }
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        switch keyPath {
        case "arrangedObjects":
            let prettyPrintObjects = (self.arrayController.arrangedObjects as [COSong])
            let titles = prettyPrintObjects.map({ (song: COSong) -> String in return song.title })
            playQueue.enqueue(self.arrayController.arrangedObjects as [COSong])
            break
        default: break
        }
    }
}