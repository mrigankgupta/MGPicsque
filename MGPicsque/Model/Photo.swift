//
//  Photo.swift
//  MGPicsque
//
//  Created by Gupta, Mrigank on 27/11/18.
//  Copyright © 2018 Gupta, Mrigank. All rights reserved.
//

import Foundation
typealias JsonDict = [String : String]

struct PhotoListing<T: Decodable>: Decodable {
    var photos: PagedResponse<T>
}

struct PagedResponse<T: Decodable>: Decodable {
    var types: [T]
    var page: Int
    var pageSize: Int
    var totalPageCount: Int
    public enum CodingKeys: String, CodingKey {
        case types = "photo"
        case page
        case pageSize = "perpage"
        case totalPageCount = "pages"
    }
}

struct Photo: Decodable {
    var id: String
    var title: String
    var url240Small: String?
    var url360Small: String?
    public enum CodingKeys: String, CodingKey {
        case id
        case title
        case url240Small = "url_m"
        case url360Small = "url_n"
    }
}
