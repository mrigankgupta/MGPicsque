//
//  PageInteractor.swift
//  ShowMyRide
//
//  Created by Gupta, Mrigank on 19/08/18.
//  Copyright © 2018 Gupta, Mrigank. All rights reserved.
//

import Foundation
import UIKit

protocol PageDataSource: class {
    func addUniqueItems(for items: [AnyObject]) -> Range<Int>
    func addAllItems(items: [AnyObject])
}

class PageInteractor<item, keyType: Hashable> {

    var array: [item] = []
    var dict: [keyType:keyType] = [:]
    var service: PagableService?

    weak var pageDelegate: Pageable?
    weak var pageDataSource: PageDataSource?
    public internal(set) var isLoading = false
    private var currentPage: Int
    private let firstPage: Int
    private var showLoadingCell = false

    init(firstPage: Int) {
        self.firstPage = firstPage
        currentPage = firstPage
    }

    func setupService() {
        refreshPage()
    }

    func visibleRow() -> Int {
        return showLoadingCell ? count()+1 : count()
    }

    func refreshPage() {
        array.removeAll()
        dict.removeAll()
        isLoading = true
        service?.refreshPage()
        print("refresh Page", currentPage)
    }

    func loadNextPage() {
        if !isLoading {
            isLoading = true
            service?.loadNextPage(currentPage: currentPage)
            print("load Page", currentPage+1)
        }
    }

    func shouldPrefetch(index: Int) {
        if showLoadingCell && index == count() {
            loadNextPage()
        }
    }
    #if swift(>=4.2)
    func getUniqueItemsIndexPath(addedRange: Range<Int>) -> [IndexPath] {
        let truncate = showLoadingCell ? addedRange : addedRange.dropLast()
        return truncate.map({IndexPath(row: $0, section: 0)})
    }
    #else
    func getUniqueItemsIndexPath(addedRange: Range<Int>) -> [IndexPath] {
        let truncate = showLoadingCell ? addedRange : addedRange.lowerBound..<addedRange.upperBound-1
        var path = [IndexPath]()
        for row in truncate.lowerBound..<truncate.upperBound {
            path.append(IndexPath(row: row, section: 0))
        }
        return path
    }
    #endif
    func updatePageNumber(With responsePage: Int, totalPageCount: Int) {
        isLoading = false
        currentPage = responsePage
        showLoadingCell = currentPage < totalPageCount-1
    }

    func selectedItem(for index: Int) -> item {
        return array[index]
    }

    func count() -> Int {
        return array.count
    }
}

extension PageInteractor: WebResponse {

    func returnedResponse<T>(_ item: PagedResponse<T>?) where T: Decodable {
        if let currentResponse = item {
            updatePageNumber(With: currentResponse.page, totalPageCount: currentResponse.totalPageCount)
            if currentResponse.page == firstPage {
                pageDataSource?.addAllItems(items: currentResponse.types as [AnyObject])
                DispatchQueue.main.async {
                    self.pageDelegate?.reloadAll(true)
                }
            } else {
                if let numberOfItems = pageDataSource?.addUniqueItems(for: currentResponse.types as [AnyObject]) {
                    let newIndexPaths = getUniqueItemsIndexPath(addedRange: numberOfItems)
                    DispatchQueue.main.async {
                        self.pageDelegate?.insertAndUpdateRows(new: newIndexPaths)
                    }
                }
            }
        }else {
            isLoading = false
            DispatchQueue.main.async {
                self.pageDelegate?.reloadAll(true)
            }
            print("some error")
        }
    }

}
