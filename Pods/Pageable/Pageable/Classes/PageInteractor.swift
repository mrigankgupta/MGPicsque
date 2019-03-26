//
//  PageInteractor.swift
//  ShowMyRide
//
//  Created by Gupta, Mrigank on 19/08/18.
//  Copyright © 2018 Gupta, Mrigank. All rights reserved.
//

import Foundation

public protocol PageDataSource: class {
    func addUniqueItems(for items: [AnyObject]) -> Range<Int>
    func addAll(items: [AnyObject])
}

public class PageInteractor <Item, KeyType: Hashable> {

    public var array: [Item] = []
    public var dict: [KeyType : KeyType] = [:]
    public var service: PagableService?

    public weak var pageDelegate: Pageable?
    public weak var pageDataSource: PageDataSource?
    public internal(set) var isLoading = false
    #if swift(>=4.2)
    private var currentPage: Int
    private let firstPage: Int
    #else
    fileprivate var currentPage: Int
    fileprivate let firstPage: Int
    #endif

    private var showLoadingCell = false

    public init(firstPage: Int) {
        self.firstPage = firstPage
        currentPage = firstPage
    }

    public func visibleRow() -> Int {
        return showLoadingCell ? count()+1 : count()
    }

    public func refreshPage() {
        array.removeAll()
        dict.removeAll()
        isLoading = true
        service?.cancelAllRequests()
        service?.loadPage(firstPage)
    }

    public func loadNextPage() {
        if !isLoading {
            isLoading = true
            service?.loadPage(currentPage+1)
        }
    }

    public func shouldPrefetch(index: Int) {
        if showLoadingCell && index == count()-1 {
            loadNextPage()
        }
    }
    
    #if swift(>=4.2)
    public func getUniqueItemsIndexPath(addedRange: Range<Int>) -> [IndexPath] {
        let truncate = showLoadingCell ? addedRange : addedRange.dropLast()
        return truncate.map({IndexPath(row: $0, section: 0)})
    }
    #else
    public func getUniqueItemsIndexPath(addedRange: Range<Int>) -> [IndexPath] {
        let truncate = showLoadingCell ? addedRange : addedRange.lowerBound..<addedRange.upperBound-1
        var path = [IndexPath]()
        for row in truncate.lowerBound..<truncate.upperBound {
            path.append(IndexPath(row: row, section: 0))
        }
        return path
    }
    #endif

    public func updatePage(number: Int, totalPageCount: Int) {
        isLoading = false
        currentPage = number
        showLoadingCell = currentPage < totalPageCount
    }

    public func selectedItem(for index: Int) -> Item {
        return array[index]
    }

    public func count() -> Int {
        return array.count
    }
}

extension PageInteractor: WebResponse {

    public func returnedResponse<T>(_ info: PageInfo<T>?) {
        if let currentResponse = info {
            let lastPageNumber = currentPage
            updatePage(number: currentResponse.page, totalPageCount: currentResponse.totalPageCount)
            print(currentResponse.page)
            if currentResponse.page == firstPage {
                pageDataSource?.addAll(items: currentResponse.types as [AnyObject])
                DispatchQueue.main.async {
                    self.pageDelegate?.reloadAll(true)
                }
            } else if currentResponse.page == lastPageNumber + 1 {
                if let numberOfItems = pageDataSource?.addUniqueItems(for: currentResponse.types as [AnyObject]) {
                    let newIndexPaths = getUniqueItemsIndexPath(addedRange: numberOfItems)
                    DispatchQueue.main.async {
                        self.pageDelegate?.insertAndUpdateRows(new: newIndexPaths)
                    }
                }
            }else{
                print("Ignore result as requests landed in non-sequential order")
            }
        }else {
            isLoading = false
            DispatchQueue.main.async {
                self.pageDelegate?.reloadAll(false)
            }
//            print("some error")
        }
    }

}
