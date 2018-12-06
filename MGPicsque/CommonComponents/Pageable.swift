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
    func reloadAll(_ reload: Bool)
    func setupRefreshControl(_ target: Any?, selector: Selector)
}

extension UITableView: Pageable {

    func insertAndUpdateRows(new: [IndexPath]) {
        self.performBatchUpdates({
            self.insertRows(at: new, with: .none)
        }) { (_) in }
        if let visible = self.indexPathsForVisibleRows {
            let intersection = Set(new).intersection(Set(visible))
            if intersection.count > 0 {
                self.reloadRows(at: Array(intersection), with: .none)
            }
        }
    }

    func reloadAll(_ reload: Bool) {
        if reload {
            self.reloadData()
        }
        refreshControl!.endRefreshing()
    }

    func setupRefreshControl(_ target: Any?, selector: Selector) {
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(target, action: selector, for: .valueChanged)
        refreshControl!.beginRefreshing()
    }

}
