//
//  COMetadata.swift
//  Concerto
//
//  Created by Christian Benincasa on 10/13/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Cocoa
import AVFoundation

class COMetadata: NSObject {

    var asset: AVURLAsset
    var metadataDictionary: [String : AVMetadataItem] = [:]
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
        var artist = {
            self.getFilteredMetadata(AVMetadataCommonIdentifierTitle, id3Identifier: AVMetadataIdentifierID3MetadataTitleDescription, iTunesIdentifier: AVMetadataIdentifieriTunesMetadataSongName).orElse(
                self.getMetadataForKey(commonKey: AVMetadataCommonKeyTitle, ID3Key: AVMetadataID3MetadataKeyTitleDescription, iTunesKey: AVMetadataiTunesMetadataKeySongName)
            )
        }()
        
        return artist?.stringValue
    }
    
    func releaseDate() -> NSDate? {
        var date = {
            self.getFilteredMetadata(nil, id3Identifier: AVMetadataIdentifierID3MetadataReleaseTime, iTunesIdentifier: AVMetadataIdentifieriTunesMetadataReleaseDate).orElse(
                self.getMetadataForKey(ID3Key: AVMetadataID3MetadataKeyReleaseTime, iTunesKey: AVMetadataiTunesMetadataKeyReleaseDate, commonKey: nil)
            )
        }()
        
        return date?.dateValue
    }
    
    func year() -> Int? {
        var year = {
            self.getFilteredMetadata(nil, id3Identifier: AVMetadataIdentifierID3MetadataYear, iTunesIdentifier: AVMetadataIdentifieriTunesMetadataReleaseDate).orElse(
                self.getMetadataForKey(ID3Key: AVMetadataID3MetadataKeyYear, iTunesKey: AVMetadataiTunesMetadataKeyReleaseDate, commonKey: nil)
            )
        }()

        return year?.numberValue as? Int
    }
    
    func bitRate() -> Int? {
        return nil // TODO implement this
    }
    
    // MARK: Artist metadata
    
    func artistName() -> String? {
        var artist = {
            self.getFilteredMetadata(AVMetadataCommonIdentifierArtist, id3Identifier: AVMetadataIdentifierID3MetadataOriginalArtist, iTunesIdentifier: AVMetadataIdentifieriTunesMetadataArtist).orElse(
                self.getMetadataForKey(commonKey: AVMetadataCommonKeyArtist,
                    ID3Key: AVMetadataID3MetadataKeyOriginalArtist,
                    iTunesKey: AVMetadataiTunesMetadataKeyArtist)
            )
        }()

        return artist?.stringValue
    }
    
    // MARK: Album metadata
    
    func albumName() -> String? {
        var album = {
            self.getFilteredMetadata(AVMetadataCommonIdentifierAlbumName, id3Identifier: AVMetadataIdentifierID3MetadataAlbumTitle, iTunesIdentifier: AVMetadataIdentifieriTunesMetadataAlbum).orElse(
                self.getMetadataForKey(commonKey: AVMetadataCommonIdentifierAlbumName,
                                       ID3Key: AVMetadataID3MetadataKeyOriginalArtist,
                                       iTunesKey: AVMetadataiTunesMetadataKeyArtist)
            )
        }()

        return album?.stringValue
    }
    
    private func getFilteredMetadata(commonIdentifier: String?, id3Identifier: String?, iTunesIdentifier: String?) -> AVMetadataItem? {
        assert(commonIdentifier != nil && id3Identifier != nil && iTunesIdentifier != nil, "EVERYTHING IS NIL")
        
        if let cid = commonIdentifier {
            let item = AVMetadataItem.metadataItemsFromArray(self.commonArray, filteredByIdentifier: cid).first as? AVMetadataItem
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
    
    private func getMetadataForKey(ID3Key: String? = nil, iTunesKey: String? = nil, commonKey: String? = nil) -> AVMetadataItem? {
        assert(commonKey != nil && ID3Key != nil && iTunesKey != nil, "They're all nil!!")
                
        var item: AVMetadataItem?
        if let ck = commonKey {
            item = getMetadataValue(ck, keySpace: AVMetadataKeySpaceCommon)
            if item != nil {
                return item
            }
        }
        
        if let id3 = ID3Key {
            item = getMetadataValue(id3, keySpace: AVMetadataKeySpaceID3)
            if item != nil {
                return item
            }
        }
        
        if let itunes = iTunesKey {
            item = getMetadataValue(itunes, keySpace: AVMetadataKeySpaceiTunes)
            if item != nil {
                return item
            }
        }
        
        return nil
    }
    
    private func getMetadataValue(key: String, keySpace: String) -> AVMetadataItem? {
        if metadataDictionary[key] != nil {
            return metadataDictionary[key]
        } else {
            let asset = AVMetadataItem.metadataItemsFromArray(self.asset.commonMetadata, withKey: key, keySpace: keySpace) as [AVMetadataItem]
            if let value = asset.first? {
                metadataDictionary[key] = value
            }
            
            return asset.first?
        }
    }
}
