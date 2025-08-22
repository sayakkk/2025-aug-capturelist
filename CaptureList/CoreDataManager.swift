import Foundation
import CoreData
import WidgetKit

class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()
    
    private let containerName = "CaptureList"
    private let appGroupIdentifier = "group.com.example.CaptureList"
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: containerName)
        
        // Configure for App Groups
        if let storeDescription = container.persistentStoreDescriptions.first {
            storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            storeDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            
            // Use App Groups container
            if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
                let storeURL = appGroupURL.appendingPathComponent("\(containerName).sqlite")
                storeDescription.url = storeURL
            }
        }
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private init() {}
    
    // MARK: - Save Context
    func save() {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
                WidgetCenter.shared.reloadAllTimelines()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    // MARK: - Folder Operations
    func createFolder(name: String) -> Folder {
        let folder = Folder(context: viewContext)
        folder.id = UUID()
        folder.name = name
        folder.createdAt = Date()
        save()
        return folder
    }
    
    func fetchFolders() -> [Folder] {
        let request: NSFetchRequest<Folder> = Folder.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Folder.createdAt, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching folders: \(error)")
            return []
        }
    }
    
    func deleteFolder(_ folder: Folder) {
        viewContext.delete(folder)
        save()
    }
    
    // MARK: - Screenshot Operations
    func createScreenshot(assetIdentifier: String, thumbnailData: Data? = nil) -> Screenshot {
        let screenshot = Screenshot(context: viewContext)
        screenshot.id = UUID()
        screenshot.assetIdentifier = assetIdentifier
        screenshot.capturedAt = Date()
        screenshot.thumbnailData = thumbnailData
        save()
        return screenshot
    }
    
    func fetchScreenshots(in folder: Folder? = nil) -> [Screenshot] {
        let request: NSFetchRequest<Screenshot> = Screenshot.fetchRequest()
        
        if let folder = folder {
            request.predicate = NSPredicate(format: "folder == %@", folder)
        }
        
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Screenshot.capturedAt, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching screenshots: \(error)")
            return []
        }
    }
    
    func fetchRecentScreenshots(limit: Int = 10) -> [Screenshot] {
        let request: NSFetchRequest<Screenshot> = Screenshot.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Screenshot.capturedAt, ascending: false)]
        request.fetchLimit = limit
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching recent screenshots: \(error)")
            return []
        }
    }
    
    func moveScreenshot(_ screenshot: Screenshot, to folder: Folder?) {
        screenshot.folder = folder
        save()
    }
    
    func deleteScreenshot(_ screenshot: Screenshot) {
        viewContext.delete(screenshot)
        save()
    }
    
    // MARK: - Widget Data
    func getWidgetData() -> [Folder] {
        return fetchFolders().prefix(4).map { folder in
            // Create a lightweight copy for widget
            let widgetFolder = Folder(context: viewContext)
            widgetFolder.id = folder.id
            widgetFolder.name = folder.name
            widgetFolder.createdAt = folder.createdAt
            return widgetFolder
        }
    }
} 