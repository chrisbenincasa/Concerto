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
        self.willChangeValueForKey("albums")
        let albums = album.mutableSetValueForKey("albums")
        albums.addObject(album)
        self.didChangeValueForKey("albums")
    }
}
