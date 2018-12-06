//
//  FetchRecent.swift
//  MGPicsque
//
//  Created by Gupta, Mrigank on 28/11/18.
//  Copyright © 2018 Gupta, Mrigank. All rights reserved.
//

import Foundation

fileprivate let methodAPI = "flickr.groups.pools.getPhotos"
final class FetchPopular: WebService {
    private let firstPage: Int

    init(firstPage: Int) {
        self.firstPage = firstPage
    }

    private func fetchPopularPics(page: Int, pageSize: Int = 15) {
        let service = WebService()
        let recentPics: Resourse<PhotoListing<Photo>> = service.prepareResource(page: page, pageSize: pageSize, pathForREST: "services/rest/", argsDict: ["method":"\(methodAPI)","group_id":"1577604@N20"])
        service.getMe(res: recentPics) { (pics) in
//            print(pics)
            self.delegate?.returnedResponse(pics?.photos)
        }
    }
}

extension FetchPopular: PagableService {

    func refreshPage() {
        fetchPopularPics(page: firstPage)
    }

    func loadNextPage(currentPage: Int) {
        fetchPopularPics(page: currentPage+1)
    }
}
