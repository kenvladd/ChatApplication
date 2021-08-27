//
//  SeeAllViewController.swift
//  ChatApplication
//
//  Created by OPSolutions on 8/27/21.
//

import UIKit

class SeeAllViewController: ViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    let urlCategory = "https://www.themealdb.com/api/json/v1/1/categories.php"
    var category :[Categories] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        fetchDataCategory(from: urlCategory)
    }
    
    func fetchDataCategory(from url: String) {
        
        let task = URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    print("something went wrong")
                    return
                }
                
                var result: FoodCategories?
                do {
                    result = try JSONDecoder().decode(FoodCategories.self, from: data)
                }
                catch{
                    print("failed to convert \(error.localizedDescription)")
                }
                
                guard let json = result else {
                    return
                }
                self.category = json.categories
                
                self.collectionView.reloadData()
            }
            
        })
        
        task.resume()
        
    }
}

extension SeeAllViewController:  UICollectionViewDataSource {
func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 1
}

func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    return UICollectionViewCell()
}
}

extension SeeAllViewController: UICollectionViewDelegate {
    
}
