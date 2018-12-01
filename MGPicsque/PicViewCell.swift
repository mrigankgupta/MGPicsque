//
//  PicViewCell.swift
//  MGPicsque
//
//  Created by Gupta, Mrigank on 28/11/18.
//  Copyright © 2018 Gupta, Mrigank. All rights reserved.
//

import UIKit

class PicViewCell: UICollectionViewCell {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var picImage: UIImageView!
    @IBOutlet weak var descript: UILabel!
    @IBOutlet weak var title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
