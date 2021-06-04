//
//  ExpenseController.swift
//  Budget
//
//  Created by Yago Saboia Felix Frota on 23/04/19.
//  Copyright © 2019 com.yagoapps. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth

class BudgetController: UIViewController, UITextFieldDelegate {
    
    var expense: Expense?
    var revenue: Revenue?
    var transType: TransactionType!
    var transAction: TransactionAction!
    
    
    @IBOutlet weak var totalText: UILabel!
    
    @IBOutlet weak var valueTxf: UITextField!
    
    @IBOutlet weak var descriptionTxf: UITextField!
    
    
    @IBOutlet weak var dateTxf: UITextField!
    
    @IBOutlet weak var paidSeg: UISegmentedControl!
    
    
    var amt: Int = 0
    var paid: String = ""
    private var datePicker : UIDatePicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch transType{
        case .expense:
            navigationController?.title = "Expense"
        case .revenue:
            navigationController?.title = "Revenue"
        default:
            navigationController?.title = "Expense"
        }
        
        if(revenue != nil || transType == .revenue){
            totalText.text = "Total of revenue"
            paidSeg.isHidden = true
            dateTxf.placeholder = "Date"
        }
        
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        
        datePicker?.addTarget(self, action: #selector(BudgetController.dateChanged(datePicker:)), for: .valueChanged)
        dateTxf.inputView = datePicker
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(BudgetController.viewTapped(gestureRecognizer:)))
        
        view.addGestureRecognizer(tapGesture)
        
        valueTxf.delegate = self
        valueTxf.attributedPlaceholder = NSAttributedString(string:"placeholder text",
                                                            attributes:[NSAttributedString.Key.foregroundColor: UIColor.black])
        valueTxf.placeholder = updateAmount()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(expense) != nil{
            valueTxf.text = expense?.value
            descriptionTxf.text = expense?.description
            dateTxf.text = expense?.date
            if(expense?.paid == "paid"){
                paidSeg.selectedSegmentIndex = 1
            }
        }
        if(revenue) != nil{
            valueTxf.text = revenue?.value
            descriptionTxf.text = revenue?.description
            dateTxf.text = revenue?.date
        }
    }
    
    @IBAction func returnBtt(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneBtt(_ sender: Any) {
        if transType == .expense{
            expenseType()
        }else if(transAction == .edit && expense != nil){
            expenseType()
        }else{
            revenueType()
        }
        
    }
    
    func expenseType(){
        let user = Auth.auth().currentUser
        if let user = user {
            let uid = user.uid
            
            if valueTxf.text == "" || valueTxf.text == "0.00" {
                AlertsManager.shared.simpleAlert(withText: "Please enter a value to expense", toView: self)
            }else if(descriptionTxf.text == "" ){
                AlertsManager.shared.simpleAlert(withText: "Please put a description", toView: self)
            }else if(dateTxf.text == ""){
                AlertsManager.shared.simpleAlert(withText: "Please put a date", toView: self)
            }else{
                
                if paidSeg.selectedSegmentIndex == 0 {
                    paid = "not paid"
                }else{
                    paid = "paid"
                }
                guard let value = valueTxf.text, let description = descriptionTxf.text, let date = dateTxf.text else {return}
                
                if(expense != nil){
                    guard let id = expense?.ID else { return }
                    FirebaseService.shared.updateExpense(id, uid, value, description, date, paid) { error in
                        guard let error = error else {
                            self.dismiss(animated: true, completion: nil)
                            return
                        }
                        AlertsManager.shared.simpleAlert(withText: "Update failed, try later", toView:  self)
                        print(error)
                    }
                }else{
                    FirebaseService.shared.writeExpense(uid, value, description, date, paid) { error in
                        guard let error = error else {
                            self.dismiss(animated: true, completion: nil)
                            return
                        }
                        AlertsManager.shared.simpleAlert(withText: "Expense create failed, try later", toView: self)
                        print(error)
                    }
                }
            }
            
        }
    }
    
    func revenueType() {
        let user = Auth.auth().currentUser
        if let user = user {
            let uid = user.uid
            
            if valueTxf.text == "" || valueTxf.text == "0.00" {
                AlertsManager.shared.simpleAlert(withText: "Please enter a value to revenue", toView: self)
            }else if(descriptionTxf.text == "" ){
                AlertsManager.shared.simpleAlert(withText: "Please put a description", toView: self)
            }else if(dateTxf.text == ""){
                AlertsManager.shared.simpleAlert(withText: "Please put a date", toView: self)
            }else{
                
                guard let value = valueTxf.text, let description = descriptionTxf.text, let date = dateTxf.text else {return}
                
                if(revenue != nil){
                    guard let id = revenue?.ID else{ return }
                    FirebaseService.shared.updateRevenue(id, uid, value, description, date) { error in
                        guard let error = error else {
                            self.dismiss(animated: true, completion: nil)
                            return
                        }
                        AlertsManager.shared.simpleAlert(withText: "Update failed, try later", toView: self)
                        print(error)
                    }
                }else{
                    FirebaseService.shared.writeRevenue(uid, value, description, date) { error in
                        guard let error = error else {
                            self.dismiss(animated: true, completion: nil)
                            return
                        }
                        AlertsManager.shared.simpleAlert(withText: "Expense create failed, try later", toView: self)
                        print(error)
                    }
                }
            }
            
        }
    }
    
    @objc func viewTapped(gestureRecognizer : UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    @objc func dateChanged(datePicker : UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateTxf.text = dateFormatter.string(from: datePicker.date)
        view.endEditing(true)
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let digit = Int(string) {
            
            amt = amt * 10 + digit
            
            if amt > 1_000_000_000_00 {
                AlertsManager.shared.simpleAlert(withText: "Please enter a amount less than 1 billion", toView: self)
                
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
