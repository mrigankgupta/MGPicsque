//
//  ViewController.swift
//  MGPicsque
//
//  Created by Gupta, Mrigank on 26/11/18.
//  Copyright © 2018 Gupta, Mrigank. All rights reserved.
//

import UIKit
import Kingfisher
import Pageable

private let firstReqIndex = 1

final class PicsqueTimeline: UIViewController {

    @IBOutlet weak private var picsTimeline: UITableView!
    //Point: 1
    private var pgInteractor: PageInteractor<Photo, String>!

    override func viewDidLoad() {
        super.viewDidLoad()
        //Point: 2
        setupPageInteractor()

        setupTableView()
    }
}

extension PicsqueTimeline: UITableViewDataSourcePrefetching {

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        ImagePrefetcher(urls: getURLs(tableView, For: indexPaths)).start()
    }

    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        ImagePrefetcher(urls: getURLs(tableView, For: indexPaths)).stop()
    }
}

extension PicsqueTimeline: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //Point: 3
        pgInteractor.shouldPrefetch(index: indexPath.item)
    }

}
extension PicsqueTimeline: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pgInteractor.visibleRow()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.item >= pgInteractor.count() {
            let loading = tableView.dequeueReusableCell(withIdentifier: String(describing: LoadingCell.self), for: indexPath)
                as! LoadingCell
            loading.activityIndicator.startAnimating()
            return loading
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PhotoViewCell.self), for: indexPath)
                as! PhotoViewCell
            let photo: Photo = pgInteractor.selectedItem(for: indexPath.item)
            cell.configureCell(with: photo, for: indexPath)
            return cell
        }
    }

}
//Point: 4
extension PicsqueTimeline: PageDataSource {

    func addUniqueItems(for items: [AnyObject]) -> Range<Int> {
        let startIndex = pgInteractor.count()
        if let items = items as? [Photo] {
            for new in items {
                if pgInteractor.dict[new.id] == nil {
                    pgInteractor.dict[new.id] = new.id
                    pgInteractor.array.append(new)
                }
            }
        }
        return startIndex..<pgInteractor.count()
    }

    func addAll(items: [AnyObject]) {
        if let items = items as? [Photo] {
            pgInteractor.array = items
            for new in items {
                pgInteractor.dict[new.id] = new.id
            }
        }
    }
}

extension PicsqueTimeline {
    //Point: 6
    @objc
    func refreshPage() {
        pgInteractor.refreshPage()
    }

    private func getURLs(_ tableView: UITableView, For indexPaths: [IndexPath]) -> [URL] {
        let urls:[URL] = indexPaths.compactMap {
            if $0.item < pgInteractor.count() {
                let photo: Photo = pgInteractor.selectedItem(for: $0.item)
                if let urlString = photo.url240Small {
                    return URL(string: urlString)
                }
            }
            return nil
        }
        return urls
    }

    private func setupTableView() {
        picsTimeline.dataSource = self
        picsTimeline.delegate = self
        picsTimeline.prefetchDataSource = self
        picsTimeline.register(UINib(nibName: String(describing: PhotoViewCell.self), bundle: nil), forCellReuseIdentifier:
            String(describing: PhotoViewCell.self))
        picsTimeline.register(UINib(nibName: String(describing: LoadingCell.self), bundle: nil), forCellReuseIdentifier:
            String(describing: LoadingCell.self))
        picsTimeline.estimatedRowHeight = 400
        picsTimeline.rowHeight = UITableView.automaticDimension

        picsTimeline.backgroundColor = .black
        picsTimeline.tableFooterView = UIView(frame: .zero)
        self.navigationController?.navigationBar.isTranslucent = false
        picsTimeline.setupRefreshControl(self, selector:#selector(self.refreshPage))
    }
    //point: 5
    private func setupPageInteractor() {
        pgInteractor = PageInteractor(firstPage: firstReqIndex)
        pgInteractor.pageDelegate = self.picsTimeline
        pgInteractor.pageDataSource = self
        let fetchPopular = FetchPopular(firstPage: firstReqIndex)
        fetchPopular.delegate = pgInteractor
        pgInteractor.service = fetchPopular
        pgInteractor.refreshPage()
    }
}
