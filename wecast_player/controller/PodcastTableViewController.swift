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
    
//    var player: AVAudioPlayer?
    var audioPlayerController = AudioPlayerController()
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
                let localPathUrl = getLocalPath(post.urlMedia)
                if audioAlreadyDownloaded(localPathUrl) {
                    post.pathMedia = localPathUrl
                    post.downloadStatus = .completed
                }
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
        cell.config(post, thumbUrl: thumbFeedURL)
        cell.downloadButton.tag = indexPath.row
        cell.downloadButton.addTarget(self, action: #selector(tapDownloadOrPlay(sender:)), for: .touchUpInside)
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
                try FileManager.default.moveItem(at: location, to: localPathUrl)
                post.pathMedia = localPathUrl
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
        let row = sender.tag
        let indexPath = IndexPath(item: row, section: 0)
        let post = posts[row]
        let localPathUrl = getLocalPath(post.urlMedia)
        if audioAlreadyDownloaded(localPathUrl) {
            audioPlayerController.play(posts, indexPath) { (rowsToReload) in
                print(rowsToReload.count)
                self.tableView.reloadRows(at: rowsToReload, with: .none)
            }
        } else {
            post.downloadStatus = .downloading
            tableView.reloadRows(at: [indexPath], with: .none)
            executeDownload(post, localPathUrl, completion: { (success) in
                DispatchQueue.main.async {
                    post.downloadStatus = (success) ? .completed : .none
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
            })
        }
    }
    
}
