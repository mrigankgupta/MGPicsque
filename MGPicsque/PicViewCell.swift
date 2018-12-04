//
//  PicViewCell.swift
//  MGPicsque
//
//  Created by Gupta, Mrigank on 28/11/18.
//  Copyright © 2018 Gupta, Mrigank. All rights reserved.
//

import UIKit
import Kingfisher

class PicViewCell: UICollectionViewCell {
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var picImage: UIImageView!
    @IBOutlet weak var descript: UILabel!
    @IBOutlet weak var title: UILabel!
    var downloadURL: URL?

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    func configureCell(with source: (CellDataSource & CellStyling), for indexPath: IndexPath) {
        title.text = source.titleText
        descript.text = source.descText
        downloadURL = source.imageURL()
    }

    func setImage() {
        if let downloadURL = downloadURL {
            picImage.kf.setImage(with: downloadURL)
        }else {
            picImage.image = nil
        }
    }

    func removeImage() {
        picImage.image = nil
    }
}

protocol CellDataSource {
    var titleText: String { get }
    var descText: String? { get }
}

protocol CellStyling {
    func imageURL() -> URL?
}

extension Photo: CellStyling, CellDataSource {
    var descText: String? {
        return description
    }

    func imageURL() -> URL? {
        guard let url = url240Small else {
            return nil
        }
        return URL(string: url)
    }

    var titleText: String {
        return title
    }

}
