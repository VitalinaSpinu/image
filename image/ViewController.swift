//
//  ViewController.swift
//  image
//
//  Created by Dmitrii Vrabie on 18.01.2023.
//

import UIKit
import CoreData


class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var cellIdentifier = "cell"
    var filteredName = [Image]()
    
    private var allImages : [Image] = [Image(name: "download"),
                                       Image(name: "gerafa"),
                                       Image(name: "luna")]
    
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
    private func filterNames(for searchText: String) {
        filteredName = allImages.filter { name in
            return name.name.starts(with: searchText.lowercased())
        }
        collectionView.reloadData()
    }
           
}
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! MyCollectionViewCell
        var images = allImages[indexPath.item]
        if searchController.isActive && searchController.searchBar.text != "" {
            images = filteredName[indexPath.item]
        } else {
            images = allImages[indexPath.item]
        }
        cell.myImage?.image = UIImage(named: images.name)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredName.count
        } else {
            return allImages.count
        }
        
    }
}
extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterNames(for: searchController.searchBar.text ?? "")
    }
}

