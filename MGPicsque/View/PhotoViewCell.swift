//
//  PicViewCell.swift
//  MGPicsque
//
//  Created by Gupta, Mrigank on 28/11/18.
//  Copyright © 2018 Gupta, Mrigank. All rights reserved.
//

import UIKit
import Kingfisher

final class PhotoViewCell: UITableViewCell {
    @IBOutlet weak private var content: UIView!
    @IBOutlet weak private var picImage: UIImageView!
    @IBOutlet weak private var title: UILabel!
    private var downloadURL: URL?

    func configureCell(with source: (CellDataSource & CellStyling), for indexPath: IndexPath) {
        title.text = source.titleText
        downloadURL = source.imageURL()
        setImage(indexPath)
    }

    func setImage(_ indexPath: IndexPath) {
        if let downloadURL = downloadURL {
            let processor = RoundCornerImageProcessor(cornerRadius: 20)
            picImage.kf.setImage(with: downloadURL, placeholder: UIImage(named: "cellPlaceholder"),
                                 options:[.processor(processor), .transition(.fade(0.2))])
        }else {
            picImage.image = UIImage(named: "cellPlaceholder")
        }
    }

    func removeImage() {
        picImage.image = nil
    }
}

protocol CellDataSource {
    var titleText: String { get }
}

protocol CellStyling {
    func imageURL() -> URL?
}

extension Photo: CellStyling, CellDataSource {

    func imageURL() -> URL? {
        guard let url = url360Small ?? url240Small else {
            return nil
        }
        return URL(string: url)
    }

    var titleText: String {
        return title
    }

}
