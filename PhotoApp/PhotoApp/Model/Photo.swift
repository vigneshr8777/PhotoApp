//
//  Photo.swift
//  PhotoApp
//
//  Created by Vignesh Radhakrishnan on 02/06/20.
//  Copyright © 2020 Sample. All rights reserved.
//

import Foundation

struct Photo : Codable {
    let id : String
    let owner : String?
    let secret : String
    let server : String
    let farm : Int
    let title : String?
    let ispublic : Int?
    let isfriend : Int?
    let isfamily : Int?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case owner = "owner"
        case secret = "secret"
        case server = "server"
        case farm = "farm"
        case title = "title"
        case ispublic = "ispublic"
        case isfriend = "isfriend"
        case isfamily = "isfamily"
    }
}

struct Photos : Codable {
    let page : Int?
    let pages : Int?
    let perpage : Int?
    let total : Int
    let photo : [Photo]?

    enum CodingKeys: String, CodingKey {

        case page = "page"
        case pages = "pages"
        case perpage = "perpage"
        case total = "total"
        case photo = "photo"
    }
}

struct Response : Codable {
    let photos : Photos?
    let stat : String?

    enum CodingKeys: String, CodingKey {

        case photos = "photos"
        case stat = "stat"
    }
}
