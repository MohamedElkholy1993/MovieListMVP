//
//  MoviesPresenter.swift
//  MovieList
//
//  Created by moutaz hegazy on 4/10/21.
//  Copyright © 2021 Mohmaed_Elkholy. All rights reserved.
//

import Foundation
import Reachability

protocol MovieListView: class{
    func startLoading()
    func finishLoading()
    func reloadTableView()
    func netWorkIsOnline()
    func networkIsOffline()
}


protocol MovieListViewPresenter{
    init(view: MovieListView)
    func fetchMoviesData()
}

class MovieListPresenter: MovieListViewPresenter{
    weak var view:MovieListView?
    var movies :[Movie]
    var movieEntities :[MovieEntity]
    let reachability = try! Reachability()
    var url = "http://api.androidhive.info/json/movies.json"
    
    required init(view: MovieListView) {
        self.view = view
        movies = []
        movieEntities = []
    }
    
    func fetchMoviesData() {
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                //Online Mode
                self.view?.netWorkIsOnline()
                
                //fetch data from api
                self.view?.startLoading()
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
                            
                            weakSelf.view?.finishLoading()
                        }
                    }catch {
                        print(error)
                    }
                    
                }
                
            } else {
                //Offline Mode
                self.view?.networkIsOffline()
                //fetch data from CoreData
                CoreDataLayer.sharedInstance.getDataFromStorage(){[weak self](movies,movieEntities,error) in
                    guard let weakSelf = self else {return}
                    if error == nil {
                        weakSelf.movies += movies!
                        weakSelf.movieEntities += movieEntities!
                        weakSelf.view?.finishLoading()
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
