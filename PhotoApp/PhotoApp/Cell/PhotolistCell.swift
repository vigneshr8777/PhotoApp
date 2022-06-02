//
//  PhotolistCell.swift
//  PhotoApp
//
//  Created by Vignesh Radhakrishnan on 02/06/20.
//  Copyright © 2020 Sample. All rights reserved.
//

import Foundation
import UIKit

final class PhotolistCell : UICollectionViewCell {
    
    private var profilePicturePath: String?
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    func configureCell(withViewModel viewModel: ListCellViewModel) {

        if let path = viewModel.profilePicturePath {
            profilePicturePath = path
            ImageDownloader.sharedImageDownloader.download(path: path, placeHolderImage: UIImage(named: "")) { [weak self] (image) in
                guard let self = self else {
                    return
                }
                if self.profilePicturePath == path {
                    self.photoImageView.image = image
                }
            }
        }
    }
    
    override func prepareForReuse() {
           super.prepareForReuse()
           photoImageView.image = UIImage(named:"")
       }
}
