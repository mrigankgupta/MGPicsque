//
//  FetchRecent.swift
//  MGPicsque
//
//  Created by Gupta, Mrigank on 28/11/18.
//  Copyright © 2018 Gupta, Mrigank. All rights reserved.
//

import Foundation
fileprivate let methodAPI = "flickr.photos.getRecent"

class FetchRecent: WebService {

    func fetchRecentPics(page: Int = 0, pageSize: Int = 15) {
        let service = WebService()
        let recentPics: Resourse<PhotoListing<Photo>> = service.prepareResource(page: 1, pageSize: 10, pathForREST: "services/rest/", argsDict: ["method":"\(methodAPI)"])
        service.getMe(res: recentPics) { (pics) in
            print(pics)
            self.delegate?.returnedResponse(pics?.photos)
        }
    }
}
