//
//  User.swift
//  Sunray
//
//  Created by ZhengXun Tu on 2018/9/26.
//  Copyright © 2018 Noodoe. All rights reserved.
//

import Foundation

class User: Codable {
    
    var id: String?
    
    var name: String?
    
    var avatarImage: Image?

    var thumbnailImage: Image?
    
    var birthday: Date?
    
    var gender: Gender?
    
    var phone: String?
    
    var email: String?
    
    init(id: String? = nil, name: String? = nil, avatarImage: Image? = nil, thumbnailImage: Image? = nil, birthday: Date? = nil, gender: Gender? = nil, phone: String? = nil, email: String? = nil) {
        self.id = id
        self.name = name
        self.avatarImage = avatarImage
        self.thumbnailImage = thumbnailImage
        self.birthday = birthday
        self.gender = gender
        self.phone = phone
        self.email = email
    }
    
}
