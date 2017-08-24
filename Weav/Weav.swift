import UIKit
import MapKit

class Weav: NSObject, MKAnnotation {
    var title: String?
    let locationName: String
    let discipline: IntegerLiteralType
    let coordinate: CLLocationCoordinate2D
    
    var current_location: CLLocation!
    var eventID: String!
    var fromDiscover: Bool = false
    
    init(title: String, locationName: String, discipline: IntegerLiteralType, coordinate: CLLocationCoordinate2D, eventID: String) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        self.eventID = eventID
        
        super.init()
    }
    
    var subtitle: String? {
        return "Public"
    }
}

