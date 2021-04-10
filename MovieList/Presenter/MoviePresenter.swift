//
//  MoviePresenter.swift
//  MovieList
//
//  Created by moutaz hegazy on 4/10/21.
//  Copyright © 2021 Mohmaed_Elkholy. All rights reserved.
//

import Foundation

protocol MovieView: class{
    func viewMovieDetails()
}

protocol MovieViewPresenter{
    init(view: MovieView)
    func viewMovie()
}

class MoviePresenter: MovieViewPresenter{
    var view: MovieView?
    var movieToView: Movie
    
    required init(view: MovieView) {
        self.view = view
        movieToView = Movie()
    }
    
    func viewMovie() {
        view?.viewMovieDetails()
    }
}
