//
//  COArtist+Additions.swift
//  Concerto
//
//  Created by Christian Benincasa on 10/12/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Cocoa

extension COArtist {
    func addAlbum(album: COAlbum) {
        withChangeBlock("albums", f: { () -> Void in
            let albums = self.mutableSetValueForKey("albums")
            albums.addObject(album)
            self.albums = albums
        })
    }
    
    func addSong(song: COSong) {
        withChangeBlock("songs", f: { () -> Void in
            let songs = self.mutableSetValueForKey("songs")
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
