//
//  ReminderFetchedResultsController.swift
//  ProximityReminderApp
//
//  Created by Raymond Choy on 1/6/20.
//  Copyright © 2020 thechoygroup. All rights reserved.
//

import UIKit
import CoreData


class ReminderFetchedResultsController: NSFetchedResultsController<Reminder>, NSFetchedResultsControllerDelegate {
    private let tableView: UITableView?
    
    init(managedObjectContext: NSManagedObjectContext, predicate: NSPredicate?, tableView: UITableView?) {
        self.tableView = tableView
        super.init(fetchRequest: Reminder.fetchRequest(predicate: predicate), managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        self.delegate = self
        tryFetch()
    }
    
    func tryFetch() {
        do {
            try performFetch()
        } catch {
            print("Unresolved error: \(error.localizedDescription)")
        }
    }
    
    //MARK: Fetched Results Controller Delegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
            case .insert:
                tableView?.insertSections(indexSet, with: .automatic)
            case .delete:
                tableView?.deleteSections(indexSet, with: .automatic)
            case .update:
                tableView?.reloadSections(indexSet, with: .automatic)
            default: return
            }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                guard let newIndexPath = newIndexPath else { return }
                tableView?.insertRows(at: [newIndexPath], with: .left)
            case .delete:
                guard  let indexPath = indexPath else { return }
                tableView?.deleteRows(at: [indexPath], with: .bottom)
            case .update, .move:
                guard let indexPath = indexPath else { return }
                tableView?.reloadRows(at: [indexPath], with: .automatic)
            default: return
        }
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.endUpdates()
    }
}
