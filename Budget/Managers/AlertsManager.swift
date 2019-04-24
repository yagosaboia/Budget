//
//  AlertsManager.swift
//  Budget
//
//  Created by Yago Saboia Felix Frota on 24/04/19.
//  Copyright © 2019 com.yagoapps. All rights reserved.
//

import Foundation
import UIKit

class AlertsManager : NSObject {
    func alertSpecs(withText text : String) -> UIAlertController{
        let alert = UIAlertController(title: text, message: nil, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        
        
        return alert
    }
    
    
}


