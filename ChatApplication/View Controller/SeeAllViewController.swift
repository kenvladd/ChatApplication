//
//  SeeAllViewController.swift
//  ChatApplication
//
//  Created by OPSolutions on 8/31/21.
//

import UIKit
import Kingfisher

class SeeAllViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var category :[Categories] = []
    let urlCategory = "https://www.themealdb.com/api/json/v1/1/categories.php"
    var completionHandler: ((String?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        
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

extension SeeAllViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return category.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SeeAllCollectionViewCell
        let categories = category[indexPath.row]
        let url = URL(string: categories.strCategoryThumb)
        cell.imageView.kf.setImage(with: url)
        cell.titleLabel.text = categories.strCategory
        cell.contentView.layer.cornerRadius = 8.0
        return cell
    }
}

extension SeeAllViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let categories = category[indexPath.row]
        let categoryURL = categories.strCategory
        completionHandler?(categoryURL)
        dismiss(animated: true, completion: nil)
    }
}

extension SeeAllViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 183, height: 215)
    }
}
