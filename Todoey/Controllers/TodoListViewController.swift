//
//  ViewController.swift
//  Todoey
//
//  Created by andres murguido on 7/26/18.
//  Copyright © 2018 andres murguido. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework


class TodoListViewController: SwipeTableViewController {
    let realm = try! Realm()
    var todos: Results<Todo>?
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
    }
    //Navigation controller not existing on ViewDidLoad, must use other app lifecycle method viewWillAppear
    //to wait for navigation bar
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory?.name
        
        guard let hexColor = selectedCategory?.backgroundColor else {fatalError("Could not get Selected Categories background")}
        updateNavbar(withHexCode: hexColor)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavbar(withHexCode: "1D9BF6")
//        navigationController?.navigationBar.barTintColor = originalColor
//        navigationController?.navigationBar.tintColor = FlatGray()
//        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:ContrastColorOf(FlatGray(), returnFlat: true)]
    }
    //MARK - set up navbar
    func updateNavbar(withHexCode colorHex: String){
        guard let navBar = navigationController?.navigationBar else { fatalError("Couldnt find navbar controller")}
        
        guard let navbarColor = UIColor(hexString: colorHex) else {fatalError("NavBar Color Not Set")}
        
        navBar.barTintColor = navbarColor
        
        searchBar.barTintColor = navbarColor
        
        navBar.tintColor = ContrastColorOf(navbarColor, returnFlat: true)
        
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor:ContrastColorOf(navbarColor, returnFlat: true)]
    }
    
    //MARK - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return todos?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todos?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            cell.accessoryType = (item.done) ? .checkmark : .none
            if let color = UIColor(hexString: (selectedCategory!.backgroundColor))?.darken(byPercentage:
                CGFloat(indexPath.row) / CGFloat((todos?.count)!)
                ){
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
        }
      
        
        return cell
    }
    //MARK - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let todo = todos?[indexPath.row] {
            do {
                try realm.write {
                    todo.done = !todo.done
                }
            } catch {
                print("Error updating todo item: \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //MARK - Add New Items
    @IBAction func AddTodo(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //Added Item
            if let currentCategory = self.selectedCategory {
                do{
                    try self.realm.write {
                        let newTodo = Todo()
                        newTodo.title = textField.text!
                        newTodo.createdAt = Date()
                        currentCategory.todos.append(newTodo)
                        self.realm.add(newTodo)
                    }
                } catch {
                    print("Could not add new todo: \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add Todo Item"
            textField = alertTextField
            print(alertTextField.text!)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil);
    }
  
    //MARK - Load Todos
    func loadItems() {
        todos = selectedCategory?.todos.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    //MARK - Delete Todos
    override func updateModel(at indexPath: IndexPath) {
        if let todoItem = todos?[indexPath.row]{
            do {
                try realm.write {
                    realm.delete(todoItem)
                }
            } catch {
                print("Could Not Delete Todo: \(error)")
            }
        }
    }

}
//MARK - Search bar methods
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       todos = todos?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "createdAt", ascending: true)
        tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
    }

}








