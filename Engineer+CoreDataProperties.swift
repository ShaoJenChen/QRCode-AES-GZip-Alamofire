//
//  Engineer+CoreDataProperties.swift
//  
//
//  Created by ShaoJen Chen on 2018/4/26.
//
//

import Foundation
import CoreData


extension Engineer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Engineer> {
        return NSFetchRequest<Engineer>(entityName: "Engineer")
    }

    @NSManaged public var attribute: String?
    @NSManaged public var attribute1: String?
    @NSManaged public var attribute2: Bool

}
