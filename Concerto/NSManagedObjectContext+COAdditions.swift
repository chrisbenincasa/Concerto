//
//  NSManagedObjectContext+COAdditions.swift
//  Concerto-Swift
//
//  Created by Christian Benincasa on 9/21/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Cocoa

struct ConcertoEntity {
    static let Song = "Song"
    static let Artist = "Artist"
    static let Album = "Album"
    static let Tag = "Tag"
}

extension NSManagedObjectContext {
    func createEntity<T : NSManagedObject>(entityName: String, shouldInsert: Bool = false) -> T {
        if shouldInsert {
            return NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: self) as T
        } else {
            let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: self)
            return T(entity: entity!, insertIntoManagedObjectContext: nil)
        }
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
            return []
        }
        
        if let fetched = objs {
            return fetched
        } else {
            return []
        }
    }
    
    func fetchObjects(entityName: String, sort: [NSSortDescriptor], predicate: NSPredicate, limit: Int) -> [AnyObject] {
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: self)
        fetchRequest.sortDescriptors = sort
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = limit
        fetchRequest.shouldRefreshRefetchedObjects = true
        var error: NSError?
        
        let fetchedObjects = self.executeFetchRequest(fetchRequest, error: &error)
        
        if error != nil {
            println("ERROR FETCHING THING")
            return []
        }
        
        if fetchedObjects.isEmpty() {
            return []
        }
        
        return fetchedObjects!
    }
    
    func firstObject<T : AnyObject>(entityName: String, sort: [NSSortDescriptor], predicate: NSPredicate) -> T? {
        return fetchObjects(entityName, sort: sort, predicate: predicate, limit: 1).first as T?
    }
    
    func songWithMetadata(title: String, artist: String?, album: String?, create: Bool) -> COSong? {
        let titlePred = NSPredicate(format: "title == %s", title)
        var subpredicates: [NSPredicate] = [titlePred!]
        
        if let a = artist {
            let predicate = NSPredicate(format: "artist.name == %s", a)
            subpredicates.append(predicate!)
        }
        if let a = album {
            let predicate = NSPredicate(format: "album.name == %s", a)
            subpredicates.append(predicate!)
        }
        
        let predicate = NSCompoundPredicate.andPredicateWithSubpredicates(subpredicates)
        
        let existingSong: COSong? = firstObject(ConcertoEntity.Song, sort: [], predicate: predicate)
        
        if existingSong == nil && create {
            return createEntity(ConcertoEntity.Song, shouldInsert: true) as COSong
        } else {
            return existingSong
        }
    }
    
    func artistWithName(name: String?, create: Bool) -> COArtist? {
        // TODO normalize name
        let normalizedName: String = name.getOrElse("Unknown Artist")
        
        let predicate = NSPredicate(format: "name == %s", normalizedName)
        
        if let fetched = firstObject(ConcertoEntity.Artist, sort: [], predicate: predicate!) as COArtist? {
            return fetched
        } else {
            if create {
                return createEntity(ConcertoEntity.Artist, shouldInsert: true) as COArtist
            } else {
                return nil
            }
        }
    }
    
    func albumWithName(name: String?, create: Bool) -> COAlbum? {
        let normalizedName: String = name.getOrElse("Unknown Album")
        let predicate = NSPredicate(format: "name == %s", normalizedName)
        if let fetched = firstObject(ConcertoEntity.Album, sort: [], predicate: predicate!) as COAlbum? {
            return fetched
        } else {
            if create {
                return createEntity(ConcertoEntity.Album, shouldInsert: true) as COAlbum
            } else {
                return nil
            }
        }
    }
    
    func addOrUpdateRelationships(metadata: COMetadata) -> (COSong, COArtist, COAlbum) {
        let song = songWithMetadata(metadata.trackName().getOrElse("Unknown Title"), artist: metadata.artistName(), album: metadata.albumName(), create: false).getOrElse({() -> COSong in
            
            let s = self.createEntity(ConcertoEntity.Song, shouldInsert: true) as COSong
            s.updateSongMetadata(metadata)
            return s
        }())
        
        let artist = artistWithName(metadata.artistName(), create: false).getOrElse({() -> COArtist in
            let a = self.createEntity(ConcertoEntity.Artist, shouldInsert: true) as COArtist
            a.name = metadata.artistName()!
            return a
        }())
        
        let album = albumWithName(metadata.albumName(), create: false).getOrElse({() -> COAlbum in
            let a = self.createEntity(ConcertoEntity.Album, shouldInsert: true) as COAlbum
            a.name = metadata.albumName()!
            return a
        }())
        
        song.artist = artist
        song.album = album
        artist.addSong(song)
        artist.addAlbum(album)
        album.artist = artist
        album.addSong(song)
        
        return (song, artist, album)
    }
}