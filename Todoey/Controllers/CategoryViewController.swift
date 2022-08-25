//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Anon's MacBook Pro on 8/7/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        tableView.separatorStyle = .none
      
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller doesn't exist.")}
        navBar.backgroundColor = UIColor(hexString: "1D9BF6")
    }
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row]{
            cell.textLabel?.text = category.name
            
            guard let categoryColour = UIColor(hexString: category.colour) else {(fatalError())}
            
            cell.backgroundColor = categoryColour
            cell.textLabel?.textColor = ContrastColorOf(categoryColour, returnFlat: true)
        }
        


        return cell
        
    }
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    //MARK: - TableView Manipulation Methods
    
    func save(category: Category) {
        
        do {
            try realm.write{
                realm.add(category)
            }
        } catch {
            print("Error saving category \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadCategories(){
        
        categories = realm.objects(Category.self)
        
        //        let request : NSFetchRequest<Category> = Category.fetchRequest()
        //        do{
        //          categories = try context.fetch(request)
        //        }catch{
        //            print("Error loading categories \(error)")
        //        }
        tableView.reloadData()
    }
    
    //MARK: - Delete data from Swipe
    override func updateModel(at indexPath: IndexPath) {
        if let categotyForDeletion = self.categories?[indexPath.row]{
            do{
                try self.realm.write{
                    self.realm.delete(categotyForDeletion)
                }
            }catch{
                print("Error deleting category, \(error)")
            }
        }
    }
    
    //MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New category ", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.colour = UIColor.randomFlat().hexValue()
            self.save(category: newCategory)
            
        }
        
        alert.addAction(action)
        
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Add a new category"
        }
        
        present(alert, animated: true, completion: nil)
    }
}
