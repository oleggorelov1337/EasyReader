//
//  ActivityIndicator.swift
//  EasyReader
//
//  Created by Gorelov Oleg on 10/05/17.
//  Copyright © 2017 Oleg Gorelov. All rights reserved.
//

import Foundation
import UIKit

class ActivityIndicator {
    
    static let shared = ActivityIndicator()
    var numberOfActivities = 0
    
    func increaseActivity() {
        
        numberOfActivities += 1
        UIApplication.shared.isNetworkActivityIndicatorVisible = true;
        
    }
    
    func decreaseActivity() {
        
        if numberOfActivities > 0 {
            numberOfActivities -= 1
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = numberOfActivities > 0
        
    }
    
    func stopActivities() {
        
        numberOfActivities = 0
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
    }
    
}
