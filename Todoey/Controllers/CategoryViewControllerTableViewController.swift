//
//  CategoryViewControllerTableViewController.swift
//  Todoey
//
//  Created by andres murguido on 7/26/18.
//  Copyright © 2018 andres murguido. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewControllerTableViewController: SwipeTableViewController {

    
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation bar doesnt exist")
        }
        guard let navbarBG = navBar.barTintColor else {
            print("Could Not get categories navbar bg color")
            return
        }
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: ContrastColorOf(navbarBG, returnFlat: true)]
    }
    
    
    //MARK - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //MARK - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let category = categories?[indexPath.row]{
            cell.textLabel?.text = category.name
            if let cellBgColor = UIColor(hexString: category.backgroundColor) {
                cell.backgroundColor = cellBgColor
                cell.textLabel?.textColor = ContrastColorOf(cellBgColor, returnFlat: true)
            }
        }
        return cell
    }
    //MARK - Data Manipulation Methods
    func saveCategory(category: Category){
        do {
            try realm.write {
                realm.add(category)
            }
        } catch  {
            print("Error Saving Category: \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories(){
         categories = realm.objects(Category.self)

        tableView.reloadData()
    }
    
    //MARK - Delete Category from model
    override func updateModel(at indexPath: IndexPath) {
        if let deletedCategory = categories?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(deletedCategory)
                }
            } catch {
                print("Error Deleting Category: \(error)")
            }
        }
    }
    
    
    @IBAction func addCategory(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.backgroundColor = UIColor.randomFlat.hexValue()
            self.saveCategory(category: newCategory)
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add a new category here..."
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
   
    
}







