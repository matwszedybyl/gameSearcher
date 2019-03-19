//
//  ViewController.swift
//  GameSearcher
//
//  Created by Mat Wszedybyl on 3/18/19.
//  Copyright © 2019 Mat Wszedybyl. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var gamesTableView: UITableView!
    fileprivate var giantBombAPI: GameSearchAPI?
    fileprivate var gamesViewModel =  GamesViewModel()
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        callSearchAPI()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func callSearchAPI() {
        self.gamesViewModel.gamesList.removeAll()
        self.gamesViewModel.offset = 0
        fetchPage(page: 1)
    }
    
    func fetchPage(page: Int) {
        giantBombAPI = GameSearchAPI.init(searchHandler: { (response, result) in
            if response == RequestResult.Success {
                if let error = result?.error {
                    DispatchQueue.main.async {
                        print(error)
                        //check if we are adding more games to the list or new search
                        if self.gamesViewModel.gamesList.count > 0 {
                            for game in (result?.results)! {
                                self.gamesViewModel.gamesList.append(game)
                            }
                            self.gamesViewModel.offset = (result?.offset)!
                        } else {
                            self.gamesViewModel.gamesList = (result?.results)!
                            self.gamesViewModel.totalResults = (result?.number_of_total_results)!
                        }
                        // check if any games exist
                        if result!.number_of_page_results == 0 {
                            let alert = UIAlertController(title: "Error", message: "No games found", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        } else {
                            self.gamesTableView.reloadData()
                        }
                        self.gamesViewModel.isFetching = false
                    }
                }
            } else if response == RequestResult.Failure {
                print("Error")
            }
        })
        let query = searchTextField.text?.replacingOccurrences(of: " ", with: "+")
        giantBombAPI?.callGameSearchAPI(gameName: query!, page: page)
    }
    
}

extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gamesViewModel.gamesList.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlainCell", for: indexPath) as! GameCellView
        //Title
        cell.gameTitleView.text = gamesViewModel.gamesList[indexPath.row].name
        
        //Release Date
        let usableDate = gamesViewModel.gamesList[indexPath.row].original_release_date
        var releaseDate = "N/A"
        if usableDate != nil {
            releaseDate = String(usableDate![..<String.Index(encodedOffset: 10)])
        }
        cell.releaseDateView.text = "Release Date: \(releaseDate)"

        //Thumbnail image async
        let imageUrl = gamesViewModel.gamesList[indexPath.row].image["tiny_url"]
        Alamofire.request(imageUrl!, method: .get).responseData { response in
            DispatchQueue.main.async {
                guard let image = UIImage(data:response.data!) else {
                    return
                }
                cell.thumbnailView?.image = image
            }
        }
        return cell
    }
}

extension ViewController : UITableViewDelegate {
    //pagination
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.extractCurrentY() > scrollView.contentSize.height - 100.0 {
            if gamesViewModel.gamesList.count < gamesViewModel.totalResults && !gamesViewModel.isFetching {
                gamesViewModel.isFetching = true
                fetchPage(page: (gamesViewModel.getPage()) )
            }
        }
    }
}
