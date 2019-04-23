//
//  ExpenseController.swift
//  Budget
//
//  Created by Yago Saboia Felix Frota on 23/04/19.
//  Copyright © 2019 com.yagoapps. All rights reserved.
//

import Foundation
import UIKit

class ExpenseController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var valueTxf: UITextField!
    
    @IBOutlet weak var descriptionTxf: UITextField!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var paidSeg: UISegmentedControl!
    
    
    var amt: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        valueTxf.delegate = self
        valueTxf.attributedPlaceholder = NSAttributedString(string:"placeholder text",
                                                            attributes:[NSAttributedString.Key.foregroundColor: UIColor.black])
        valueTxf.placeholder = updateAmount()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func returnBtt(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneBtt(_ sender: Any) {
        
        if amt == 0 {
            let alert = UIAlertController(title: "Please enter a value to expense", message: nil, preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
            
            present(alert, animated: true, completion: nil)
        }else if(descriptionTxf.text == "" ){
            let alert = UIAlertController(title: "Please put a description", message: nil, preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
            
            present(alert, animated: true, completion: nil)
        }else{
            
            
            self.dismiss(animated: true, completion: nil)
        }
        
        
        
    }
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let digit = Int(string) {
            
            amt = amt * 10 + digit
            
            if amt > 1_000_000_000_00 {
                let alert = UIAlertController(title: "Please enter a amount less than 1 billion", message: nil, preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
                
                present(alert, animated: true, completion: nil)
                
                valueTxf.text = ""
                
                amt = 0
            }
            
            valueTxf.text = updateAmount()
        }
        if string == "" {
            amt = amt/10
            
            valueTxf.text = updateAmount()
        }
        
        return false
    }
    
    func updateAmount() -> String? {
        let formatter = NumberFormatter()
        
        formatter.numberStyle = NumberFormatter.Style.currency
        
        let amount = Double(amt/100) + Double(amt%100)/100
        
        return formatter.string(from: NSNumber(value: amount))
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
