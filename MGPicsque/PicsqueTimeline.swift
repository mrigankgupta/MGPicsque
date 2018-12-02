//
//  ViewController.swift
//  MGPicsque
//
//  Created by Gupta, Mrigank on 26/11/18.
//  Copyright © 2018 Gupta, Mrigank. All rights reserved.
//

import UIKit
import Kingfisher

class PicsqueTimeline: UIViewController {
    @IBOutlet weak var picsTimeline: UICollectionView!

    var pgInteractor: PageInteractor<Photo, String>!

    override func viewDidLoad() {
        super.viewDidLoad()
        pgInteractor = PageInteractor()
        pgInteractor.pageDelegate = self.picsTimeline
        pgInteractor.pageDataSource = self
        let fetchRecent = FetchRecent()
        fetchRecent.delegate = pgInteractor
        pgInteractor.service = fetchRecent
        pgInteractor.setupService()

        picsTimeline.dataSource = self
        picsTimeline.delegate = self
        picsTimeline.register(UINib(nibName: String(describing: PicViewCell.self), bundle: nil), forCellWithReuseIdentifier:
            String(describing: PicViewCell.self))
        picsTimeline.register(UINib(nibName: String(describing: LoadingCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: LoadingCell.self))
        let flowLayout = UICollectionViewFlowLayout()
//        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        flowLayout.itemSize = CGSize(width: 30, height: 80)
        picsTimeline.collectionViewLayout = flowLayout

        picsTimeline.backgroundColor = .clear
        picsTimeline.contentInset = UIEdgeInsets(top: 23, left: 16, bottom: 10, right: 16)
        picsTimeline.setupRefreshControl(self, selector:#selector(self.refreshPage))
    }
}

extension PicsqueTimeline: UICollectionViewDelegate {

}

extension PicsqueTimeline: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pgInteractor.visibleRow()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row >= pgInteractor.count() {
            let loading = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: LoadingCell.self), for: indexPath) as! LoadingCell
            loading.activityIndicator.startAnimating()
            return loading
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PicViewCell.self), for: indexPath) as! PicViewCell
            cell.title.text = "wtf"
            return cell
        }

    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        pgInteractor.shouldPrefetch(index: indexPath.row)
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
