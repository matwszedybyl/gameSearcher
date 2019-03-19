//
//  gamesViewModel.swift
//  GameSearcher
//
//  Created by Mat Wszedybyl on 3/18/19.
//  Copyright © 2019 Mat Wszedybyl. All rights reserved.
//

import Foundation


class GamesViewModel {
    
    var currentPage: Int = 0
    var gamesList: [GameModel] = []
    var offset: Int = 0
    var isFetching: Bool = false
    var totalResults: Int = 0

    
    func getPage() -> Int{
        return (offset + 20 ) / 10
    }
    
    
}
