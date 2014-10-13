//
//  AppDelegate.swift
//  Concerto-Swift
//
//  Created by Christian Benincasa on 9/21/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Cocoa
import AVFoundation

#if DEBUG
    let shouldSave = true
#else
    let shouldSave = false
#endif

class AppDelegate: NSObject, NSApplicationDelegate {

    private var hasLaunched: Bool = false
    
    // MARK: View Controllers
    @IBOutlet var playlistViewController: COPlaylistViewController!
    
    @IBOutlet weak var preferencesWindow: NSWindow?
    var preferencesController: COPreferencesWindowController?
    var mainWindowController: COPlaylistWindowController?
    
    private let operationQueue = NSOperationQueue()
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {        
        self.hasLaunched = true
        
        operationQueue.maxConcurrentOperationCount = 1
        
        playlistViewController.managedObjectContext = self.managedObjectContext
        playlistViewController.reloadData()
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.chrisbenincasa.Concerto" in the user's Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
        let appSupportURL = urls[urls.count - 1] as NSURL
        return appSupportURL.URLByAppendingPathComponent("com.chrisbenincasa.Concerto")
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Concerto", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.) This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        let fileManager = NSFileManager.defaultManager()
        var shouldFail = false
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."

        // Make sure the application files directory is there
        let propertiesOpt = self.applicationDocumentsDirectory.resourceValuesForKeys([NSURLIsDirectoryKey], error: &error)
        if let properties = propertiesOpt {
            if !properties[NSURLIsDirectoryKey]!.boolValue {
                failureReason = "Expected a folder to store application data, found a file \(self.applicationDocumentsDirectory.path)."
                shouldFail = true
            }
        } else if error!.code == NSFileReadNoSuchFileError {
            error = nil
            fileManager.createDirectoryAtPath(self.applicationDocumentsDirectory.path!, withIntermediateDirectories: true, attributes: nil, error: &error)
        }
        
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator?
        if !shouldFail && (error == nil) {
            coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Concerto.storedata")
            
            // Custom options
            let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
            
            if coordinator!.addPersistentStoreWithType(NSXMLStoreType, configuration: nil, URL: url, options: options as NSDictionary, error: &error) == nil {
                coordinator = nil
            }
        }
        
        if shouldFail || (error != nil) {
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            if error != nil {
                dict[NSUnderlyingErrorKey] = error
            }
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSApplication.sharedApplication().presentError(error!)
            return nil
        } else {
            return coordinator
        }
    }()

    @IBOutlet lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving and Undo support

    func applicationShouldTerminate(sender: NSApplication!) -> NSApplicationTerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        
        if let moc = managedObjectContext {
            if !moc.commitEditing() {
                NSLog("\(NSStringFromClass(self.dynamicType)) unable to commit editing to terminate")
                return .TerminateCancel
            }
            
            if !moc.hasChanges {
                return .TerminateNow
            }
            
            var error: NSError? = nil
            if !moc.save(&error) {
                // Customize this code block to include application-specific recovery steps.
                let result = sender.presentError(error!)
                if (result) {
                    return .TerminateCancel
                }
                
                let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
                let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info")
                let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
                let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
                let alert = NSAlert()
                alert.messageText = question
                alert.informativeText = info
                alert.addButtonWithTitle(quitButton)
                alert.addButtonWithTitle(cancelButton)
                
                let answer = alert.runModal()
                if answer == NSAlertFirstButtonReturn {
                    return .TerminateCancel
                }
            }
        }
        // If we got here, it is time to quit.
        return .TerminateNow
    }
    
    // Preferences Window
    @IBAction func openPreferencesWindow(sender: AnyObject!) {
        preferencesController = COPreferencesWindowController(windowNibName: "Preferences")
        preferencesController!.showWindow(sender)
    }
    
    @IBAction func openSongs(sender: AnyObject!) {
        let panel: NSOpenPanel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        if NSFileHandlingPanelOKButton == panel.runModal() {
            let paths = (panel.URLs as [NSURL]).map { $0.path! } as [String]
            self.application(NSApp as NSApplication, openFiles: paths)
        }
    }
    
    // MARK: NSApplicationDelegate
    
    func application(sender: NSApplication!, openFile filename: String!) -> Bool {
        self.application(NSApp as NSApplication, openFiles: [filename])
        return true
    }
    
    func application(sender: NSApplication!, openFiles filenames: [AnyObject]!) {
        let context = self.managedObjectContext
        let songs = (filenames as [String]).map({ (path: String) -> COSong in
            let url = NSURL(fileURLWithPath: path)
            let metadata = COMetadata(url: url!)
            let song: COSong = context!.createEntity(ConcertoEntity.Song, shouldInsert: true)
            let artist: COArtist = context!.createEntity(ConcertoEntity.Artist, shouldInsert: true)
            
            if let trackName = metadata.trackName() {
                song.title = trackName
            } else {
                println("COULDNT GET TRACKNAME")
                abort()
            }
            
            if let artistName = metadata.artistName() {
                artist.name = artistName
            } else {
                println("COULDNT GET ARTIST NAME")
                abort()
            }


            song.playCount = 0
            song.setBookmarkFromPath(path)
            song.artist = artist
            
            return song
        })
        
        COPlayQueue.sharedInstance.enqueue(songs)
    }
}

