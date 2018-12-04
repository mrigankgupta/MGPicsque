//
//  ViewController.swift
//  MGPicsque
//
//  Created by Gupta, Mrigank on 26/11/18.
//  Copyright © 2018 Gupta, Mrigank. All rights reserved.
//

import UIKit
import Kingfisher

let side_inset: CGFloat = 16.0
let firstReqIndex = 1

class PicsqueTimeline: UIViewController {

    @IBOutlet weak var picsTimeline: UICollectionView!
    private var pgInteractor: PageInteractor<Photo, String>!
    private var estimatedWidth: CGFloat {
        get {
            return UIScreen.main.bounds.size.width - 2*side_inset
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        pgInteractor = PageInteractor(firstPage: firstReqIndex)
        pgInteractor.pageDelegate = self.picsTimeline
        pgInteractor.pageDataSource = self
        let fetchRecent = FetchRecent(firstPage: firstReqIndex)
        fetchRecent.delegate = pgInteractor
        pgInteractor.service = fetchRecent
        pgInteractor.setupService()

        picsTimeline.dataSource = self
        picsTimeline.delegate = self
        picsTimeline.prefetchDataSource = self
        picsTimeline.register(UINib(nibName: String(describing: PicViewCell.self), bundle: nil), forCellWithReuseIdentifier:
            String(describing: PicViewCell.self))
        picsTimeline.register(UINib(nibName: String(describing: LoadingCell.self), bundle: nil), forCellWithReuseIdentifier:
            String(describing: LoadingCell.self))
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = CGSize(width: estimatedWidth, height: estimatedWidth + 80)
        flowLayout.itemSize = UICollectionViewFlowLayout.automaticSize
        picsTimeline.collectionViewLayout = flowLayout

        picsTimeline.backgroundColor = .black
        picsTimeline.contentInset = UIEdgeInsets(top: 23, left: side_inset, bottom: 10, right: side_inset)
        picsTimeline.setupRefreshControl(self, selector:#selector(self.refreshPage))
    }
}

extension PicsqueTimeline: UICollectionViewDataSourcePrefetching {
    private func getURLs(_ collectionView: UICollectionView, For indexPaths: [IndexPath]) -> [URL] {

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

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        ImagePrefetcher(urls: getURLs(collectionView, For: indexPaths)).start()
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        ImagePrefetcher(urls: getURLs(collectionView, For: indexPaths)).stop()
    }
}

extension PicsqueTimeline: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        pgInteractor.shouldPrefetch(index: indexPath.item)
        if let cell = cell as? PicViewCell {
            cell.setImage()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? PicViewCell {
            cell.removeImage()
        }
    }

}

extension PicsqueTimeline: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pgInteractor.visibleRow()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item >= pgInteractor.count() {
            let loading = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: LoadingCell.self), for: indexPath) as! LoadingCell
            loading.activityIndicator.startAnimating()
            return loading
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PicViewCell.self), for: indexPath) as! PicViewCell
            let photo: Photo = pgInteractor.selectedItem(for: indexPath.item)
            cell.configureCell(with: photo, for: indexPath)
            return cell
        }
    }
}

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

    func addAllItems(items: [AnyObject]) {

        if let items = items as? [Photo] {
            pgInteractor.array = items
            for new in items {
                pgInteractor.dict[new.id] = new.id
            }
        }
    }
}

extension PicsqueTimeline {
    @objc
    func refreshPage() {
        pgInteractor.refreshPage()
    }
}
