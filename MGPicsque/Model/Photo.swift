//
//  Photo.swift
//  MGPicsque
//
//  Created by Gupta, Mrigank on 27/11/18.
//  Copyright © 2018 Gupta, Mrigank. All rights reserved.
//

import Foundation
import Pageable

struct PhotoListing<T: Decodable>: Decodable {
    let photos: PagedResponse<T>
}

struct PagedResponse<T: Decodable>: Decodable {
    let types: [T]
    let page: Int
    let pageSize: Int
    let totalPageCount: Int
    public enum CodingKeys: String, CodingKey {
        case types = "photo"
        case page
        case pageSize = "perpage"
        case totalPageCount = "pages"
    }
}

struct Photo: Decodable {
    let id: String
    let title: String
    let url240Small: String?
    let url360Small: String?
    public enum CodingKeys: String, CodingKey {
        case id
        case title
        case url240Small = "url_m"
        case url360Small = "url_n"
    }
}
