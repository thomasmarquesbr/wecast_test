//
//  PlayerViewController.swift
//  wecast_player
//
//  Created by Thomás Marques Brandão Reis on 02/02/19.
//  Copyright © 2019 Thomás Marques Brandão Reis. All rights reserved.
//

import UIKit
import AVFoundation.AVPlayerItem
import Kingfisher

class PlayerViewController: UIViewController {

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
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.view.backgroundColor = UIColor.white
    }
    
    fileprivate func initComponentViews() {
        timelineSlider.thumbImage(for: )
        updateComponentViews()
        guard let audioPlayerController = audioPlayerController else { return }
        
        audioPlayerController.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
    
        if audioPlayerController.isPlaying() {
            playButton.setImage(UIImage(named: "pause"), for: .normal)
            audioPlayerController.addObserverOfCurrentItemToNotificationCenter(self,
                                                                               selector: #selector(playerDidFinishPlaying),
                                                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime)
        }
    }
    
    fileprivate func updateComponentViews() {
        if let urlImage = self.urlImage {
            imageView.kf.setImage(with: URL(string: urlImage))
            imageView.alpha = 0.95
        }
        titleLabel.text = currentEpisode?.title
        titleLabel.font = UIFont(name: "ChalkboardSE-Bold", size: 25.0)
        titleLabel.textColor = Color.forText
        if let index = posts.firstIndex(where: { $0.title == currentEpisode?.title }) {
            currentEpisodeIndex = index
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is AVPlayerItem, keyPath == "playbackLikelyToKeepUp" {
            guard let duration = audioPlayerController?.getDuration() else { return }
            timelineSlider.maximumValue = duration
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
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
            audioPlayerController.addObserverOfCurrentItemToNotificationCenter(self,
                                                                               selector: #selector(playerDidFinishPlaying),
                                                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime)
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
        audioPlayerController?.pause()
        guard let sliderValue = Float64(exactly: timelineSlider.value) else { return }
        audioPlayerController?.seekToAndPlay(value: sliderValue)
        audioPlayerController?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
    }
    
    @IBAction func didBackStep10(_ sender: Any) {
        guard let currentTime = audioPlayerController?.getCurrentTime() else { return }
        guard let value = Float64(exactly: currentTime - 10) else { return }
        audioPlayerController?.seekToAndPlay(value: value)
    }
    
    @IBAction func didFoward30(_ sender: Any) {
        guard let currentTime = audioPlayerController?.getCurrentTime() else { return }
        guard let value = Float64(exactly: currentTime + 30) else { return }
        audioPlayerController?.seekToAndPlay(value: value)
    }
    
    
    //MARK:- Selector
    
    @objc func updateSlider() {
        guard let currentTime = audioPlayerController?.getCurrentTime() else { return }
        if currentTime <= timelineSlider.maximumValue {
            timelineSlider.value = currentTime
        }
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        currentEpisodeIndex = (currentEpisodeIndex == posts.endIndex - 1) ? 0 : currentEpisodeIndex + 1
        let episode = posts[currentEpisodeIndex]
        audioPlayerController?.play(post: episode, completion: { _ in })
        currentEpisode = episode
        updateComponentViews()
    }
    
}
