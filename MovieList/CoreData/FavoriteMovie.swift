import CoreData

@objc(FavoriteMovie)
public class FavoriteMovie: NSManagedObject {
    @NSManaged public var id: Int64
    @NSManaged public var title: String?
    @NSManaged public var posterUrl: String?
    @NSManaged public var rating: Double
    @NSManaged public var year: Int16
    @NSManaged public var movieDescription: String?
    @NSManaged public var genres: String?
    @NSManaged public var addedDate: Date?
}

extension FavoriteMovie {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteMovie> {
        return NSFetchRequest<FavoriteMovie>(entityName: "FavoriteMovie")
    }
}