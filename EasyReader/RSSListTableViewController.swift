//
//  RSSListTableViewController.swift
//  EasyReader
//
//  Created by Oleg Gorelov on 09.05.17.
//  Copyright © 2017 Oleg Gorelov. All rights reserved.
//

import UIKit
import CoreData

class RSSListTableViewController: CoreDataTableViewController {
    
    private struct Storyboard {
        static let itemCellIdentifier = "itemCell"
        static let showDetailItem = "showDetailItem"
        static let rowHeight: CGFloat = 60.0
    }
    
    private var currentItemObjectID: NSManagedObjectID?
    
    var resultsController: NSFetchedResultsController<Item>!

        private var context: NSManagedObjectContext? = (UIApplication.shared.delegate as? AppDelegate)?.getManagedObjectContext(withConcurrencyType: .mainQueueConcurrencyType)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString(Constant.rrsListLocKey, comment: "RRS List VC title")
        navigationItem.leftBarButtonItem?.title = NSLocalizedString(Constant.clearLocKey, comment: "Clear RSS List")
        
        NotificationCenter.default.addObserver(self, selector: #selector(RSSListTableViewController.contextDidChange(notification:)), name: .NSManagedObjectContextDidSave, object: nil)

        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = view.tintColor
        refreshControl?.tintColor = UIColor.white
        refreshControl?.addTarget(self,
                                  action: #selector(RSSListTableViewController.getLatestItems),
                                  for: .valueChanged)
        tableView.tableFooterView = UIView()
        
        setup()
        
        if getTableViewRowCount() == 0 {
            setEmptyDataLabel()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .NSManagedObjectContextDidSave, object: nil)
    }
    
    func contextDidChange(notification: Notification) {
        context?.mergeChanges(fromContextDidSave: notification)
    }
    
    private func setEmptyDataLabel() {
        let messageLabel = UILabel(frame: CGRect(x: 0,
                                                 y: 0,
                                                 width: view.bounds.size.width,
                                                 height: view.bounds.size.height))
        messageLabel.textColor = UIColor.gray
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = NSTextAlignment.center
        messageLabel.font = UIFont(name: "Menlo-Bold ", size: 20)
        messageLabel.text = NSLocalizedString(Constant.listNotLoadedLocKey, comment: "Empty RSS list")
        messageLabel.sizeToFit()
        
        tableView.backgroundView = messageLabel
        navigationItem.leftBarButtonItem?.isEnabled = false
    }


    
    @objc private func getLatestItems() {
        DataManager.sharedInstance.searchRSSItems {
            isGetRSS in
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    private func setup() {

        if let cntx = context {
            let request = NSFetchRequest<Item>(entityName: "Item")
            request.sortDescriptors = [NSSortDescriptor(key: "pubDate", ascending: false)]
            resultsController = NSFetchedResultsController(fetchRequest: request,
                                                           managedObjectContext: cntx,
                                                           sectionNameKeyPath: nil,
                                                           cacheName: nil)
            
            fetchedResultsController = resultsController as? NSFetchedResultsController<NSFetchRequestResult>
        } else {
            fetchedResultsController = nil
        }
        
    }
    
    private func getTableViewRowCount() -> Int {
        var rowCount = 0
        
        for i in 0..<tableView.numberOfSections {
            rowCount += tableView.numberOfRows(inSection: i)
        }
        
        return rowCount
    }
    
    // MARK: - Actions
    
    @IBAction func clearAllItemsAction(_ sender: UIBarButtonItem) {
        
        let actionSheet = UIAlertController(title: NSLocalizedString(Constant.attentionLocKey, comment: "Action sheet Title"), message: NSLocalizedString(Constant.clearListLocKey, comment: "Action sheet message"), preferredStyle: .actionSheet)
        let yesAction = UIAlertAction(title: NSLocalizedString(Constant.yesLocKey, comment: "yes"), style: .destructive) { (action) in
            DataManager.sharedInstance.clearAllItems()
        }
        let noAction = UIAlertAction(title: NSLocalizedString(Constant.noLocKey, comment: "no"), style: .cancel, handler: nil)
        actionSheet.addAction(yesAction)
        actionSheet.addAction(noAction)
        actionSheet.view.tintColor = view.tintColor
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    
    // MARK: - Nabigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        refreshControl?.endRefreshing()
        if let detailItemViewController = segue.destination as? DetailItemTableViewController,
            segue.identifier == Storyboard.showDetailItem, currentItemObjectID != nil {
            detailItemViewController.itemObjectID = currentItemObjectID
            
        } 
        currentItemObjectID = nil
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    
    override func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        super.controllerDidChangeContent(controller)
        
        if getTableViewRowCount() > 0 {
            navigationItem.leftBarButtonItem?.isEnabled = true
        } else {
            navigationItem.leftBarButtonItem?.isEnabled = false
            setEmptyDataLabel()
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Storyboard.rowHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = fetchedResultsController?.object(at: indexPath) as? Item, context != nil {
            currentItemObjectID = item.objectID
            performSegue(withIdentifier: Storyboard.showDetailItem, sender: nil)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
 

    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.itemCellIdentifier, for: indexPath)
        
        guard let itemCell = cell as? ItemTableViewCell else {
            return cell
        }
        
        if let placeholder = UIImage(named: "placeholder") {
            itemCell.itemImageView.image = placeholder
        }
        
        if let item = fetchedResultsController?.object(at: indexPath) as? Item {
            itemCell.itemTitle.text = item.title
            itemCell.itemDescription.text = item.descrip
            
            if let localURL = item.localImageURL,
                let localImageURL = URL(string: localURL) {
                let image = UIImage(contentsOfFile: localImageURL.path)
                itemCell.itemImageView.image = image
            }

        }

        return itemCell
    }
    

}
