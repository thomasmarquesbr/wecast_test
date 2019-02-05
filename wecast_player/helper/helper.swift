//
//  helper.swift
//  wecast_player
//
//  Created by Thomás Marques Brandão Reis on 04/02/19.
//  Copyright © 2019 Thomás Marques Brandão Reis. All rights reserved.
//

import UIKit

func statusBarHeight() -> CGFloat {
    let statusBarSize = UIApplication.shared.statusBarFrame.size
    return Swift.min(statusBarSize.width, statusBarSize.height)
}

func getIndexOf(_ post: Post, inList: [Post]) -> Int? {
    return inList.firstIndex(where: { $0.title == post.title })
}
