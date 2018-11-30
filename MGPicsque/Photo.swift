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

struct PagedResponse<T: Decodable >: Decodable {
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
    var url: String?
    public enum CodingKeys: String, CodingKey {
        case id
        case url = "url_q"
    }
}

protocol PageListing {
    associatedtype ArrayType
    associatedtype KeyType where KeyType: Hashable

    var array: [ArrayType] { get set }
    var dict: [KeyType : KeyType] { get set }
}

struct PhotoList: Decodable, PageListing {

    typealias ArrayType = Photo
    typealias KeyType = String

    var array: [Photo]
    var dict: JsonDict

    init(photos: [Photo]) {
        array = photos
        dict = JsonDict()
        for photo in photos {
            dict[photo.id] = photo.id
        }
    }
}
