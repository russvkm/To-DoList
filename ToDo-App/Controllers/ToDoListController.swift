//
//  ViewController.swift
//  ToDo-App
//
//  Created by Shashank Pandey on 25/12/23.
//

import UIKit
import CoreData

class ToDoListController: UITableViewController {
    var itemArray:[TaskModel] = []
    var toDoViewModel = TodoViewModel()
    var selectedCategory:Category?{
        didSet{
            loadData()
            toDoViewModel.loadItemsFromCoreData(for: selectedCategory!)
        }
    }
    //let defaults = UserDefaults.standard
    
    // core data context
    
    
    // ns coder concept
    let dataPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
        .appendingPathComponent("Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        if let itemArray = defaults.array(forKey: "TASK-DATA") as? [TaskModel]{
//            self.itemArray = itemArray
//        }
       // loadItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = selectedCategory?.name
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].value
        cell.accessoryType = itemArray[indexPath.row].isSelected ? .checkmark:.none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].isSelected.toggle()
        //saveData()
        toDoViewModel.saveToCoreData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - swipe to delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            toDoViewModel.deleteFromCoreDate(item: itemArray[indexPath.row])
            itemArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            print("Insert")
        }
    }

    @IBAction func addNewItem(_ sender: Any) {
        showAlert()
    }
    
    private func showAlert(){
        var textField = UITextField()
        let alert = UIAlertController(title: "Add Task", message: "Type and press add to add your task", preferredStyle: .alert)
        alert.addTextField { textfield in
            textfield.placeholder = "enter the task name"
            textField = textfield
        }
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { alertAction in
            guard let item = textField.text else { return }
            guard !item.isEmpty else { return }
            guard let context = self.toDoViewModel.context else {return}
            guard let selectedCategory = self.selectedCategory else { return }
            let task = TaskModel(context: context)
            task.value = item
            task.isSelected = false
            task.parentRelation = selectedCategory
            self.itemArray.append(task)
            
            //MARK: - add data to user default
            //self.defaults.set(self.itemArray, forKey: "TASK-DATA")
            // MARK: - use encoder
            //self.saveData()
            // MARK: - use core data to save the value
            
            self.toDoViewModel.saveToCoreData()
            
        }))
        
        self.present(alert, animated: true)
    }
    
    //MARK: - Encoder add data to cutom info.plist -> Encoding data to nscoder
//    private func saveData(){
//        let encoder = PropertyListEncoder()
//        do{
//            let data = try encoder.encode(self.itemArray)
//            guard let dataPath = self.dataPath else { return }
//            try data.write(to: dataPath)
//        }catch{print("Error")}
//        
//        self.tableView.reloadData()
//    }
    
    //MARK: - decode data from nscoder
    
//    private func loadItem(){
//        guard let dataPath else { return }
//        if let data = try? Data(contentsOf: dataPath){
//            let decoder = PropertyListDecoder()
//            do{
//                itemArray = try decoder.decode([TaskModel].self, from: data)
//            }catch{print("Error while decoding from file path")}
//            
//        }
//    }
    
    private func loadData(){
        toDoViewModel.dataEvent = {
            event in
            switch event{
            case .success(let data):
                self.itemArray = data
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

extension ToDoListController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let data = searchBar.text else { return }
        guard let selectedCategory else { return }
        toDoViewModel.searchData(data: data, for: selectedCategory)
        
        view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            guard let selectedCategory else { return }
            toDoViewModel.loadItemsFromCoreData(for: selectedCategory)
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        
    }
}

