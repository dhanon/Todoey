import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    var todoItems : Results<Item>?
    let realm = try! Realm()
    
    
    @IBOutlet weak var searchbar: UISearchBar!
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let colourHex = selectedCategory?.colour{
            
            title = selectedCategory?.name 
            
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller doesn't exist.")}
            
            if let navBarColour = UIColor(hexString: colourHex){
                
                navBar.backgroundColor = navBarColour
                
                navBar.barTintColor = ContrastColorOf(navBarColour, returnFlat: true)
                
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor :ContrastColorOf(navBarColour, returnFlat: true)]
                
                searchbar.backgroundColor = navBarColour
                
            }
            

        }
    }
    
    
    //MARK - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
       
        if let item = todoItems?[indexPath.row]{
            cell.textLabel?.text = item.title
            
            if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)){
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
            
            
            
            
            
            //          Ternary Operator
            //          value = condition ? valueIfTrue : valueIfFalse
            
            cell.accessoryType = item.done ? .checkmark : .none
//            if item.done == true{
//                cell.accessoryType = .checkmark
//            }else{
//                cell.accessoryType = .none
//            }
        }else{
            cell.textLabel?.text = "No Items Added"
        }
        return cell
    }
    
    //MARK - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row]{
            do{
                try realm.write{
              //    realm.delete(item)
                    item.done = !item.done
                }
            }catch{
                print("Error saving done status, \(error)")
            }
        }
        tableView.reloadData()
        
        //**Delete the data your Persistent Contanier using Code Data**
        
        //context.delete(itemArray[indexPath.row])
        //itemArray.remove(at: indexPath.row)
        //todoItems[indexPath.row].done = !itemArray[indexPath.row].done
        //saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
     
    }
    
    
    
    //MARK - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //What will happen once the user clicks the Add Item buttom on our UIAlert
            if let currentCategory = self.selectedCategory{
                do{
                    try self.realm.write{
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                }catch{
                    print("Error saving new items, \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
        alert.addTextField { (aleartTextField) in
            aleartTextField.placeholder = "Create new item"
            textField = aleartTextField
            
            
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    //MARK - Model Manupulation Methods
    
    
    //Read the from your Persistent Contanier using Code Data
    
    func loadItems(){
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        //        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        //
        //        if let addtionalPredicate = predicate{
        //            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,addtionalPredicate])
        //        }else{
        //            request.predicate = categoryPredicate
        //        }
        //let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,predicate])
        //
        //      request.predicate = compoundPredicate
        //
        //        do{
        //            itemArray = try context.fetch(request)
        //        } catch{
        //            print("Error fetching data from context \(error)")
        //        }
        tableView.reloadData()
        
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = todoItems? [indexPath.row]{
            do{
                try realm.write{
                    realm.delete(item)
                }
            }catch{
                print("Error Deleting Items, \(error)")
            }

        }
    }
}


//MARK - Search ber methods

extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
        
    }
//        let request: NSFetchRequest<Item> = Item.fetchRequest()
//
//        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//
//        loadItems(with: request, predicate: predicate)
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
