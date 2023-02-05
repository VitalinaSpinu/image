//
//  ViewController.swift
//  image
//
//  Created by Vitalina Spinu on 18.01.2023.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON


class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var cellIdentifier = "cell"
    
    private var allImages : [PhotoInfo] = []
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search image..."
        definesPresentationContext = true
        navigationItem.searchController = searchController
        searchController.searchBar.tintColor = UIColor.red
        
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    func fetchImages(text: String) {
        let url = "https://api.flickr.com/services/rest/"
        let apiKey = "30237fed0e734b6df7992c0d3f362672"
        let parameters: Parameters = ["method":"flickr.photos.search",
                                      "api_key": "\(apiKey)",
                                      "format": "json",
                                      "nojsoncallback": "1",
                                      "extras": "url_o",
                                      "text": "\(text)"]
        
        AF.request(url, method: .get, parameters: parameters)
            .responseJSON{ responds in
                switch responds.result {
                case .success(let value):
                    self.parsePhotos(json: JSON(value))
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    func parsePhotos(json: JSON) {
        allImages = []
        allImages.reserveCapacity(100)
        for (index, dict) in json["photos"]["photo"] {
            if dict["url_o"].exists() {
                let photosList = PhotoInfo(url: dict["url_o"].stringValue)
                allImages.append(photosList)
            }
        }
        collectionView.reloadData()
    }
    
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! MyCollectionViewCell
        let url = URL(string: allImages[indexPath.item].url)!
        URLSession.shared.dataTask(with: url) { data, response, error in
                    guard
                        let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                        let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                        let data = data, error == nil,
                        let image = UIImage(data: data)
                        else { return }
                    DispatchQueue.main.async() { [weak self] in
                        cell.myImage?.image = image
                    }
                }.resume()

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allImages.count
    }
    
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        fetchImages(text: searchController.searchBar.text ?? "")
    }
}
