//
//  CategoryController.swift
//  ToDo-App
//
//  Created by Shashank Pandey on 25/12/23.
//

import UIKit
import CoreData

class CategoryController:UITableViewController{
    
    var category:[Category] = []
    let categoryViewModel = CategoryViewmodel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        categoryViewModel.loadItemsFromCoreData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return category.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategotyCell", for: indexPath)
        cell.textLabel?.text = category[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            categoryViewModel.deleteFromCoreDate(item: category[indexPath.row])
            category.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            print("Insert")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ViewToDoList", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewToDoList"{
            let destination = segue.destination as? ToDoListController
            if let indexPath = tableView.indexPathForSelectedRow{
                destination?.selectedCategory = category[indexPath.row]
            }
            
        }
    }
    
    @IBAction func addCategory(_ sender: Any) {
        showAlert()
    }
    
    private func showAlert(){
        var textField = UITextField()
        let alert = UIAlertController(title: "Add Task category", message: "Type and press add to add your task category", preferredStyle: .alert)
        alert.addTextField { textfield in
            textfield.placeholder = "enter the category name"
            textField = textfield
        }
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { alertAction in
            guard let item = textField.text else { return }
            guard !item.isEmpty else { return }
            guard let context = self.categoryViewModel.context else {return}
            
            let task = Category(context: context)
            task.name = item
            self.category.append(task)
            
            self.categoryViewModel.saveToCoreData()
            
        }))
        
        self.present(alert, animated: true)
    }
    
    private func loadData(){
        categoryViewModel.dataEvent = {
            event in
            switch event{
            case .success(let data):
                self.category = data
                self.tableView.reloadData()
                break
            case .error(let error):
                print(error)
                break
            case .dataSaved:
                self.tableView.reloadData()
            case .loading:
                break
            }
        }
    }
    
}
