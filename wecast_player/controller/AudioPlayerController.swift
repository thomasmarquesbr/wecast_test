//
//  AVAudioPlayerController.swift
//  wecast_player
//
//  Created by Thomás Marques Brandão Reis on 03/02/19.
//  Copyright © 2019 Thomás Marques Brandão Reis. All rights reserved.
//

import UIKit
import AVFoundation

class AudioPlayerController {
    
    var player: AVAudioPlayer?
    var lastPlayed: Post?
    
    func prepareLastPlayed(_ post: Post, _ posts: [Post]) -> IndexPath? {
        lastPlayed?.isPlaying = false
        var indexPathLastPlayed: IndexPath?
        if let lastPlayed = lastPlayed, let indexLastPost = posts.firstIndex(where: {
            $0.title == lastPlayed.title }) {
            indexPathLastPlayed = IndexPath(row: indexLastPost, section: 0)
        }
        lastPlayed = post
        return indexPathLastPlayed
    }
    
    func play(_ posts: [Post], _ indexPath: IndexPath, completion: @escaping([IndexPath])->()) {
        let post = posts[indexPath.row]
        var rowsToReload = [indexPath]
    
        if let player = player, player.url?.absoluteURL == post.pathMedia?.absoluteURL {
 
            if player.isPlaying {
                player.pause()
                post.isPlaying = false
            } else {
                player.play()
                post.isPlaying = true
 
                if let indexPathLastPlayed = prepareLastPlayed(post, posts) {
                    rowsToReload.append(indexPathLastPlayed)
                }
            }
            completion(rowsToReload)
            
        } else {
            
            do {
                guard let pathMedia = post.pathMedia else { return }
                player = try AVAudioPlayer(contentsOf: pathMedia)
                player?.prepareToPlay()
                player?.volume = 1.0
                player?.play()
                post.isPlaying = true
                
                if let indexPathLastPlayed = prepareLastPlayed(post, posts) {
                    rowsToReload.append(indexPathLastPlayed)
                }
                
                completion(rowsToReload)

            } catch let error as NSError {
                print("playing error: \(error.localizedDescription)")
            } catch {
                print("AVAudioPlayer init failed")
            }
            
        }
    }
    
    
}
