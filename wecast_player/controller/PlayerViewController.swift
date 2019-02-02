//
//  PlayerViewController.swift
//  wecast_player
//
//  Created by Thomás Marques Brandão Reis on 02/02/19.
//  Copyright © 2019 Thomás Marques Brandão Reis. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {
    
    var player: AVPlayer?
    var currentTime = CMTimeMake(value: 0, timescale: 1)
    var currentEpisodeIndex = 0
    var posts = [Post]()
    var urlImage: String?
    var episodeTitle: String?
    var timer: Timer?
    
    @IBOutlet var rewindButton: UIButton!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var fowardButton: UIButton!
    @IBOutlet var timelineSlider: UISlider!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        if let urlImage = self.urlImage {
            imageView.kf.setImage(with: URL(string: urlImage))
        }
        if let episodeTitle = self.episodeTitle {
            titleLabel.text = episodeTitle
        }
    }
    
    func prepareNextItemToPlay(_ currentEpisodeIndex: Int = 0) {
        let mediaUrl = posts[currentEpisodeIndex].urlMedia
        let playerItem = AVPlayerItem(url: mediaUrl)
        playerItem.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        player = AVPlayer(playerItem: playerItem)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is AVPlayerItem, keyPath == "playbackLikelyToKeepUp" {
            guard let playerItem = player?.currentItem else { return }
            let maxVal = Float(CMTimeGetSeconds(playerItem.duration))
            if !maxVal.isNaN {
                timelineSlider.maximumValue = Float(CMTimeGetSeconds(playerItem.duration))
                timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
            }
        }
    }
    
    
    //MARK:- Button Actions
    
    @IBAction func didRewind(_ sender: Any) {
        currentEpisodeIndex = (currentEpisodeIndex == 0) ? posts.endIndex - 1 : currentEpisodeIndex - 1
        prepareNextItemToPlay(currentEpisodeIndex)
        player?.play()
    }
    
    @IBAction func didPlayPause(_ sender: Any) {
        if player?.rate == 0 || player == nil {
            playButton.setImage(UIImage(named: "pause"), for: .normal)
            prepareNextItemToPlay(currentEpisodeIndex)
            player?.seek(to: currentTime)
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player!.currentItem)
            player?.play()
        } else {
            playButton.setImage(UIImage(named: "play"), for: .normal)
            currentTime = player?.currentTime() ?? CMTimeMake(value: 0, timescale: 1)
            player?.pause()
        }
    }
    
    @IBAction func didFoward(_ sender: Any) {
        currentEpisodeIndex = (currentEpisodeIndex == posts.endIndex - 1) ? 0 : currentEpisodeIndex + 1
        prepareNextItemToPlay(currentEpisodeIndex)
        player?.play()
    }
    
    @IBAction func changeAudioTime(_ sender: Any) {
        player?.pause()
        guard let sliderValue = Float64(exactly: timelineSlider.value) else { return }
        let timeToSeek = CMTimeMakeWithSeconds(sliderValue, preferredTimescale: 1)
        player?.seek(to: timeToSeek)
        player?.play()
    }
    
    
    //MARK:- Selector
    
    @objc func updateSlider() {
        guard let currentItem = player?.currentItem else { return }
        let valueSlider = Float(currentItem.currentTime().seconds)
        if valueSlider <= timelineSlider.maximumValue {
            timelineSlider.value = valueSlider
        }
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        currentEpisodeIndex = (currentEpisodeIndex == posts.endIndex - 1) ? 0 : currentEpisodeIndex + 1
        prepareNextItemToPlay(currentEpisodeIndex)
        player?.play()
    }
    
    
}
