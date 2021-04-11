//
//  MoviesCollectionPresenter.swift
//  MovieList
//
//  Created by moutaz hegazy on 4/11/21.
//  Copyright © 2021 Mohmaed_Elkholy. All rights reserved.
//

import Foundation
import Reachability

protocol MoviesCollectionView: class{
    
    func reloadTableView()
    
}

protocol MoviesCollectionViewPresenter{
    init(view: MoviesCollectionView)
    func fetchMoviesData()
}

class MoviesCollectionPresenter: MoviesCollectionViewPresenter{
    weak var view: MoviesCollectionView?
    var movies: [Movie]
    var movieEntities :[MovieEntity]
    let url = "http://api.androidhive.info/json/movies.json"
    let reachability = try! Reachability()
    
    required init(view: MoviesCollectionView) {
        self.view = view
        movies = []
        movieEntities = []
    }
    
    func fetchMoviesData() {
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                //Online Mode
                
                
                //fetch data from api
                
                NetworkLayer.sharedInstance.getDataFromJSON(url: self.url) {[weak self](data,respose,error) in
                    guard let weakSelf = self else {return}
                    do{
                        //parsing with codable
                        if let safeData = data{
                            let decoder = JSONDecoder()
                            do {
                                let decodedData = try decoder.decode(Array<Movie>.self, from: safeData)
                                weakSelf.movies = decodedData
                            }
                        }else{
                            print("error fetching data!")
                        }
                        
                        
                        DispatchQueue.main.async {
                            
                            //fetch data from CoreData
                            CoreDataLayer.sharedInstance.getDataFromStorage(){[weak self](movies,movieEntities,error) in
                                guard let weakSelf = self else {return}
                                if error == nil {
                                    weakSelf.movies += movies!
                                    weakSelf.movieEntities += movieEntities!
                                    weakSelf.view?.reloadTableView()
                                }else{
                                    print(error!)
                                }
                                
                            }
                            
                            
                        }
                    }catch {
                        print(error)
                    }
                    
                }
                
            } else {
                //Offline Mode
                
                //fetch data from CoreData
                CoreDataLayer.sharedInstance.getDataFromStorage(){[weak self](movies,movieEntities,error) in
                    guard let weakSelf = self else {return}
                    if error == nil {
                        weakSelf.movies += movies!
                        weakSelf.movieEntities += movieEntities!
                        
                    }else{
                        print(error!)
                    }
                    
                }
            }
            
            
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }

    }
}

