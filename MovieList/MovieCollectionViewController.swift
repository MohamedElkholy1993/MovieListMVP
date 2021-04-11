//
//  MovieCollectionViewController.swift
//  MovieList
//
//  Created by moutaz hegazy on 3/15/21.
//  Copyright © 2021 Mohmaed_Elkholy. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class MovieCollectionViewController: UICollectionViewController{
   
   
    var presenter: MoviesCollectionPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = false
        presenter = MoviesCollectionPresenter(view: self)
        self.title = "Movies List"
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 4, bottom: 0, right: 4)
        presenter.fetchMoviesData()
 
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return presenter.movies.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MovieCollectionViewCell
    
        // Configure the cell
        
        cell.layer.cornerRadius = 20.0
        cell.layer.borderWidth  = 1.0
        cell.layer.borderColor  = UIColor.white.cgColor
        
        if let url = URL(string:  presenter.movies[indexPath.row].image){
            cell.activityIndicator.startAnimating()
            
            cell.movieImageView?.sd_setImage(with: url, completed: { (image, error, cacheType, url) in
                DispatchQueue.main.async {
                    cell.activityIndicator.stopAnimating()
                    let size = CGSize(width: (self.view.frame.width/2)-10, height: (self.view.frame.width/2)-10)
                    cell.movieImageView.frame.size = size
                    if error != nil {
                        cell.movieImageView?.image = UIImage(named: "Image")
                    }
                }
            })
        }
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "movieDetails") as! MovieDetailsViewController
        vc.presenter = MoviePresenter(view: vc)
        vc.presenter.movieToView =  presenter.movies[indexPath.row]
        tabBarController?.tabBar.isHidden = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    

}

extension MovieCollectionViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: (view.frame.width/2)-10, height: (view.frame.width/2)-10)
        return size
    }
}

extension MovieCollectionViewController: MoviesCollectionView{
    
       func reloadTableView() {
           collectionView.reloadData()
       }
}



