//
//  DetailItemTableViewController.swift
//  EasyReader
//
//  Created by Oleg Gorelov on 09.05.17.
//  Copyright © 2017 Oleg Gorelov. All rights reserved.
//

import UIKit
import CoreData

class DetailItemTableViewController: UITableViewController {
    

    @IBOutlet weak var titleButton: MultilineButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    private struct Storyboard {
        static let showPage = "showPage"
    }
    
    private var itemLink = ""
    
    private var context: NSManagedObjectContext? = (UIApplication.shared.delegate as? AppDelegate)?.getManagedObjectContext(withConcurrencyType: .mainQueueConcurrencyType)
    
    var itemObjectID: NSManagedObjectID?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(RSSListTableViewController.contextDidChange(notification:)), name: .NSManagedObjectContextDidSave, object: nil)

        tableView.estimatedRowHeight = 600.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView?.tableHeaderView = UIView(frame: CGRect(x: 0.0,
                                                          y: 0.0,
                                                          width: tableView.bounds.size.width,
                                                          height: 0.01))
        
        setupUI()
    }
    
    func contextDidChange(notification: Notification) {
        context?.mergeChanges(fromContextDidSave: notification)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .NSManagedObjectContextDidSave, object: nil)
    }
    
    private func setupUI() {
        
        if context != nil, itemObjectID != nil {
            let item = Item.item(withObjectID: itemObjectID!, inManagedObjectContext: context!)
            titleButton.setTitle(item?.title, for: .normal)
            descriptionLabel.text = item?.descrip
            authorLabel.text = item?.creator
            itemLink = item?.link ?? ""
            
            if let pubDate = item?.pubDate {
                let localizedDateTime = DateFormatter.localizedString(from: pubDate as Date,
                                                                      dateStyle: .medium,
                                                                      timeStyle: .short)
                
                dateLabel.text = localizedDateTime
            }
            
            if let localURL = item?.localImageURL,
                let localImageURL = URL(string: localURL) {
                let image = UIImage(contentsOfFile: localImageURL.path)
                imageView.image = image
            }
        }
        
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let webViewController = segue.destination as? WebViewController,
            segue.identifier == Storyboard.showPage {
            webViewController.itemLink = itemLink
        }
        
    }
    
    // MARK: - Actions
    
    
    @IBAction func tapTitleButtonAction(_ sender: MultilineButton) {
        
        if URL(string: itemLink) != nil {
            performSegue(withIdentifier: Storyboard.showPage, sender: nil)
        }
        
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

}
