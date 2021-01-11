//
//  DetailsCollectionViewCell.swift
//  MarvelChallenge
//
//  Created by c80256a on 11/01/21.
//  Copyright © 2021 Henrique Silva. All rights reserved.
//

import UIKit

class DetailsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var borderedView: UIView!
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCell(description: String){
        self.labelDescription.text = description
        self.borderedView.layer.borderWidth = 1
        self.borderedView.layer.borderColor = UIColor.white.cgColor
        self.borderedView.layer.masksToBounds = true
        self.borderedView.layer.cornerRadius = 10
    }
    
}
