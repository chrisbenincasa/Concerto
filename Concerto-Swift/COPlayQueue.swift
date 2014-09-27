//
//  COPlayQueue.swift
//  Concerto-Swift
//
//  Created by Christian Benincasa on 9/21/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Foundation
import AVFoundation

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
    
    override init() {
        self.songs = []
        self.playing = false
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
        if songs.count == 0 {
            println("queue is empty!!")
            return
        }
        
        if index == currentIndex && self.playing {
            return
        }
        
        assert(index >= 0, "Index cannot be less than zero")
        assert(index < songs.count, "Index out of bounds")
        
        // Get the next song to play
        let songToPlay = songs[index]
        currentIndex = index
        
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
            addPendingItem(next)
        }
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
    
    func next() {
        if currentIndex == self.songs.count - 1 && !self.repeat {
            currentPlayer?.stop()
            return
        }
        
        if let pending = pendingPlayer {
            if self.playing {
                pending.play()
            }
            currentPlayer = pending
            currentPlayer!.delegate = self
            pendingPlayer = nil
            println("playing song at index \(currentIndex) -- \(pendingPlayer?.url)")
        } else {
            // there is no pending player
//            currentPlayer?.stop()
            
        }
        
        currentIndex++
        if currentIndex >= self.songs.count {
            currentIndex = 0;
        }
        
        let nextIndex = currentIndex + 1
        
        println("repeat? = \(self.repeat)")
        if nextIndex < self.songs.count {
            addPendingItem(songs[nextIndex])
        } else if nextIndex >= self.songs.count && self.repeat {
            println("looped back")
            addPendingItem(songs.first!)
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
    
    private func addPendingItem(item: COSong) {
        pendingPlayer = AVAudioPlayer(contentsOfURL: NSURL(string: item.url), error: nil)
        pendingPlayer!.delegate = self
        pendingPlayer!.prepareToPlay()
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        println("done!")
    }
}