//
//  ResultModel.swift
//  GameSearcher
//
//  Created by Mat Wszedybyl on 3/18/19.
//  Copyright © 2019 Mat Wszedybyl. All rights reserved.
//

import Foundation

struct GameSearchResultsModel: Codable {
    var error: String
    var limit: Int
    var offset: Int
    var number_of_page_results: Int
    var number_of_total_results: Int
    var status_code: Int
    var results: [GameModel]
//    
    
}
