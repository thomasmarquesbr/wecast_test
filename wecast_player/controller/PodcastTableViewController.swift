//
//  PodcastTableViewController.swift
//  wecast_player
//
//  Created by Thomás Marques Brandão Reis on 02/02/19.
//  Copyright © 2019 Thomás Marques Brandão Reis. All rights reserved.
//

import UIKit
import FeedKit
import TransitionTreasury
import TransitionAnimation

class PodcastTableViewController: UITableViewController, ModalTransitionDelegate {
    
    var tr_presentTransition: TRViewControllerTransitionDelegate?
    
    var storageController = StorageController()
    var audioPlayerController = AudioPlayerController()
    let searchController = UISearchController(searchResultsController: nil)
    let feedURL = URL(string: "http://feeds.feedburner.com/podcastmrg")!
    let dateFormatter = DateFormatter()
    var thumbFeedURL = ""
    var posts = [Post]()
    var filteredPosts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSearchController()
//        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.isNavigationBarHidden = true
        tableView.separatorStyle = .none
        dateFormatter.dateFormat = "dd-MM-yyyy"
        getFeedRSS()
        print("viewDidLoad")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    
    //MARK:- List Functions
    
    fileprivate func populateListPosts(_ feed: RSSFeed) {
        for item in feed.items! {
            if let post = Post(item: item) {
                let localPathUrl = storageController.getLocalPath(post.urlMedia)
                if storageController.audioAlreadyDownloaded(localPathUrl) {
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
        if isFiltering() {
            return filteredPosts.count
        }
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let post = posts[indexPath.row]
        let post = (isFiltering()) ? filteredPosts[indexPath.row] : posts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        cell.config(post, thumbUrl: thumbFeedURL)
        cell.downloadButton.tag = indexPath.row
        cell.downloadButton.addTarget(self, action: #selector(tapDownloadOrPlay(sender:)), for: .touchUpInside)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = indexPath.row
        let post = (isFiltering()) ? filteredPosts[row] : posts[row]
        
        guard let cell = tableView.cellForRow(at: indexPath) as? PostCell else { return }
        let playerViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "playerViewController") as! PlayerViewController
        playerViewController.backTitle = self.title
        playerViewController.currentEpisodeIndex = (isFiltering()) ? getIndexOf(filteredPosts[row], inList: posts)! : row
        playerViewController.audioPlayerController = audioPlayerController
        playerViewController.urlImage = self.thumbFeedURL
        playerViewController.posts = posts
        playerViewController.currentEpisode = post
        audioPlayerController.play(post: post) { (listToUpdate) in
            let rows = self.rowsToUpdate(list: listToUpdate)
            self.tableView.reloadRows(at: rows, with: .none)
        }
        
        guard let logoImageView = cell.thumb else { return }
//        var logoImageView = UIImageView().kf.setImage(with: URL(fileURLWithPath: thumbFeedURL))
        let paramGcRect = CGRect(x: 20, y: 210, width: 374, height: 374)
        navigationController?.tr_pushViewController(playerViewController,
                                                    method: TRPushTransitionMethod.blixt(keyView: logoImageView, to: paramGcRect),
                                                    statusBarStyle: .lightContent,
                                                    completion: {})
    }
    
    
    //MARK:- Navigation
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "postSegue", let itemRow = self.tableView.indexPathForSelectedRow?.row {
//            let playerViewController = segue.destination as! PlayerViewController
//            playerViewController.currentEpisodeIndex = itemRow
//            playerViewController.audioPlayerController = audioPlayerController
//            playerViewController.urlImage = self.thumbFeedURL
//            playerViewController.posts = posts
//            let episode = (isFiltering()) ? filteredPosts[itemRow] : posts[itemRow]
//            playerViewController.currentEpisode = episode
//            audioPlayerController.play(post: episode) { (listToUpdate) in
//                let rows = self.rowsToUpdate(list: listToUpdate)
//                self.tableView.reloadRows(at: rows, with: .none)
//            }
//        }
//    }
    
    
    //MARK:- Actions
    
    func rowsToUpdate(list: [Post]) -> [IndexPath] {
        var rows = [IndexPath]()
        posts.forEach { (post) in
            if let index = getIndexOf(post, inList: posts) {
                rows.append(IndexPath(row: index, section: 0))
            }
        }
        return rows
    }
    
    @objc func tapDownloadOrPlay(sender: UIButton)  {
        let row = sender.tag
        let indexPath = IndexPath(item: row, section: 0)
        let post = (isFiltering()) ? filteredPosts[row] : posts[row]
        let localPathUrl = storageController.getLocalPath(post.urlMedia)
        if storageController.audioAlreadyDownloaded(localPathUrl) {
            let list = (isFiltering()) ? filteredPosts : posts
//            audioPlayerController.play(list, indexPath) { (rowsToReload) in
//                self.tableView.reloadRows(at: rowsToReload, with: .none)
//            }
            
            audioPlayerController.play(post: list[row]) { (listToUpdate) in
                let rows = self.rowsToUpdate(list: listToUpdate)
                self.tableView.reloadRows(at: rows, with: .none)
            }
        } else {
            post.downloadStatus = .downloading
            tableView.reloadRows(at: [indexPath], with: .none)
            storageController.executeDownload(post, localPathUrl, completion: { (success) in
                DispatchQueue.main.async {
                    post.downloadStatus = (success) ? .completed : .none
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
            })
        }
    }

}

extension PodcastTableViewController: UISearchResultsUpdating {
    
    func initSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Buscar episódio"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredPosts = posts.filter({( post: Post) -> Bool in
            return (post.title.lowercased().contains(searchText.lowercased()))
        })
        tableView.reloadData()
    }

    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
}
