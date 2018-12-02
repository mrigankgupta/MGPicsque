//
//  PageController.swift
//  ShowMyRide
//
//  Created by Gupta, Mrigank on 28/08/18.
//  Copyright © 2018 Gupta, Mrigank. All rights reserved.
//

import UIKit

protocol Pageable: class {
    func insertAndUpdateRows(new: [IndexPath])
    func reloadAll()
    func setupRefreshControl(_ target: Any?, selector: Selector)
}

extension UICollectionView: Pageable {

    func insertAndUpdateRows(new: [IndexPath]) {
        self.performBatchUpdates({
            self.insertItems(at: new)
        }) { (_) in }
        let visible = self.indexPathsForVisibleItems
        let intersection = Set(new).intersection(Set(visible))
        if intersection.count > 0 {
            self.reloadItems(at: Array(intersection))
        }
    }

    func reloadAll() {
        refreshControl!.endRefreshing()
        self.reloadData()
    }

    func setupRefreshControl(_ target: Any?, selector: Selector) {
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(target, action: selector, for: .valueChanged)
        refreshControl!.beginRefreshing()
    }

}
