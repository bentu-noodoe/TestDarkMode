//
//  Journey.swift
//  Sunray
//
//  Created by ZhengXun Tu on 2018/9/26.
//  Copyright © 2018 Noodoe. All rights reserved.
//

import UIKit

class Journey: Codable {
    
    var id: String?
    
    var author: User?
    
    var title: String?
    
    var story: String?
    
    var music: Music?
    
    var previewImage: Image?
    
    var tripLog: String?
    
    var trip: Trip?
    
    var spots: [Spot]?
    
    //interaction
    var isCurrentUserLike: Bool?
    
    var isCurrentUserCollect: Bool?
    
    var likesCount: Int?
    
    var commentsCount: Int?
    
    var collectsCount: Int?
    
    //state
    var isPublic: Bool?
    
    var reportState: String?
    
    var createdAt: Date?
    
    var updatedAt: Date?
    
    var publishedAt: Date?
    
    // inner var
    var _tripLogs: [TripGeoJSON]?
    
    var _previewImage: UIImage?
    
    var _thumbnailImage: UIImage?
    
    init(id: String? = nil, author: User? = nil, title: String? = nil, story: String? = nil, music: Music? = nil, previewImage: Image? = nil, tripLog: String? = nil, trip: Trip? = nil, spots: [Spot]? = nil, isPublic: Bool? = false, reportState: String? = nil, createdAt: Date? = nil, updatedAt: Date? = nil, publishedAt: Date? = nil) {
        self.id = id
        self.author = author
        self.title = title
        self.story = story
        self.music = music
        self.previewImage = previewImage
        self.tripLog = tripLog
        self.trip = trip
        self.spots = spots
        self.isPublic = isPublic
        self.reportState = reportState
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.publishedAt = publishedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case author
        case title
        case story
        case music
        case previewImage
        case tripLog
        case trip
        case spots
        case isPublic
        case reportState
        case createdAt
        case updatedAt
        case publishedAt
        case isCurrentUserLike
        case isCurrentUserCollect
        case likesCount
        case commentsCount
        case collectsCount
    }
    
}

import CoreLocation

//TODO: Naming? This is not GeoJson.
struct TripGeoJSON: Codable {
    let latitude: Double
    let longitude: Double
    let timeStamp: Date
    var isSpotLog: Bool
    
//    static func tripGeoJsonsFromGeoJson(_ geoJson: GeoJson) -> [TripGeoJSON] {
//        return geoJson.features.compactMap { feature -> TripGeoJSON? in
//            guard let coords = feature.geometry.coordinates as? [Double], coords.count == 2 else { return nil }
//            return TripGeoJSON(latitude: coords[1],
//                               longitude: coords[0],
//                               timeStamp: Date(timeIntervalSince1970: Double(feature.properties.timestamp) / 1000),
//                               isSpotLog: feature.properties.isSpot)
//        }
//    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

//extension GeoJson {
//    
//    static func geoJsonFromTripGeoJsons(_ tripGeoJsons: [TripGeoJSON]) -> GeoJson {
//        let result = GeoJson()
//        result.reserveCapacity(tripGeoJsons.count)
//        tripGeoJsons.forEach { result.addPoints(points: [$0.longitude, $0.latitude],
//                                                properties: Properties(timestamp: UInt64($0.timeStamp.timeIntervalSince1970*1000),
//                                                                       isSpot: false)) }
//        return result
//    }
//    
//}
