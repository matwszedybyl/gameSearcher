//
//  GameSearchAPI.swift
//  GameSearcher
//
//  Created by Mat Wszedybyl on 3/18/19.
//  Copyright © 2019 Mat Wszedybyl. All rights reserved.
//

import Foundation
import Alamofire


class GameSearchAPI {

    var searchCompletion : ((RequestResult, GameSearchResultsModel?) -> Void )

    init(searchHandler: @escaping (RequestResult, GameSearchResultsModel?) -> Void ){
        searchCompletion = searchHandler
    }
    

    func callGameSearchAPI(gameName : String) {
        let gameSearchURL = URL(string: "http://www.giantbomb.com/api/search/?api_key=" + API_KEY + "&format=json&query=\(gameName)&resources=game")

        let task = URLSession.shared.dataTask(with: gameSearchURL!){ (data, respond, error) in
            guard let dataResponse = data,
                error == nil else {
                    self.searchCompletion(RequestResult.Failure, nil)
                    return }
            do{
                let searchResultsJSON = try JSONDecoder().decode(GameSearchResultsModel.self, from: dataResponse)
                self.searchCompletion(RequestResult.Success, searchResultsJSON)
                return
            } catch let parsingError {
                print("Error", parsingError)
            }
        }
        task.resume()
    }
    
    
}

