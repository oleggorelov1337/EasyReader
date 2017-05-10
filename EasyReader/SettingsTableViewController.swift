//
//  SettingsTableViewController.swift
//  EasyReader
//
//  Created by Gorelov Oleg on 10/05/17.
//  Copyright © 2017 Oleg Gorelov. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var rssStreamTextField: UITextField!
    
    private var isVisible = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString(Constant.settingsLocKey, comment: "Settings title")

        rssStreamTextField.delegate = self
        
        if let url = UserDefaults.standard.url(forKey: Constant.rssStream) {
            rssStreamTextField.text = url.absoluteString
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isVisible = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        isVisible = false
    }
    
    
    private func showAlert() {
        
        if view.window != nil && isVisible {
            let alert = UIAlertController(title: NSLocalizedString(Constant.attentionLocKey, comment: "Alert title"),
                                          message: NSLocalizedString(Constant.notRSSFlowLocKey, comment: "Alert message"),
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString(Constant.okLocKey, comment: "ok"),
                                         style: .default,
                                         handler: nil)
            alert.addAction(okAction)
            alert.view.tintColor = view.tintColor
            present(alert, animated: true, completion: nil)
        }
        
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionName = ""
        if section == 0 {
            sectionName = NSLocalizedString(Constant.enterRSSstreamLocKey, comment: "section header title")
        }
        return sectionName
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let stream = rssStreamTextField.text {
            
            UserDefaults.standard.set(URL(string: stream), forKey: Constant.rssStream)
            
            DataManager.sharedInstance.searchRSSItems(completionHandler: { isRSS in
                
                if isRSS == false {
                    
                    DispatchQueue.main.async {
                        self.showAlert()
                    }
                    
                }
            })
            
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        rssStreamTextField.resignFirstResponder()
        return true
    }

}
