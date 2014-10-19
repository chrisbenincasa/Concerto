//
//  COTag.swift
//  Concerto
//
//  Created by Christian Benincasa on 10/19/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Foundation
import CoreData

class COTag: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var albums: COAlbum
    @NSManaged var playlists: COPlaylist
    @NSManaged var songs: NSSet

}
