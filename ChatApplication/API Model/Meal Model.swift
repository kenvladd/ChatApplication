//
//  Meal Model.swift
//  ChatApplication
//
//  Created by OPSolutions on 8/24/21.
//

import Foundation

struct Food: Codable {
    let  meals: [Meals]
}

struct Meals: Codable {
    let  strMeal: String
    let  strMealThumb: String
    let  idMeal: String
}

struct FoodCategories: Codable {
    let  categories: [Categories]
}

struct Categories: Codable {
    let  idCategory: String
    let  strCategory: String
    let  strCategoryThumb: String
}

