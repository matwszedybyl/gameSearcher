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
    fileprivate var searchResult : GameSearchResultsModel?
    fileprivate var giantBombAPI: GameSearchAPI?
    fileprivate var isfetching: Bool?
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        callSearchAPI()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func callSearchAPI() {
        self.searchResult?.results.removeAll()
        self.searchResult?.offset = 0
        fetchPage(page: 1)
    }
    
    
    func fetchPage(page: Int) {
        giantBombAPI = GameSearchAPI.init(searchHandler: { (response, result) in
            if response == RequestResult.Success {
                if let error = result?.error {
                    DispatchQueue.main.async {
                        print(error)
                        //check if we are adding more games to the list or new search
                        if self.searchResult?.results != nil, (self.searchResult?.results.count)! > 0 {
                            for game in (result?.results)! {
                                self.searchResult?.results.append(game)
                            }
                            self.searchResult?.offset = (result?.offset)!
                        } else {
                            self.searchResult = result!
                        }
                        // check if any games exist
                        if result!.number_of_page_results == 0 {
                            let alert = UIAlertController(title: "Error", message: "No games found", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        } else {
                            self.gamesTableView.reloadData()
                        }
                        self.isfetching = false
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
        return searchResult?.results.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlainCell", for: indexPath) as! GameCellView
        //Title
        cell.gameTitleView.text = searchResult?.results[indexPath.row].name
        
        //Release Date
        let usableDate = searchResult?.results[indexPath.row].original_release_date
        var releaseDate = "N/A"
        if usableDate != nil {
            releaseDate = String(usableDate![..<String.Index(encodedOffset: 10)])
        }
        cell.releaseDateView.text = "Release Date: \(releaseDate)"

        //Thumbnail image async
        let imageUrl = searchResult?.results[indexPath.row].image["tiny_url"]
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
            if (searchResult?.results.count)! < (searchResult?.number_of_total_results)! && !isfetching! {
                isfetching = true
                let nextPage = ((searchResult?.offset)! + 20) / 10 //should be refactored
                fetchPage(page: nextPage )
            }
        }
        
    }
    
}
