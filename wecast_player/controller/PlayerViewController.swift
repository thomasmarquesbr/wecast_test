//
//  PlayerViewController.swift
//  wecast_player
//
//  Created by Thomás Marques Brandão Reis on 02/02/19.
//  Copyright © 2019 Thomás Marques Brandão Reis. All rights reserved.
//

import UIKit
import AVFoundation
import Kingfisher
import TransitionTreasury
import TransitionAnimation

class PlayerViewController: UIViewController, NavgationTransitionable {
    
    var tr_pushTransition: TRNavgationTransitionDelegate?
    var audioPlayerController: AudioPlayerController?
    var currentEpisodeIndex = 0
    var currentEpisode: Post?
    var posts = [Post]()
    var urlImage: String?
    var timer: Timer?
    var backTitle: String?
    
    @IBOutlet var rewindButton: UIButton!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var fowardButton: UIButton!
    @IBOutlet var timelineSlider: UISlider!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configNavigationBar()
        initComponentViews()
    }
    
    fileprivate func configNavigationBar() {
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: statusBarHeight(), width: self.view.frame.width, height: 50))
        navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationBar.shadowImage = UIImage()
        view.addSubview(navigationBar)
        
        let backButton = UIBarButtonItem(title: backTitle, style: .done, target: self, action: #selector(didTapBackNavigation))
        let navigationItem = UINavigationItem(title: "")
        navigationItem.leftBarButtonItem = backButton
        navigationBar.items = [navigationItem]
    }
    
    
    fileprivate func initComponentViews() {
        updateComponentViews()
        guard let audioPlayerController = audioPlayerController else { return }
        audioPlayerController.avPlayerItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        if audioPlayerController.isPlaying() {
            playButton.setImage(UIImage(named: "pause"), for: .normal)
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: audioPlayerController.avPlayer?.currentItem)
        }
    }
    
    fileprivate func updateComponentViews() {
        if let urlImage = self.urlImage {
            imageView.kf.setImage(with: URL(string: urlImage))
        }
        titleLabel.text = currentEpisode?.title
        if let index = posts.firstIndex(where: { $0.title == currentEpisode?.title }) {
            currentEpisodeIndex = index
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is AVPlayerItem, keyPath == "playbackLikelyToKeepUp" {
            guard let playerItem = audioPlayerController?.avPlayer?.currentItem else { return }
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
        let episode = posts[currentEpisodeIndex]
        audioPlayerController?.play(post: episode, completion: { _ in })
        currentEpisode = episode
        updateComponentViews()
    }
    
    @IBAction func didPlayPause(_ sender: Any) {
        guard let audioPlayerController = audioPlayerController else { return }
        var img = "pause"
        if audioPlayerController.isPlaying() {
            img = "play"
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: audioPlayerController.avPlayer?.currentItem)
        }
        playButton.setImage(UIImage(named: img), for: .normal)
        let episode = posts[currentEpisodeIndex]
        audioPlayerController.play(post: episode, completion: {_ in })
    }
    
    @IBAction func didFoward(_ sender: Any) {
        currentEpisodeIndex = (currentEpisodeIndex == posts.endIndex - 1) ? 0 : currentEpisodeIndex + 1
        let episode = posts[currentEpisodeIndex]
        audioPlayerController?.play(post: episode, completion: { _ in })
        currentEpisode = episode
        updateComponentViews()
    }
    
    @IBAction func changeAudioTime(_ sender: Any) {
        audioPlayerController?.avPlayer?.pause()
        guard let sliderValue = Float64(exactly: timelineSlider.value) else { return }
        let timeToSeek = CMTimeMakeWithSeconds(sliderValue, preferredTimescale: 1)
        audioPlayerController?.avPlayer?.seek(to: timeToSeek)
        audioPlayerController?.avPlayer?.play()
        guard let audioPlayerController = audioPlayerController else { return }
        audioPlayerController.avPlayerItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
    }
    
    
    //MARK:- Selector
    
    @objc func updateSlider() {
        guard let currentItem = audioPlayerController?.avPlayer?.currentItem else { return }
        let valueSlider = Float(currentItem.currentTime().seconds)
        if valueSlider <= timelineSlider.maximumValue {
            timelineSlider.value = valueSlider
        }
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        currentEpisodeIndex = (currentEpisodeIndex == posts.endIndex - 1) ? 0 : currentEpisodeIndex + 1
        let episode = posts[currentEpisodeIndex]
        audioPlayerController?.play(post: episode, completion: { _ in })
        currentEpisode = episode
        updateComponentViews()
    }
    
    @objc func didTapBackNavigation() {
        _ = navigationController?.tr_popViewController({ () -> Void in
            print("Pop finished.")
        })
    }
    
}
