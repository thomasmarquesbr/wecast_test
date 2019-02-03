//
//  PodcastTableViewController.swift
//  wecast_player
//
//  Created by Thomás Marques Brandão Reis on 02/02/19.
//  Copyright © 2019 Thomás Marques Brandão Reis. All rights reserved.
//

import UIKit
import FeedKit
import Kingfisher
import AVFoundation
import NVActivityIndicatorView

class PodcastTableViewController: UITableViewController {
    
    var player: AVAudioPlayer?
    let feedURL = URL(string: "http://feeds.feedburner.com/podcastmrg")!
    let dateFormatter = DateFormatter()
    var thumbFeedURL = ""
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.separatorStyle = .none
        dateFormatter.dateFormat = "dd-MM-yyyy"
        getFeedRSS()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK:- List Functions
    
    fileprivate func populateListPosts(_ feed: RSSFeed) {
        for item in feed.items! {
            if let post = Post(item: item) {
                self.posts.append(post)
            }
        }
        self.posts = self.posts.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
        self.tableView.reloadData()
    }
    
    fileprivate func getFeedRSS() {
        let parser = FeedParser(URL: feedURL)
        parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { (result) in
            DispatchQueue.main.async {
                guard let feed = result.rssFeed, result.isSuccess else {
                    print(result.error as Any)
                    return
                }
                guard let podName = feed.title else { return }
                self.title = podName
                guard let thumbUrl = feed.image?.url else { return }
                self.thumbFeedURL = thumbUrl
                self.populateListPosts(feed)
            }
        }
    }
    
    
    //MARK:- TableViewDelegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        cell.title.text = post.title
        cell.subtitle.text = post.subTitle
        let isAlreadyDownload = audioAlreadyDownloaded(getLocalPath(post.urlMedia))
        let img: String
        if isAlreadyDownload {
            posts[indexPath.row].pathMedia = getLocalPath(post.urlMedia)
            img = "play"
        } else {
            img = "download"
        }
        cell.downloadButton.setImage(UIImage(named: img), for: .normal)
        cell.downloadButton.tag = indexPath.row
        cell.downloadButton.addTarget(self, action: #selector(tapDownloadOrPlay(sender:)), for: .touchUpInside)
        cell.thumb.kf.setImage(with: URL(string: thumbFeedURL))
        return cell
    }
    
    
    //MARK:- Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "postSegue", let itemRow = self.tableView.indexPathForSelectedRow?.row {
            let playerViewController = segue.destination as! PlayerViewController
            playerViewController.currentEpisodeIndex = itemRow
            playerViewController.posts = posts
            playerViewController.urlImage = self.thumbFeedURL
            playerViewController.episodeTitle = posts[itemRow].title
        }
    }
    
    
    //MARK:- Download functions
    
    fileprivate func getLocalPath(_ url: URL) -> URL {
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectoryURL.appendingPathComponent(url.lastPathComponent)
    }
    
    fileprivate func executeDownload(_ post: Post, _ localPathUrl: URL, completion: @escaping(Bool) -> ()) {
        URLSession.shared.downloadTask(with: post.urlMedia, completionHandler: { (location, response, error) -> Void in
            guard let location = location, error == nil else { return }
            do {
                // after downloading your file you need to move it to your destination url
                try FileManager.default.moveItem(at: location, to: localPathUrl)
//                self.play(localPathUrl)
                completion(true)
            } catch let error as NSError {
                print(error.localizedDescription)
                completion(false)
            }
        }).resume()
    }
    
    fileprivate func audioAlreadyDownloaded(_ localPathUrl: URL) -> Bool {
        return FileManager.default.fileExists(atPath: localPathUrl.path)
    }
    
    @objc func tapDownloadOrPlay(sender: UIButton)  {
        let index = sender.tag
        let post = posts[index]
        print(post.title)
        let localPathUrl = getLocalPath(post.urlMedia)
        if audioAlreadyDownloaded(localPathUrl) {
            play(localPathUrl, button: sender)
        } else {
            sender.loadingIndicator(true)
            executeDownload(post, localPathUrl, completion: { (success) in
                DispatchQueue.main.async {
                    sender.loadingIndicator(false)
                    let button = (success) ? "play" : "download"
                    sender.setImage(UIImage(named: button), for: .normal)
                }
            })
        }
    }
    
    var lastButtonClicked: UIButton?
    
    fileprivate func play(_ localPathUrl: URL, button: UIButton) {
        if let player = player, player.url?.absoluteURL == localPathUrl.absoluteURL {
            if player.isPlaying {
                player.pause()
                button.setImage(UIImage(named: "play"), for: .normal)
            } else {
                player.play()
                lastButtonClicked?.setImage(UIImage(named: "play"), for: .normal)
                button.setImage(UIImage(named: "pause"), for: .normal)
                lastButtonClicked = button
            }
        } else {
            do {
                player = try AVAudioPlayer(contentsOf: localPathUrl)
                player?.prepareToPlay()
                player?.volume = 1.0
                player?.play()
                lastButtonClicked?.setImage(UIImage(named: "play"), for: .normal)
                button.setImage(UIImage(named: "pause"), for: .normal)
                lastButtonClicked = button
            } catch let error as NSError {
                print("playing error: \(error.localizedDescription)")
            } catch {
                print("AVAudioPlayer init failed")
            }
        }
    }
    
}

extension UIButton {
    func loadingIndicator(_ show: Bool) {
        let tag = 808404
        if show {
            self.isEnabled = false
            self.alpha = 0.5
//            let indicator = UIActivityIndicatorView()
            self.setImage(nil, for: .normal)
            let color = UIColor(red: CGFloat(65/255.0), green: CGFloat(69/255.0), blue: CGFloat(70/255.0), alpha: 1)
            let indicator = NVActivityIndicatorView(frame: self.frame, type: NVActivityIndicatorType.circleStrokeSpin, color: color, padding: 3.0)
            let buttonHeight = self.bounds.size.height
            let buttonWidth = self.bounds.size.width
            indicator.center = CGPoint(x: buttonWidth/2, y: buttonHeight/2)
            indicator.tag = tag
            self.addSubview(indicator)
            indicator.startAnimating()
        } else {
            self.isEnabled = true
            self.alpha = 1.0
//            if let indicator = self.viewWithTag(tag) as? UIActivityIndicatorView {
            if let indicator = self.viewWithTag(tag) as? NVActivityIndicatorView {
                indicator.stopAnimating()
                indicator.removeFromSuperview()
            }
        }
    }
}
