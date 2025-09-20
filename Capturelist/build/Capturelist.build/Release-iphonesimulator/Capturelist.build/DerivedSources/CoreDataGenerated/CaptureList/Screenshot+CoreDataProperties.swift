//
//  Screenshot+CoreDataProperties.swift
//  
//
//  Created by saya lee on 2025. 9. 20..
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Screenshot {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Screenshot> {
        return NSFetchRequest<Screenshot>(entityName: "Screenshot")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var phAssetID: String?
    @NSManaged public var folder: Folder?

}

extension Screenshot : Identifiable {

}
