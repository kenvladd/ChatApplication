//
//  DetailsViewController.swift
//  ChatApplication
//
//  Created by OPSolutions on 8/27/21.
//

import UIKit

class DetailsViewController: ViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var url: String!
    var names: String!
    var id: String!
    var detail: [DetailMeals] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.imageView.kf.setImage(with: URL(string: url))
        self.name.text = names

        
        let baseURL = "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(id!)"
        print(baseURL)
        fetchData(from: baseURL)
        
        }
    
    func fetchData(from url: String) {
        
        let task = URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    print("something went wrong")
                    return
                }
                
                var result: Details?
                do {
                    result = try JSONDecoder().decode(Details.self, from: data)
                }
                catch{
                    print("failed to convert \(error.localizedDescription)")
                }
                
                guard let json = result else {
                    return
                }
                
                self.detail = json.meals
//                print(self.details.count)
                self.tableView.reloadData()
            }
            
        })
        
        task.resume()
        
    }
    
    struct Details: Codable {
        let  meals: [DetailMeals]
    }
    
    struct DetailMeals: Codable {
        let  strInstructions: String
        let  strIngredient1: String
        let  strIngredient2: String
        let  strIngredient3: String
        let  strIngredient4: String
        let  strIngredient5: String
        let  strIngredient6: String
        let  strIngredient7: String
        let  strIngredient8: String
        let  strIngredient9: String
        let  strIngredient10: String
        let  strIngredient11: String
        let  strIngredient12: String
        let  strIngredient13: String
        let  strIngredient14: String
        let  strIngredient15: String
        let  strIngredient16: String
        let  strIngredient17: String
        let  strIngredient18: String
        let  strIngredient19: String
        let  strIngredient20: String
        
        let  strMeasure1: String
        let  strMeasure2: String
        let  strMeasure3: String
        let  strMeasure4: String
        let  strMeasure5: String
        let  strMeasure6: String
        let  strMeasure7: String
        let  strMeasure8: String
        let  strMeasure9: String
        let  strMeasure10: String
        let  strMeasure11: String
        let  strMeasure12: String
        let  strMeasure13: String
        let  strMeasure14: String
        let  strMeasure15: String
        let  strMeasure16: String
        let  strMeasure17: String
        let  strMeasure18: String
        let  strMeasure19: String
        let  strMeasure20: String



    }
}

extension DetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detail.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                
        let details = detail[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = details.strInstructions

        return cell
    }
    
    
}

extension DetailsViewController: UITableViewDelegate {
    
}
