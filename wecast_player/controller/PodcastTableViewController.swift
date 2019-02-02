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

class PodcastTableViewController: UITableViewController {
    
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
    
    
    //MARK:- Private functions
    
    func populateListPosts(_ feed: RSSFeed) {
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
    
    func getFeedRSS() {
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
    
}
