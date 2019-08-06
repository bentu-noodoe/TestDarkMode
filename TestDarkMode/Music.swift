//
//  Music.swift
//  Sunray
//
//  Created by ZhengXun Tu on 2018/9/26.
//  Copyright © 2018 Noodoe. All rights reserved.
//

import Foundation

class Music: Codable {
    
    var id: String?
    
    var musicName: String?
    
    var musicUrl: URL?
    
    var albumImage: Image?
    
    init() {
        
    }
    
    convenience init(id: String) {
        self.init()
        self.id = id
    }
    
}

extension Music: Equatable {
    
    static func == (lhs: Music, rhs: Music) -> Bool {
        return lhs.id == rhs.id
    }
    
}
