//
//  PhotoCell.swift
//  Pinterest
//
//  Created by arafat on 9/22/19.
//  Copyright © 2019 Pinterest. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
  @IBOutlet private weak var containerView: UIView!
  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var captionLabel: UILabel!
  @IBOutlet private weak var commentLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    containerView.layer.cornerRadius = 6
    containerView.layer.masksToBounds = true
  }


  var photo: CellViewModel? {
    didSet {
      if let photo = photo {
        imageView.image = photo.image
        captionLabel.text = photo.userName
        commentLabel.text = "Likes: \(photo.likes)"
      }
    }
  }
}
