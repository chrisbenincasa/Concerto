//
//  COAlbum+Extensions.swift
//  Concerto
//
//  Created by Christian Benincasa on 10/21/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Cocoa

extension COAlbum {

    func addSong(song: COSong) {
        withChangeBlock("songs", f: { () -> Void in
            let songs = self.mutableOrderedSetValueForKey("songs")
            songs.addObject(song)
            self.songs = songs
        })
    }
    
    private func withChangeBlock<T>(key: String, f: () -> T) -> T {
        self.willChangeValueForKey(key)
        let result = f()
        self.didChangeValueForKey(key)
        return result
    }
}
