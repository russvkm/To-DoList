//
//  CategoryViewmodel.swift
//  ToDo-App
//
//  Created by Shashank Pandey on 25/12/23.
//

import UIKit
import CoreData

class CategoryViewmodel{
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    var dataEvent:((_ event:DataTransaction<[Category]>)->Void)?
    
    func saveToCoreData(){
        do{
            try context?.save()
        }catch{dataEvent?(.error(error))}
        dataEvent?(.dataSaved)
    }
    
    func loadItemsFromCoreData(){
        let request:NSFetchRequest<Category> = Category.fetchRequest()
        do{
            let itemArray = try context?.fetch(request) ?? [Category]()
            dataEvent?(.success(itemArray))
        }catch{
            dataEvent?(.error(error))
        }
        
    }
    
    func deleteFromCoreDate(item:Category){
        context?.delete(item)
        saveToCoreData()
    }
}
