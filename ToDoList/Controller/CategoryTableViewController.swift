import UIKit
import ChameleonFramework
import RealmSwift

class CategoryTableViewController: SwipeTableViewController {
    
    let realm = try! Realm()

    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation Controller does not exist")
        }
        navBar.backgroundColor = .white

        
        let navBarColor = UINavigationBarAppearance()
        navBarColor.backgroundColor = .white
        navBar.scrollEdgeAppearance = navBarColor
    }
    
    // Add a New Category

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
        
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.cellColorHexValue = UIColor.randomFlat().hexValue()

            self.save(category: newCategory)
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Category Name"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // Delete Data From Swipe Gesture
    override func updateModel(at indexPath: IndexPath) {
        
        if let categoryToDelete = self.categories?[indexPath.row] {
            
            do {
                
                try self.realm.write {
                    self.realm.delete(categoryToDelete)
                }
                
            } catch {
                print("Error deleting category: \(error)")
            }
        }
        
    }
}


//MARK: - Data Manipulation Methods

extension CategoryTableViewController {
    
    func save(category: Category) {
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving new category : \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadCategories() {
        
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource

extension CategoryTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
    
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Added"
        
        let cellColor = categories?[indexPath.row].cellColorHexValue ?? "BDD4CC"
        cell.backgroundColor = UIColor(hexString: cellColor)
        cell.textLabel?.textColor = ContrastColorOf(UIColor(hexString: cellColor)!, returnFlat: true)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.goToItemSegue, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            
            destinationVC.selectedCategory = categories?[indexPath.row]
            
            let colorScheme = categories?[indexPath.row].cellColorHexValue ?? "BDD4CC"
            destinationVC.colorScheme = UIColor(hexString: colorScheme) ?? UIColor.white
            
            destinationVC.navigationItem.title = categories?[indexPath.row].name
        }
    }

}




