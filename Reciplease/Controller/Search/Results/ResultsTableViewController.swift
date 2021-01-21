//
//  ResultsTableViewController.swift
//  Reciplease
//
//  Created by Benjamin Breton on 20/01/2021.
//

import UIKit

class ResultsTableViewController: UITableViewController {
    var choosenIngredients: [String] = []
    var recipes: [RecipeService.RecipeDetails] = []
    var selectedRecipe: RecipeService.RecipeDetails?
    var isSearching: Bool = false {
        didSet {
            indicator.isHidden = !isSearching
        }
    }
    var useFakeSession: Bool = false
    let indicator = UIActivityIndicatorView(style: .white)
    var service: RecipeService {
        return useFakeSession ? RecipeService(session: FakeResponse.correctResponseWithData("RecipeJson").fakeSession) : RecipeService()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        indicator.startAnimating()
        indicator.center = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        view.addSubview(indicator)
        
        if choosenIngredients.count > 0 || useFakeSession {
            isSearching = true
            tableView.reloadData()
            service.searchRecipe(for: choosenIngredients) { (result) in
                DispatchQueue.main.async {
                    self.isSearching = false
                    switch result {
                    case .success(let recipes):
                        self.recipes = recipes
                        self.tableView.reloadData()
                    case .failure(let error):
                        self.showAlert(error: error)
                        self.recipes = []
                    }
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return recipes.count > 0 ? 1 : 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return recipes.count
    }
    
//    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let label = UILabel()
//        label.text = isSearching ? "searching ... please wait" : choosenIngredients.count == 0 ? "you have no ingredient in the list" : recipes.count == 0 ? "no results" : ""
//        label.font = UIFont(name: "Chalkduster", size: 17)
//        label.textAlignment = .center
//        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//        return label
//    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath)
        guard let resultCell = cell as? ResultTableViewCell else { return cell }
        let result = recipes[indexPath.row]
        guard let data = result.1, let image = UIImage(data: data) else {
            guard let image = UIImage(named: "meal") else { fatalError() }
            resultCell.setCell(recipe: result.0, image: image)
            return resultCell
        }
        // Configure the cell...
        resultCell.setCell(recipe: result.0, image: image)
        return resultCell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRecipe = recipes[indexPath.row]
        performSegue(withIdentifier: "ResultsToRecipeSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? RecipeTableViewController, let recipe = selectedRecipe {
            controller.recipe = recipe
        }
    }

}
