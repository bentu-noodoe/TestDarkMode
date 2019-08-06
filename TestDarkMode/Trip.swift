//
//  Trip.swift
//  Sunray
//
//  Created by ZhengXun Tu on 2018/9/26.
//  Copyright © 2018 Noodoe. All rights reserved.
//

import UIKit
import CoreLocation

class Trip: Codable {
    
    var routeImage: Image?
    
    var distance: Int?
    
    var duration: Int?
    
    var startTime: Date?
    
    var endTime: Date?
    
    var actualDisplacement: Int?
    
    
    var _routeImage: UIImage?
    
    init(routeImage: Image? = nil, distance: Int? = 0, duration: Int? = 0, startTime: Date? = Date(timeIntervalSince1970: 0.0), endTime: Date? = Date(timeIntervalSince1970: 0.0), actualDisplacement: Int? = nil) {
        self.routeImage = routeImage
        self.distance = distance
        self.duration = duration
        self.startTime = startTime
        self.endTime = endTime
        self.actualDisplacement = actualDisplacement
    }
    
    enum CodingKeys: String, CodingKey {
        case routeImage
        case distance
        case duration
        case startTime
        case endTime
        case actualDisplacement
    }
    
}

extension Trip: Equatable {
    
    static func == (lhs: Trip, rhs: Trip) -> Bool {
        return (lhs.routeImage == rhs.routeImage) &&
                (lhs.distance == rhs.distance) &&
                (lhs.duration == rhs.duration) &&
                (lhs.startTime == rhs.startTime) &&
                (lhs.endTime == rhs.endTime) &&
                (lhs.actualDisplacement == rhs.actualDisplacement)
    }
    
}

