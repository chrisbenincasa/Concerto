//
//  COMetadata.swift
//  Concerto
//
//  Created by Christian Benincasa on 10/13/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Cocoa
import AVFoundation

enum COMetadataKey {
    case SongTitle
    case SongTrackNumber
    case SongReleaseDate
    case SongDuration
    case SongBeatsPerMinute
    case SongYear
    case ArtistName
    case AlbumName
}

class COMetadata: NSObject {

    var asset: AVURLAsset
    var metadataDictionary: [COMetadataKey : AnyObject] = [:]
    var commonArray: [AnyObject]
    lazy var id3Array: [AnyObject] = loadMetadataForFormat(self)(AVMetadataFormatID3Metadata)
    lazy var iTunesArray: [AnyObject] = loadMetadataForFormat(self)(AVMetadataFormatiTunesMetadata)
    
    private func loadMetadataForFormat(format: String) -> [AnyObject] {
        return self.asset.metadataForFormat(format)
    }
    
    init(url: NSURL) {
        self.asset = AVURLAsset(URL: url, options: nil)
        self.commonArray = self.asset.commonMetadata
    }
    
    convenience init(path: NSString) {
        let url = NSURL(string: path)
        self.init(url: url!)
    }
    
    // MARK: Song metadata
    
    func trackName() -> String? {
        if let tname: AnyObject = metadataDictionary[.SongTitle] {
            return tname as? String
        } else {
            let tname = self.getFilteredMetadata(AVMetadataCommonIdentifierTitle, AVMetadataIdentifierID3MetadataTitleDescription, AVMetadataIdentifieriTunesMetadataSongName)?.stringValue
            
            if tname != nil {
                metadataDictionary[.SongTitle] = tname!
            }
            
            return tname
        }
    }
    
    func trackNumber() -> Int? {
        if let num: AnyObject = metadataDictionary[.SongTrackNumber] {
            return num as? Int
        } else {
            let num = self.getFilteredMetadata(nil, AVMetadataIdentifierID3MetadataTrackNumber, AVMetadataIdentifieriTunesMetadataTrackNumber)
            
            let valueToReturn: Int? = {
                if let trackStr = num?.stringValue {
                    let split = trackStr.componentsSeparatedByString("/").first.getOrElse(trackStr)
                    return split.toInt()
                } else if let trackNum = num?.numberValue as? Int {
                    return trackNum
                }
                
                return nil
            }()
            
            if valueToReturn != nil {
                metadataDictionary[.SongTitle] = valueToReturn
            }
            
            return valueToReturn
        }
    }
    
    func duration() -> Int? {
        if let num: AnyObject = metadataDictionary[.SongTrackNumber] {
            return num as? Int
        } else {
            var x: [AnyObject] = self.commonArray
            x.extend(self.id3Array)
            x.extend(self.iTunesArray)
            
            let d = (x.first as? AVMetadataItem).map({ $0.duration })
            
            return d.map({ (duration: CMTime) -> Int in
                println(duration.value, duration.timescale)
                let time: Int = Int(duration.value)
                self.metadataDictionary[.SongDuration] = time
                return time
            })
        }
    }
    
    func releaseDate() -> NSDate? {
        if let num: AnyObject = metadataDictionary[.SongTitle] {
            return num as? NSDate
        } else {
            return self.getFilteredMetadata(nil, AVMetadataIdentifierID3MetadataReleaseTime, AVMetadataIdentifieriTunesMetadataReleaseDate).map { [unowned self] (item: AVMetadataItem) -> NSDate in
                let dateValue = item.dateValue
                self.metadataDictionary[.SongReleaseDate] = dateValue
                return dateValue
            }
        }
    }
    
    func year() -> Int? {
        if let year: AnyObject = metadataDictionary[.SongYear] {
            return year as? Int
        } else {
            return self.getFilteredMetadata(nil, AVMetadataIdentifierID3MetadataReleaseTime, AVMetadataIdentifieriTunesMetadataReleaseDate).map { [unowned self] (item: AVMetadataItem) -> Int in
                let year = item.numberValue as Int
                self.metadataDictionary[.SongYear] = year
                return year
            }
        }
    }
    
    func bitRate() -> Int? {
        return nil // TODO implement this
    }
    
    func beatsPerMinute() -> Int? {
        if let bpm: AnyObject = metadataDictionary[.SongBeatsPerMinute] {
            return bpm as? Int
        } else {
            return self.getFilteredMetadata(nil, AVMetadataIdentifierID3MetadataBeatsPerMinute, AVMetadataIdentifieriTunesMetadataBeatsPerMin).map { [unowned self] (item: AVMetadataItem) -> Int in
             
                let bpm = item.numberValue as Int
                self.metadataDictionary[.SongBeatsPerMinute] = bpm
                return bpm
            }
        }
    }
    
    // MARK: Artist metadata
    
    func artistName() -> String? {
        if let artist: AnyObject = metadataDictionary[.ArtistName] {
            return artist as? String
        } else {
            return self.getFilteredMetadata(AVMetadataCommonIdentifierArtist, AVMetadataIdentifierID3MetadataOriginalArtist, AVMetadataIdentifieriTunesMetadataArtist).map { [unowned self] (item: AVMetadataItem) -> String in
                let artist = item.stringValue
                self.metadataDictionary[.ArtistName] = artist
                return artist
            }
        }
    }
    
    // MARK: Album metadata
    
    func albumName() -> String? {
        if let artist: AnyObject = metadataDictionary[.AlbumName] {
            return artist as? String
        } else {
            return self.getFilteredMetadata(AVMetadataCommonIdentifierAlbumName, AVMetadataIdentifierID3MetadataAlbumTitle, AVMetadataIdentifieriTunesMetadataAlbum).map { [unowned self] (item: AVMetadataItem) -> String in
                let album = item.stringValue
                self.metadataDictionary[.AlbumName] = album
                return album
            }
        }
    }
    
    private func getFilteredMetadata(commonIdentifier: String?, _ id3Identifier: String?, _ iTunesIdentifier: String?) -> AVMetadataItem? {
        if let cid = commonIdentifier {
            let item = AVMetadataItem.metadataItemsFromArray(commonArray, filteredByIdentifier: cid).first as? AVMetadataItem
            if (item != nil) {
                return item
            }
        }
        
        if let id3 = id3Identifier {
            let item = AVMetadataItem.metadataItemsFromArray(id3Array, filteredByIdentifier: id3).first as? AVMetadataItem
            if (item != nil) {
                return item
            }
        }
        
        if let itunes = iTunesIdentifier {
            let item = AVMetadataItem.metadataItemsFromArray(iTunesArray, filteredByIdentifier: itunes).first as? AVMetadataItem
            if (item != nil) {
                return item
            }
        }
        
        return nil
    }
}
