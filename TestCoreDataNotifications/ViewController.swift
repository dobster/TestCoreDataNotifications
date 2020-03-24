//
//  ViewController.swift
//  TestCoreDataNotifications
//
//  Created by Stu Dobbie on 24/3/20.
//  Copyright © 2020 Stu Dobbie. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    @IBAction func didTapAdd(_ sender: Any) {
        let bgContext = persistentContainer.newBackgroundContext()
        bgContext.perform {
            let coffee = Coffee(context: bgContext)
            coffee.milk = true
            coffee.origin = ["Colombia", "Peru", "Kenya", "PNG"].randomElement()!
            coffee.size = 2
            try! bgContext.save()
            print("Created \(coffee.origin!)!")
        }
    }
    
    @IBAction func didTapAddTea(_ sender: Any) {
        let bgContext = persistentContainer.newBackgroundContext()
        bgContext.perform {
            let tea = Tea(context: bgContext)
            tea.sugar = true
            tea.blend = ["Darjeeling", "Earl Grey", "Rooibos"].randomElement()!
            try! bgContext.save()
            print("Created \(tea.blend!)!")
        }
    }
    
    @IBAction func didTapChangeTea(_ sender: Any) {
        let bgContext = persistentContainer.newBackgroundContext()
        bgContext.perform {
            let fetchRequest: NSFetchRequest<Tea> = NSFetchRequest(entityName: "Tea")
            fetchRequest.predicate = NSPredicate(format: "blend = %@", "Rooibos")
            let teas = try! bgContext.fetch(fetchRequest)
            print("found \(teas.count)")
            for tea in teas {
                tea.sugar.toggle()
                print("Updated \(tea.blend!)!")
            }
            try! bgContext.save()
        }
    }
    
    var fetchedResultsController: NSFetchedResultsController<Coffee>!
    var observer: NSObjectProtocol?
    
    var persistentContainer: NSPersistentContainer {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: persistentContainer.viewContext, queue: nil) { (notification) in
            print("Received notification: \(notification)")
            DispatchQueue.main.async {
                try! self.fetchedResultsController.performFetch()
                self.tableView.reloadData()
            }
        }
        
        let fetchRequest: NSFetchRequest<Coffee> = NSFetchRequest(entityName: "Coffee")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "origin", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        try? fetchedResultsController.performFetch()
    }

}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Coffee Cell", for: indexPath)
        let coffee = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = "\(coffee.milk) \(coffee.origin ?? "") \(coffee.size)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
}

