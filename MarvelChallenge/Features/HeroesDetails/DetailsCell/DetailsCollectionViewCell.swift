//
//  DetailsCollectionViewCell.swift
//  MarvelChallenge
//
//  Created by c80256a on 11/01/21.
//  Copyright © 2021 Henrique Silva. All rights reserved.
//

import UIKit
import MarvelDesignSystem

class DetailsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var borderedView: UIView!
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCell(description: String){
        self.labelDescription.text = description
        self.labelDescription.font = DesignSystem.Typography.caption
        self.labelDescription.textColor = DesignSystem.Color.textPrimary
        self.borderedView.backgroundColor = DesignSystem.Color.surface
        self.borderedView.layer.borderWidth = 1
        self.borderedView.layer.borderColor = DesignSystem.Color.border.cgColor
        self.borderedView.layer.masksToBounds = true
        self.borderedView.layer.cornerRadius = DesignSystem.Radius.medium
    }
    
}
