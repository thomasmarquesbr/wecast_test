//
//  PostCell.swift
//  wecast_player
//
//  Created by Thomás Marques Brandão Reis on 02/02/19.
//  Copyright © 2019 Thomás Marques Brandão Reis. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {
    
    @IBOutlet var thumb: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet var downloadButton: UIButton!
    
    func config(_ post: Post, thumbUrl: String) {
        self.title.text = post.title
        if post.isPlaying {
            self.downloadButton.loadingIndicator(false)
            self.downloadButton.setImage(UIImage(named: "pause-white"), for: .normal)
        } else {
            if post.downloadStatus == .none {
                self.downloadButton.loadingIndicator(false)
                self.downloadButton.setImage(UIImage(named: "download"), for: .normal)
            } else if post.downloadStatus == .downloading {
                self.downloadButton.loadingIndicator(true)
            } else { // .completed
                self.downloadButton.loadingIndicator(false)
                self.downloadButton.setImage(UIImage(named: "play-white"), for: .normal)
            }
        }
        self.thumb.kf.setImage(with: URL(string: thumbUrl))
        self.thumb.alpha = 0.9
    }
    
}
