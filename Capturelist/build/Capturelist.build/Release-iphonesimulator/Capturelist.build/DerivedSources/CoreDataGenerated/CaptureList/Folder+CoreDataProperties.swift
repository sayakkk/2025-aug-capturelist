//
//  Folder+CoreDataProperties.swift
//  
//
//  Created by saya lee on 2025. 9. 20..
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Folder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Folder> {
        return NSFetchRequest<Folder>(entityName: "Folder")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var screenshots: NSSet?

}

// MARK: Generated accessors for screenshots
extension Folder {

    @objc(addScreenshotsObject:)
    @NSManaged public func addToScreenshots(_ value: Screenshot)

    @objc(removeScreenshotsObject:)
    @NSManaged public func removeFromScreenshots(_ value: Screenshot)

    @objc(addScreenshots:)
    @NSManaged public func addToScreenshots(_ values: NSSet)

    @objc(removeScreenshots:)
    @NSManaged public func removeFromScreenshots(_ values: NSSet)

}

extension Folder : Identifiable {

}
