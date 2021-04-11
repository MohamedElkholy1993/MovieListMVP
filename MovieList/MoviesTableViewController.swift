//
//  MoviesTableViewController.swift
//  MovieList
//
//  Created by moutaz hegazy on 3/8/21.
//  Copyright © 2021 Mohmaed_Elkholy. All rights reserved.
//

import UIKit
import CoreData
import Network
import SDWebImage
import Reachability

class MoviesTableViewController: UITableViewController{
    
    @IBOutlet weak var networkStatusIcon: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var presenter: MovieListPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = false
        self.title = "Movies List"
        presenter = MovieListPresenter(view: self)
        presenter.fetchMoviesData()
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return presenter.movies.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MovieTableViewCell
        
        // Configure the cell...
        cell.layer.cornerRadius = 20.0
        cell.layer.borderWidth  = 1.0
        cell.layer.borderColor  = UIColor.white.cgColor
        cell.backgroundColor    = UIColor.black
        cell.titleLabel.textColor = UIColor.white
        cell.titleLabel.text = presenter.movies[indexPath.row].title
        cell.ratingLabel.textColor = UIColor.white
        cell.ratingLabel.text = "Rating: "+String(presenter.movies[indexPath.row].rating)
        cell.releaseYearLabel.textColor = UIColor.white
        cell.releaseYearLabel.text = "Release Year: "+String(presenter.movies[indexPath.row].releaseYear)
        
        if let url = URL(string: presenter.movies[indexPath.row].image){
            cell.activityIndicator.startAnimating()
            
            cell.movieImage?.sd_setImage(with: url, completed: { (image, error, cacheType, url) in
                DispatchQueue.main.async {
                    cell.activityIndicator.stopAnimating()
                    if error != nil {
                        cell.movieImage.image = UIImage(named: "Image")
                    }
                }
            })
        }
        
        
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "movieDetails") as! MovieDetailsViewController
        vc.presenter = MoviePresenter(view: vc)
        vc.presenter.movieToView = presenter.movies[indexPath.row]
        tabBarController?.tabBar.isHidden = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (networkStatusIcon.tintColor == .red)
        {
            return true
        }else{
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            CoreDataLayer.sharedInstance.deleteFromStorage(from: &presenter.movieEntities, at: indexPath.row)
            presenter.movies.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditNewMovie") as! EditNewMovieViewController
        self.navigationController?.pushViewController(vc, animated: true)
        vc.dataSender = self
    }
    
    
}
    // MARK: - Delegation Implementaion
extension MoviesTableViewController:SendNewMovieEditedData{
    func sendNewMovieEditedDataBack(newEditedMovie: Movie) {
        
        presenter.movies.append(newEditedMovie)
        CoreDataLayer.sharedInstance.saveToStorage(movie: newEditedMovie)
        self.tableView.reloadData()
    }
    
}

extension MoviesTableViewController: MovieListView {
    func startLoading() {
        self.activityIndicator.startAnimating()
    }
    
    func finishLoading() {
        self.activityIndicator.stopAnimating()
    }
    
    func reloadTableView() {
        self.tableView.reloadData()
    }
    func networkIsOffline() {
        self.networkStatusIcon.tintColor = UIColor.red
    }
    func netWorkIsOnline() {
        self.networkStatusIcon.tintColor = UIColor.green
    }
    
}

