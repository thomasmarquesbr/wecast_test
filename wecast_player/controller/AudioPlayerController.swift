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
   
    fileprivate var avPlayer: AVPlayer?
    fileprivate var avPlayerItem: AVPlayerItem?
    fileprivate var currentPost: Post?
    fileprivate var lastPost: Post?
    fileprivate var currentTime = CMTime(value: 0, timescale: 1)
    fileprivate var zeroTime = CMTime(value: 0, timescale: 1)
    
    fileprivate func preparePlayer(urlOrPathMedia: URL) {
        avPlayerItem = AVPlayerItem(url: urlOrPathMedia)
        avPlayer = AVPlayer(playerItem: avPlayerItem)
        
    }
    
    func play(post: Post, completion: @escaping([Post])->()) {
        var listToUpdate = [Post]()
        currentPost = post
        var url = post.urlMedia
        if let pathMedia = currentPost?.pathMedia, currentPost?.downloadStatus == .completed {
            url = pathMedia
        }
        
        if lastPost?.title != currentPost?.title { // play new audio
            avPlayer?.pause()
            lastPost?.isPlaying = false
            if let last = lastPost {
                listToUpdate.append(last)
            }
            preparePlayer(urlOrPathMedia: url)
            avPlayer?.play()
            currentPost?.isPlaying = true
            lastPost = currentPost
        } else if avPlayer?.rate == 0 { // play atual
            avPlayer?.seek(to: currentTime)
            avPlayer?.play()
            currentPost?.isPlaying = true
            lastPost = currentPost
        } else { //pause atual
            currentTime = avPlayerItem?.currentTime() ?? zeroTime
            avPlayer?.pause()
            currentPost?.isPlaying = false
        }
        
        if let current = currentPost {
            listToUpdate.append(current)
        }
        completion(listToUpdate)
    }
    
    func pause() {
        currentTime = avPlayerItem?.currentTime() ?? zeroTime
        avPlayer?.pause()
    }
    
    func seekToAndPlay(value: Float64) {
        let timeToSeek = CMTimeMakeWithSeconds(value, preferredTimescale: 1)
        avPlayer?.seek(to: timeToSeek)
        avPlayer?.play()
    }
    
    func isPlaying() -> Bool {
        return !(avPlayer?.rate == 0 || avPlayer == nil)
    }
    
    func isPlaying(_ post: Post) -> Bool {
        return lastPost?.title == post.title
    }
    
    func addObserver(_ observer: NSObject, forKeyPath: String, options: NSKeyValueObservingOptions, context: UnsafeMutableRawPointer?) {
        avPlayerItem?.addObserver(observer, forKeyPath: forKeyPath, options: options, context: context)
    }
    
    func addObserverOfCurrentItemToNotificationCenter(_ observer: Any, selector: Selector, name: NSNotification.Name?) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: name, object: avPlayer?.currentItem)
    }
    
    func getDuration() -> Float? {
        guard let playerItem = avPlayer?.currentItem else { return nil }
        let duration = Float(CMTimeGetSeconds(playerItem.duration))
        return (duration.isNaN) ? nil : duration
    }
    
    func getCurrentTime() -> Float? {
        guard let currentItem = avPlayer?.currentItem else { return nil }
        return Float(currentItem.currentTime().seconds)
    }
    
}
