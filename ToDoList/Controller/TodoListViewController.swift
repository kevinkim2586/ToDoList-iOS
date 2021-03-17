import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!

    var itemArray = [Item]()
    
    var selectedCategory: Category? {
        
        didSet {
            loadItems()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
    
        searchBar.delegate = self

        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New To Do Item", message: "", preferredStyle: .alert)
        
        // The button you are going to press once you are done
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            // What will happen once the user clicks the Add Item button on our UIAlert
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.isDone = false
            
            // 별도로 parentCategory 도 설정해야함
            newItem.parentCategory = self.selectedCategory
            
            self.itemArray.append(newItem)
            self.saveItems()
            
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField                      // Storing the same reference to a local variable accessible
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
        
    }
    
    func saveItems() {
        
        do {
            try context.save()
    
        } catch {
            print("Error saving context \(error)")
        }

        self.tableView.reloadData()
    }
    
    
    // Providing a default value for request if we don't pass a separate parameter
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {

        // going to fetch results in the form of Items that we created in the Data Model (entity)
        // you have to specify the data type
        // fetchRequest() requests everything back from the Persistent Container
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
       
        if let additionalPredicate = predicate {        // 검색까지 하면~
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
           itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
}

extension TodoListViewController {
    
    //MARK: - UITableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.toDoItemCellIdentifier, for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        cell.accessoryType = item.isDone ? .checkmark : .none

        return cell
    }
    
    //MARK: - UITableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].isDone = !itemArray[indexPath.row].isDone
        saveItems()
    
        tableView.deselectRow(at: indexPath, animated: true)    // cell 을 누르자마자 deselect 되는 애니메이션이 나올 수 있도록
    }
}

//MARK: - UISearchBarDelegate

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        
        // What do we want to get back from the database? Use NSPredicate
        // NSPredicate is basically a foundation class that specifies how data should be fetched/filtered. (query language)
        // %@ substitutes any sort of argument that you want to pass in
        // [cd] making it "case" and "diacritic" insensitive
         
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        // Why array? because .sortDescriptor"s" -> plural -> expects an array
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
       
        loadItems(with: request, predicate: predicate)
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
