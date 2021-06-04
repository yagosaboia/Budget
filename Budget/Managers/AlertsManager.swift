//
//  AlertsManager.swift
//  Budget
//
//  Created by Yago Saboia Felix Frota on 24/04/19.
//  Copyright © 2019 com.yagoapps. All rights reserved.
//

import Foundation
import UIKit

class AlertsManager{
    static var shared = AlertsManager()
    private init(){
        
    }
    
    func simpleAlert(withText text : String, toView view : UIViewController){
        let alert = UIAlertController(title: text, message: nil, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: AlertMessages.ok.description, style: UIAlertAction.Style.default, handler: nil))
        
        view.present(alert, animated: true, completion: nil)
    }
    
    func customAlert(withText text : String,andMessage message: AlertMessages,toView view : UIViewController){
        let alert = UIAlertController(title: text, message: nil, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: message.description, style: UIAlertAction.Style.default, handler: nil))
        
        view.present(alert, animated: true, completion: nil)
    }
    
    
}


