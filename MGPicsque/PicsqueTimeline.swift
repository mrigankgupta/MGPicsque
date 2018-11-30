//
//  ViewController.swift
//  MGPicsque
//
//  Created by Gupta, Mrigank on 26/11/18.
//  Copyright © 2018 Gupta, Mrigank. All rights reserved.
//

import UIKit

class PicsqueTimeline: UIViewController {
    @IBOutlet weak var picsTimeline: UICollectionView!
    var response: PagedResponse<Photo>?

    override func viewDidLoad() {
        super.viewDidLoad()
        picsTimeline.dataSource = self
        picsTimeline.delegate = self
        let fetchRecent = FetchRecent()
        fetchRecent.fetchRecentPics()
        fetchRecent.delegate = self
        picsTimeline.register(UINib(nibName: String(describing: PicViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: PicViewCell.self))
    }
}

extension PicsqueTimeline: UICollectionViewDelegate {

}

extension PicsqueTimeline: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return response?.types.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PicViewCell.self), for: indexPath) as! PicViewCell
        cell.descript.text = response?.types[indexPath.row].id
        return cell
    }
}

extension PicsqueTimeline: WebResponse {
    func returnedResponse<T>(_ item: PagedResponse<T>?) where T : Decodable {
        if let item = item as? PagedResponse<Photo> {
            response = item
            DispatchQueue.main.async {
                self.picsTimeline.reloadData()
            }
        }
    }
}
