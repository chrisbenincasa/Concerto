//
//  COSong.swift
//  Concerto
//
//  Created by Christian Benincasa on 10/19/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Foundation
import CoreData

class COSong: NSManagedObject {

    @NSManaged var bitRate: NSNumber
    @NSManaged var bookmark: NSData
    @NSManaged var bpm: NSNumber
    @NSManaged var comment: String
    @NSManaged var composer: String
    @NSManaged var dateAdded: NSDate
    @NSManaged var duration: NSNumber
    @NSManaged var fileType: String
    @NSManaged var playCount: NSNumber
    @NSManaged var releaseDate: NSDate
    @NSManaged var title: String
    @NSManaged var trackNumber: NSNumber
    @NSManaged var year: NSNumber
    @NSManaged var album: COAlbum
    @NSManaged var artist: COArtist
    @NSManaged var playlists: NSSet
    @NSManaged var tags: NSSet

}
