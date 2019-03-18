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

    var searchAPI: GameSearchAPI?
    
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var gamesTableView: UITableView!
    
    fileprivate var searchResult : GameSearchResultsModel?
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        callSearchAPI()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    func callSearchAPI() {
        searchAPI = GameSearchAPI.init(searchHandler: { (response, result) in
            if response == RequestResult.Success {
                if let error = result?.error {
                    DispatchQueue.main.async {
                        print(error)
                        self.searchResult = result!
                        if result!.number_of_page_results == 0 {
                            let alert = UIAlertController(title: "Error", message: "No games found", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        } else {
                            self.gamesTableView.reloadData()
                        }
                    }
                }
            } else if response == RequestResult.Failure {
                print("Error")
            }
        })
        searchAPI?.callGameSearchAPI(gameName: searchTextField.text!)
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
        cell.gameTitleView.text = searchResult?.results[indexPath.row].name
        
        let imageUrl = searchResult?.results[indexPath.row].image["tiny_url"]
        Alamofire.request(imageUrl!, method: .get).responseData { response in
            DispatchQueue.main.async {
                guard let image = UIImage(data:response.data!) else {
                    // Handle error
                    return
                }
                cell.thumbnailView?.image = image
            }
        }
        return cell
    }
    
}

extension ViewController : UITableViewDelegate {
}
