//
//  FetchRecent.swift
//  MGPicsque
//
//  Created by Gupta, Mrigank on 28/11/18.
//  Copyright © 2018 Gupta, Mrigank. All rights reserved.
//

import Foundation
import Pageable

fileprivate let methodAPI = "flickr.groups.pools.getPhotos"

final class FetchPopular: WebService {
    private let firstPage: Int

    init(firstPage: Int) {
        self.firstPage = firstPage
        super.init()
    }

    private func fetchPopularPics(page: Int, pageSize: Int = 15) {
        guard let recentPics: Resourse<PhotoListing<Photo>> = try? self.prepareResource(page: page, pageSize: pageSize, pathForREST: "/services/rest/", argsDict: ["method":"\(methodAPI)","group_id":"1577604@N20"]) else { return }
        var info: PageInfo<Photo>?
        getMe(res: recentPics) { (res) in
            switch res {
            case let .success(result):
                info = PageInfo(types: result.photos.types, page: result.photos.page,
                                totalPageCount: result.photos.totalPageCount)
            case let .failure(err):
                print(err)
            }
            self.delegate?.returnedResponse(info)
        }
    }
}

//point: 3
extension FetchPopular: PagableService {

    func loadPage(_ page: Int) {
        fetchPopularPics(page: page)
    }

    func cancelAllRequests() {
        cancelAll()
    }

}
