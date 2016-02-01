//
//  MoviesViewController.swift
//  Flicks
//
//  Created by zeus medina on 1/23/16.
//  Copyright © 2016 Zeus. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{

    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
       
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        let apiKey = "4d21457ec061216428cf33f6389e48cc"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)

        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                            print("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as! [NSDictionary]
                            self.tableView.reloadData()
                            
                            
                            
                            
                    }
                }
        })
        task.resume()
    }
    
    func getMovieData() {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        
        if let posterPath = movie["poster_path"] as? String {
            let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
            let posterUrl = NSURL(string: posterBaseUrl + posterPath)
            cell.posterView.setImageWithURL(posterUrl!)
        }
        else {
            // No poster image. Can either set to nil (no image) or a default movie poster image
            // that you include as an asset
            cell.posterView.image = nil
        }
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
       
        print("row \(indexPath.row) ")
        return cell
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        // ... Create the NSURLRequest (myRequest) ...
        let apiKey = "4d21457ec061216428cf33f6389e48cc"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let myRequest = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(myRequest,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                            
                            self.movies = responseDictionary["results"] as! [NSDictionary]
                            
                            self.tableView.reloadData()
                            
                            // Tell the refreshControl to stop spinning
                            refreshControl.endRefreshing()
                    }
                }
        })
        task.resume()
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movie
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


}
