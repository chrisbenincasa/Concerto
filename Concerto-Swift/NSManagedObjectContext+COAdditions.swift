//
//  NSManagedObjectContext+COAdditions.swift
//  Concerto-Swift
//
//  Created by Christian Benincasa on 9/21/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Foundation
import Cocoa
import CoreData

struct ConcertoEntity {
    static let Song = "Song"
    static let Artist = "Artist"
}

extension NSManagedObjectContext {
    func createEntity<T : NSManagedObject>(entityName: String) -> T {
        return NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: self) as T
    }
    
    // TODO change to generic function when Swift compiler can handle it
    // It doesn't like generics inside of NSObject subclasses as well as 
    // generics which are constrained by NSObject
    func fetchObjects(entityName: String, limit: Int) -> NSArray {
        let fetchRequest = NSFetchRequest()
        var error: NSError?
        fetchRequest.entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: self)
        fetchRequest.shouldRefreshRefetchedObjects = true
        let objs = self.executeFetchRequest(fetchRequest, error: &error)
        
        if error != nil {
            println("SO SCREWED")
        }
        
        if let fetched = objs {
            return fetched
        } else {
            return []
        }
    }
    
    func artistWithName(name: String, create: Bool) -> COArtist? {
        // TODO normalize name
        let fetched = fetchObjects(ConcertoEntity.Artist, limit: 1) as [COArtist]
        if fetched.isEmpty {
            if create {
                let artist: COArtist = createEntity(ConcertoEntity.Artist)
                artist.name = name
                return artist
            } else {
                return nil
            }
        } else {
            return fetched.first
        }
    }
}