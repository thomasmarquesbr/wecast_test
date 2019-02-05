//
//  Post.swift
//  wecast_player
//
//  Created by Thomás Marques Brandão Reis on 02/02/19.
//  Copyright © 2019 Thomás Marques Brandão Reis. All rights reserved.
//

import UIKit
import FeedKit

enum DownloadStatus {
    case none, downloading, completed
}

class Post {
    
    var title: String
    var subTitle: String
    var description: String
    var date: Date
    var urlMedia: URL
    var pathMedia: URL?
    var downloadStatus = DownloadStatus.none
    var isPlaying = false
    
    init?(item: RSSFeedItem) {
        guard let title = item.title else { return nil }
        guard let subTitle = item.description else { return nil }
        guard let description = item.description else { return nil }
        guard let date = item.pubDate else { return nil }
        guard let urlString = item.enclosure?.attributes?.url, let urlMedia = URL(string: urlString) else { return nil }
        self.title = title
        self.subTitle = subTitle.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        self.description = description
        self.date = date
        self.urlMedia = urlMedia
    }
    
}
