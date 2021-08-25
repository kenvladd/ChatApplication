//
//  HomeViewController.swift
//  ChatApplication
//
//  Created by OPSolutions on 8/23/21.
//

import UIKit
import Kingfisher

class HomeViewController: UIViewController {
    let url = "https://www.themealdb.com/api/json/v1/1/filter.php?c=Seafood"
    let urlCategory = "https://www.themealdb.com/api/json/v1/1/categories.php"

    var meal: [Meals] = []
    var category :[Categories] = []

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self

        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = "Explore"
        
        fetchData(from: url)
        fetchDataCategory(from: urlCategory)
    }
    
    func fetchData(from url: String) {
        
        let task = URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    print("something went wrong")
                    return
                }
                
                var result: Food?
                do {
                    result = try JSONDecoder().decode(Food.self, from: data)
                }
                catch{
                    print("failed to convert \(error.localizedDescription)")
                }
                
                guard let json = result else {
                    return
                }
                self.meal = json.meals
                
//                print(self.meal.count)
                self.collectionView.reloadData()
            }
            
        })
        
        task.resume()
        
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
                
                self.categoryCollectionView.reloadData()
            }
            
        })
        
        task.resume()
        
    }
}


extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if collectionView == self.categoryCollectionView {
            return category.count
        }
        return meal.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if collectionView == self.categoryCollectionView {
          let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategoryCollectionViewCell
            let categories = category[indexPath.row]
            cell.categoryButton.largeContentTitle = categories.strCategory

            return cell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoCollectionViewCell
        let  meals = meal[indexPath.row]
        let url = URL(string: meals.strMealThumb)
        cell.imageView.kf.setImage(with: url)
        cell.foodlabel.text = meals.strMeal

        return cell
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
    }
}

let screenSize = UIScreen.main.bounds
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: screenSize.size.width/2, height: 200)
    }
}
