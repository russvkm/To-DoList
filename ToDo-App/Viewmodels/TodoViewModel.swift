//
//  TodoViewModel.swift
//  ToDo-App
//
//  Created by Shashank Pandey on 25/12/23.
//

import UIKit
import CoreData

class TodoViewModel{
    var dataEvent:((_ event:DataTransaction<[TaskModel]>)->Void)?
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    func saveToCoreData(){
        do{
            try context?.save()
        }catch{dataEvent?(.error(error))}
        //self.tableView.reloadData()
        dataEvent?(.dataSaved)
    }
    
    func loadItemsFromCoreData(for selectedCategory:Category, 
                               with request:NSFetchRequest<TaskModel> = TaskModel.fetchRequest()
                               , predicate:NSPredicate? = nil){
        let categoryPredicate = NSPredicate(format: "parentRelation.name MATCHES %@", selectedCategory.name ?? "")
        if let hasPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, hasPredicate])
        }else{
            request.predicate = categoryPredicate
        }
        do{
            let itemArray = try context?.fetch(request) ?? [TaskModel]()
            dataEvent?(.success(itemArray))
        }catch{
            dataEvent?(.error(error))
        }
        
    }
    
    func searchData(data:String, for selectedCategory:Category){
        let request:NSFetchRequest<TaskModel> = TaskModel.fetchRequest()
        let predicate = NSPredicate(format: "value contains[cd] %@", data)
        let sortDescriptor = NSSortDescriptor(key: "value", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        loadItemsFromCoreData(for:selectedCategory, with: request, predicate: predicate)
    }
    
    func deleteFromCoreDate(item:TaskModel){
        context?.delete(item)
        saveToCoreData()
    }
}

enum DataTransaction<T>{
    case loading
    case success(_ data:T)
    case dataSaved
    case error(_ error:Error)
}
