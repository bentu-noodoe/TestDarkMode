//
//  Spot.swift
//  Sunray
//
//  Created by ZhengXun Tu on 2018/9/26.
//  Copyright © 2018 Noodoe. All rights reserved.
//

import Foundation
import CoreLocation
import MobileCoreServices

final class Spot: NSObject, Codable {
    
    var id: String?
    
    var journeyId: String?
    
    var name: String?
    
    var lat: CLLocationDegrees?

    var lon: CLLocationDegrees?

    // country, city
    // ref: https://noodoe.atlassian.net/wiki/spaces/SUN/pages/917504106/Social+Navigation+Journey+Spot+Country+City
    
    var country: [String]?

    var city: [String]?

    var date: Date?

    var spotDescription: String?
    
    var imageStories: [ImageStory]?

    init(id: String, journeyId: String, name: String, lat: CLLocationDegrees, lon: CLLocationDegrees) {
        self.id = id
        self.journeyId = journeyId
        self.name = name
        self.lat = lat
        self.lon = lon
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case journeyId
        case name
        case lat
        case lon
        case country
        case city
        case date
        case spotDescription = "description"
        case imageStories
    }
    
    final class ImageStory: NSObject, Codable {
        
        var id: String?
        
        var spotId: String?
        
        var photo: Image? = Image(imageUrl: URL(string: "https://wwww.example.com")!) //hardcode for test purpose

        var music: Music?

        var photoDescription: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case spotId
            case photo
            case photoDescription = "description"
            case music
        }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let o = object as? ImageStory else {
                return false
            }
            
            return (self.id == o.id) &&
                (self.spotId == o.spotId) &&
                (self.photo == o.photo) &&
                (self.photoDescription == o.photoDescription)
        }
        
    }
    
    static func makeStubSpots() -> [Spot] {
        let path = Bundle.main.path(forResource: "StubSpots", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let spots = try! decoder.decode([Spot].self, from: data)        
        return spots
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let o = object as? Spot else {
            return false
        }
        
        return (self.id == o.id) &&
            (self.journeyId == o.journeyId) &&
            (self.name == o.name) &&
            (self.lat == o.lat) &&
            (self.lon == o.lon) &&
            (self.country == o.country) &&
            (self.city == o.city) &&
            (self.date == o.date) &&
            (self.spotDescription == o.spotDescription) &&
            (self.imageStories == o.imageStories)
    }
    
}

@available(iOS 11.0, *)
extension Spot: NSItemProviderReading, NSItemProviderWriting {
    
    private static var itemIdentifier: [String] = [kUTTypeData as String, "SpotData"]
    
    static var writableTypeIdentifiersForItemProvider: [String] {
        return itemIdentifier
    }
    
    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        
        if let data = try? PropertyListEncoder().encode(self) {
            completionHandler(data, nil)
        }
        
        return nil
    }
    
    static var readableTypeIdentifiersForItemProvider: [String] {
        return itemIdentifier
    }
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Spot {
        guard let spot = try? PropertyListDecoder().decode(Spot.self, from: data) else {
            return self.init(id: "ID",
                             journeyId: "JOURNEYID",
                             name: "NAME",
                             lat: 80.0,
                             lon: 80.0)
        }
        
        return spot
    }
}

@available(iOS 11.0, *)
extension Spot.ImageStory: NSItemProviderReading, NSItemProviderWriting {

    private static var itemIdentifier: [String] = [kUTTypeData as String, "SpotImageStoryData"]

    static var writableTypeIdentifiersForItemProvider: [String] {
        return itemIdentifier
    }

    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {

        if let data = try? PropertyListEncoder().encode(self) {
            completionHandler(data, nil)
        }

        return nil
    }

    static var readableTypeIdentifiersForItemProvider: [String] {
        return itemIdentifier
    }

    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Spot.ImageStory {
        guard let result = try? PropertyListDecoder().decode(Spot.ImageStory.self, from: data) else {
            return self.init()
        }

        return result
    }
}
