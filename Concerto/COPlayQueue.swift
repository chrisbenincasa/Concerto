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

class COPlayQueue : NSObject, AVAudioPlayerDelegate {
    class var sharedInstance : COPlayQueue {
        struct Static {
            static let instance: COPlayQueue = COPlayQueue()
        }
        
        return Static.instance
    }
    
    var songs: [COSong]
    var currentIndex = 0;
    var currentPlayer: AVAudioPlayer?
    var pendingPlayer: AVAudioPlayer?
    var repeat: Bool = false
    var playing: Bool = false
    var observers: [COPlayQueueDelegate] = []
    
    override init() {
        self.songs = []
        self.playing = false
    }
    
    func addDelegate(d: COPlayQueueDelegate) {
        Utilities.log("Adding delegate to play queue \(d)")
        observers.append(d)
    }
    
    func removeDelegate(d: COPlayQueueDelegate) {
        observers = removeObjectIdenticalTo(d, fromArray: observers)
    }
    
    func playSongAtIndex(index: Int) {
        if index > songs.count {
            return
        }
        
        if index < 0 {
            return
        }
        
        self.play(index: index)
    }
    
    func insert(item: COSong, index: Int) {
        assert(index >= 0, "Index is less than zero")
        songs.insert(item, atIndex: index)
    }
    
    func insert(items: [COSong], index: Int) {
        for i in 0...items.count {
            self.insert(items[i], index: index + i)
        }
    }
    
    func enqueue(item: COSong) {
        self.insert(item, index: songs.count == 0 ? 0 : self.songs.count - 1)
    }
    
    func enqueue(items: [COSong]) {
        songs.extend(items)
    }
    
    func play(index: Int = 0) {
        // !. No songs to play, bail early
        if songs.count == 0 {
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
        assert(index < songs.count, "Index out of bounds")
        
        // Get the next song to play
        Utilities.log("Playing song at \(index)")
        let songToPlay = songs[index]
        currentIndex = index
        
        // TODO try to be smart and if we're requesting currentIndex + 1, just swap
        currentPlayer = AVAudioPlayer(contentsOfURL: NSURL(string: songToPlay.url), error: nil)
        currentPlayer!.delegate = self
        currentPlayer!.play()
        currentIndex = index
        self.playing = true
        
        // Optionally, find the song that would play after that one
        var nextSong: COSong?
        
        if currentIndex + 1 < self.songs.count {
            nextSong = self.songs[currentIndex + 1]
        } else if currentIndex + 1 == self.songs.count && self.repeat {
            nextSong = self.songs.first
        }
        
        if let next = nextSong {
            Utilities.log("setting next to \(next.name)")
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
        if currentIndex == self.songs.count - 1 && !self.repeat {
            // If currently playing, stop the song
            self.stop()
            
            // Nil out current and pending (nothing should be playing or queued)
            currentPlayer = nil
            pendingPlayer = nil
            return
        }
        
        // 2. No player is queued, queue one
        if pendingPlayer == nil {
            let nextIndex = (currentIndex + 1) % self.songs.count
            addPendingItem(songs[nextIndex])
        }
        
        Utilities.log("current index =\(currentIndex), swapping players")
        let wasPlaying = self.playing
        
        // Swap pending with current
        self.stop()
        
        swapPendingPlayer(wasPlaying)
        
        currentIndex = (currentIndex + 1) % self.songs.count
        
        // try to set the next player
        if currentIndex + 1 >= self.songs.count {
            if self.repeat {
                addPendingItem(songs.first!)
            } else {
                pendingPlayer = nil
            }
        } else {
            addPendingItem(songs[currentIndex + 1])
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
    
    func previous() {
        if self.playing {
            if currentPlayer!.currentTime < 10.0 {
                play(index: currentIndex - 1)
            } else {
                currentPlayer!.currentTime = 0.0
            }
        }
    }
    
    private func addPendingItem(item: COSong) {
        pendingPlayer = AVAudioPlayer(contentsOfURL: NSURL(string: item.url), error: nil)
        pendingPlayer!.delegate = self
        pendingPlayer!.prepareToPlay()
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        if pendingPlayer != nil {
            swapPendingPlayer(true)
        } else {
            if currentIndex + 1 >= self.songs.count {
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
}

// NSTableViewDataSource extensions
extension COPlayQueue : NSTableViewDataSource {
    func numberOfRowsInTableView(aTableView: NSTableView!) -> Int {
        return self.songs.count
    }
    
    func tableView(tableView: NSTableView!, objectValueForTableColumn tableColumn: NSTableColumn!, row: Int) -> AnyObject! {
        return self.songs[row]
    }
}
