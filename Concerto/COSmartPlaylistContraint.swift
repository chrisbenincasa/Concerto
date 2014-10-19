//
//  COSmartPlaylistContraint.swift
//  Concerto
//
//  Created by Christian Benincasa on 10/19/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Foundation
import CoreData

class COSmartPlaylistContraint: NSManagedObject {

    @NSManaged var constraint: NSData
    @NSManaged var playlist: COSmartPlaylist

}
