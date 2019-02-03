//
//  StorageController.swift
//  wecast_player
//
//  Created by Thomás Marques Brandão Reis on 03/02/19.
//  Copyright © 2019 Thomás Marques Brandão Reis. All rights reserved.
//

import UIKit

class StorageController {
    
    func getLocalPath(_ url: URL) -> URL {
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectoryURL.appendingPathComponent(url.lastPathComponent)
    }
    
    func executeDownload(_ post: Post, _ localPathUrl: URL, completion: @escaping(Bool) -> ()) {
        URLSession.shared.downloadTask(with: post.urlMedia, completionHandler: { (location, response, error) -> Void in
            guard let location = location, error == nil else { return }
            do {
                try FileManager.default.moveItem(at: location, to: localPathUrl)
                post.pathMedia = localPathUrl
                completion(true)
            } catch let error as NSError {
                print(error.localizedDescription)
                completion(false)
            }
        }).resume()
    }
    
    func audioAlreadyDownloaded(_ localPathUrl: URL) -> Bool {
        return FileManager.default.fileExists(atPath: localPathUrl.path)
    }
    
    
}
