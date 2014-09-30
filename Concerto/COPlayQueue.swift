//
//  COPlayQueue.swift
//  Concerto-Swift
//
//  Created by Christian Benincasa on 9/21/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Foundation
import Cocoa
import AVFoundation

@objc protocol COPlayQueueDelegate : class {
    optional func queueDidStartPlaying(song: COSong)
    optional func queueDidChangeSongs(newSong: COSong, lastSong: COSong?)
}

struct COPlayQueueNotifications {
    static let SongsAdded = "SongsAdded"
}

class COPlayQueue : NSObject, AVAudioPlayerDelegate {
    class var sharedInstance : COPlayQueue {
        struct Static {
            static let instance: COPlayQueue = COPlayQueue()
        }
        
        return Static.instance
    }
    
    var songSet: NSMutableOrderedSet
    var currentIndex = 0;
    var currentPlayer: AVAudioPlayer?
    var pendingPlayer: AVAudioPlayer?
    var repeat: Bool = false
    var playing: Bool = false
    var observers: [COPlayQueueDelegate] = []
    
    override init() {
        self.playing = false
        self.songSet = NSMutableOrderedSet()
    }
    
    func addDelegate(d: COPlayQueueDelegate) {
        Utilities.log("Adding delegate to play queue \(d)")
        observers.append(d)
    }
    
    func removeDelegate(d: COPlayQueueDelegate) {
        observers = removeObjectIdenticalTo(d, fromArray: observers)
    }
    
     func insert(item: COSong, index: Int) {
        assert(index >= 0, "Index is less than zero")
        let previousCount = self.songSet.count
        songSet.insertObject(item, atIndex: index)
        if (previousCount != self.songSet.count) {
            let key = previousCount > self.songSet.count ? "added" : "removed"
            self.emitNotification(COPlayQueueNotifications.SongsAdded, object: self, userInfo: [key : [item]])
        }
    }
    
    func insert(items: [COSong], index: Int) {
        assert(index >= 0, "Index is less than zero")
        let previousCount = self.songSet.count
        let range = NSRange(Range<Int>(start: index, end: index + items.count))
        songSet.insertObjects(items, atIndexes: NSIndexSet(indexesInRange: range))
        if (previousCount != self.songSet.count) {
            let key = previousCount > self.songSet.count ? "added" : "removed"
            self.emitNotification(COPlayQueueNotifications.SongsAdded, object: self, userInfo: [key : items])
        }
    }
    
    func enqueue(item: COSong) {
        self.insert(item, index: self.songSet.count == 0 ? 0 : self.songSet.count - 1)
    }
    
    func enqueue(items: [COSong]) {
        let previousCount = self.songSet.count
        self.insert(items, index: self.songSet.count == 0 ? 0 : self.songSet.count - 1)
    }
    
    // MARK: Audio API
    func playSongAtIndex(index: Int) {
        if index > self.songSet.count {
            return
        }
        
        if index < 0 {
            return
        }
        
        self.play(index: index)
    }
    
    func play(index: Int = 0) {
        // !. No songs to play, bail early
        if self.songSet.count == 0 {
            Utilities.log("queue is empty!!")
            return
        }
        
        // If we're already playing the specified index, exit
        // TODO if the order changes, take this check away
        if index == currentIndex && self.playing {
            Utilities.log("already playing this song")
            return
        }
        
        // Check basic truths about the requested index
        assert(index >= 0, "Index cannot be less than zero")
        assert(index < self.songSet.count, "Index out of bounds")
        
        // Get the next song to play
        Utilities.log("Playing song at \(index)")
        let songToPlay = self.songSet[index] as COSong
        currentIndex = index
        
        // TODO try to be smart and if we're requesting currentIndex + 1, just swap
        currentPlayer = AVAudioPlayer(contentsOfURL: songToPlay.url()!, error: nil)
        currentPlayer!.delegate = self
        currentPlayer!.play()
        currentIndex = index
        self.playing = true
        
        // Optionally, find the song that would play after that one
        var nextSong: COSong?
        
        if currentIndex + 1 < self.songSet.count {
            nextSong = self.songSet[currentIndex + 1] as? COSong
        } else if currentIndex + 1 == self.songSet.count && self.repeat {
            nextSong = self.songSet.firstObject as? COSong
        }
        
        if let next = nextSong {
            Utilities.log("setting next to \(next.title)")
            addPendingItem(next)
        }
        
        observers.foreach { $0.queueDidStartPlaying!(songToPlay) }
    }
    
    func pause() {
        if self.playing && currentPlayer != nil {
            currentPlayer!.pause()
            self.playing = false
        }
    }
    
    func resume() {
        if !self.playing && currentPlayer != nil {
            currentPlayer!.play()
            self.playing = true
        }
    }
    
    func stop() {
        if self.playing && currentPlayer != nil {
            currentPlayer!.stop()
            self.playing = false
        }
    }
    
    func next() {
        // 1. Hit next, not on repeat mode
        if currentIndex == self.songSet.count - 1 && !self.repeat {
            // If currently playing, stop the song
            self.stop()
            
            // Nil out current and pending (nothing should be playing or queued)
            currentPlayer = nil
            pendingPlayer = nil
            return
        }
        
        // 2. No player is queued, queue one
        if pendingPlayer == nil {
            let nextIndex = (currentIndex + 1) % self.songSet.count
            addPendingItem(self.songSet[nextIndex] as COSong)
        }
        
        Utilities.log("current index =\(currentIndex), swapping players")
        let wasPlaying = self.playing
        
        // Swap pending with current
        self.stop()
        
        swapPendingPlayer(wasPlaying)
        
        currentIndex = (currentIndex + 1) % self.songSet.count
        
        // try to set the next player
        if currentIndex + 1 >= self.songSet.count {
            if self.repeat {
                addPendingItem(self.songSet.firstObject as COSong)
            } else {
                pendingPlayer = nil
            }
        } else {
            addPendingItem(self.songSet[currentIndex + 1] as COSong)
        }
    }
    
    func previous() {
        if self.playing {
            if currentPlayer!.currentTime < 10.0 {
                play(index: currentIndex - 1)
            } else {
                currentPlayer!.currentTime = 0.0
            }
        }
    }
    
    // MARK: AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        if pendingPlayer != nil {
            swapPendingPlayer(true)
        } else {
            if currentIndex + 1 >= self.songSet.count {
                if self.repeat {
                    play(index: 0)
                } else {
                    currentPlayer = nil
                    pendingPlayer = nil
                }
            } else {
                play(index: currentIndex + 1)
            }
        }
    }
    
    private func swapPendingPlayer(shouldPlay: Bool) {
        assert(pendingPlayer != nil)
        
        // Swap the two players
        Utilities.log("swapping players -- pending URL: \(pendingPlayer!.url.absoluteString), should play=\(shouldPlay)")
        currentPlayer = pendingPlayer
        
        // If we should play, start playing the current (previously pending) player
        if shouldPlay {
            self.resume()
        }
        
        // Set the current player delegate to ourselves
        currentPlayer!.delegate = self
        
        // Nil out the pending player
        pendingPlayer = nil
    }
    
    private func addPendingItem(item: COSong) {
        pendingPlayer = AVAudioPlayer(contentsOfURL: item.url()!, error: nil)
        pendingPlayer!.delegate = self
        pendingPlayer!.prepareToPlay()
    }
    
    private func emitNotification(name: String, object: AnyObject?, userInfo: [NSObject : AnyObject]? = nil) {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        let notification = NSNotification(name: name, object: object, userInfo: userInfo)
        println("Emiiting notification")
        notificationCenter.postNotification(notification)
    }
}

// NSTableViewDataSource extensions
extension COPlayQueue : NSTableViewDataSource {
    func numberOfRowsInTableView(aTableView: NSTableView!) -> Int {
        return self.songSet.count
    }
    
    func tableView(tableView: NSTableView!, objectValueForTableColumn tableColumn: NSTableColumn!, row: Int) -> AnyObject! {
        return self.songSet[row]
    }
}
