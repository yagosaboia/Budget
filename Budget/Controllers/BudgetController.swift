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
    
    
    @IBOutlet weak var valueTxf: CurrencyTextField!
    
    @IBOutlet weak var descriptionTxf: UITextField!
    
    
    @IBOutlet weak var dateTxf: UITextField!
    
    @IBOutlet weak var paidReceivedSegment: UISegmentedControl!
    
    @IBOutlet weak var doneBtn: UIBarButtonItem!
    
    private var datePicker = UIDatePicker()
    
    private var usedDate : Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupTransaction()
        
        doneBtn.title = "Done"
        //setup for date picker
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.date = Date()
        
        datePicker.addTarget(self, action: #selector(BudgetController.dateChanged(datePicker:)), for: .valueChanged)
        dateTxf.inputView = datePicker
        
        //Need to remember what this do
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(BudgetController.viewTapped(gestureRecognizer:)))
        
        view.addGestureRecognizer(tapGesture)
        
        valueTxf.delegate = self
        valueTxf.attributedPlaceholder = NSAttributedString(string:"placeholder text",
                                                            attributes:[NSAttributedString.Key.foregroundColor: UIColor.black])
        
        
    }
    
    func setupTransaction(){
        switch transType{
        case .expense:
            navigationController?.title = "Expense"
            totalText.text = "Total to pay"
            paidReceivedSegment.setTitle("Not paid", forSegmentAt: 0)
            paidReceivedSegment.setTitle("Paid", forSegmentAt: 1)
            dateTxf.placeholder = "Expiring date"
            
            if (expense != nil){
                guard let value = expense?.value, let description = expense?.description, let date = expense?.date else { return }
                valueTxf.startingValue = value
                valueTxf.amountAsDouble = value
                descriptionTxf.text = description
                usedDate = date
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy"
                dateTxf.text = dateFormatter.string(from: date)
                
            }else{
                valueTxf.startingValue = 0
            }
        case .revenue:
            navigationController?.title = "Revenue"
            totalText.text = "Total of revenue"
            paidReceivedSegment.setTitle("Not received", forSegmentAt: 0)
            paidReceivedSegment.setTitle("Received", forSegmentAt: 1)
            dateTxf.placeholder = "Date"
            
            if (revenue != nil){
                guard let value = revenue?.value, let description = revenue?.description, let date = revenue?.date else { return }
                valueTxf.startingValue = value
                valueTxf.amountAsDouble = value
                descriptionTxf.text = description
                usedDate = date
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy"
                dateTxf.text = dateFormatter.string(from: date)
                
            }else{
                valueTxf.startingValue = 0
            }
        default:
            navigationController?.title = "Expense"
        }
    }

    
    
    
    @IBAction func doneAction(_ sender: Any) {
        if transType == .revenue{
            revenueType()
        }else{
            expenseType()
        }
    }
    
    func expenseType(){
        
        
        if valueTxf.amountAsDouble == 0{
            AlertsManager.shared.simpleAlert(withText: "Please enter a value to expense", toView: self)
        }else if(descriptionTxf.text == "" ){
            AlertsManager.shared.simpleAlert(withText: "Please enter a description", toView: self)
        }else if(dateTxf.text == "" || usedDate == nil){
            AlertsManager.shared.simpleAlert(withText: "Please enter a valid date", toView: self)
        }else{
            var paid = false
            
            if paidReceivedSegment.selectedSegmentIndex == 0 {
                paid = false
            }else{
                paid = true
            }
            
            guard let value = valueTxf.amountAsDouble, let description = descriptionTxf.text, let date = usedDate else {
                print("Failed to read expense data")
                return
            }
            
            if(expense != nil){
                //The expense is being updated
                guard let expenseID = expense?.ID else { return }
                FirebaseService.shared.updateExpense(withID: expenseID, value: value, description: description, date: date, paid: paid) { error in
                    guard let error = error else {
                        return
                    }
                    AlertsManager.shared.simpleAlert(withText: "Update failed, try later", toView:  self)
                    print(error)
                }
            }else{
                //It's a new expense
                FirebaseService.shared.writeExpense(value: value ,description: description, date: date, paid: paid) { error in
                    guard let error = error else {
                        return
                    }
                    AlertsManager.shared.simpleAlert(withText: "Expense create failed, try later", toView: self)
                    print(error)
                }
            }
            //fix this so it only go back when the firebase service is dones
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func revenueType() {
        
        if valueTxf.amountAsDouble == 0{
            AlertsManager.shared.simpleAlert(withText: "Please enter a value to revenue", toView: self)
        }else if(descriptionTxf.text == "" ){
            AlertsManager.shared.simpleAlert(withText: "Please enter a description", toView: self)
        }else if(dateTxf.text == "" || usedDate == nil){
            AlertsManager.shared.simpleAlert(withText: "Please enter a valid date", toView: self)
        }else{
            var received = false
            if paidReceivedSegment.selectedSegmentIndex == 0 {
                received = false
            }else{
                received = true
            }
            
            guard let value = valueTxf.amountAsDouble, let description = descriptionTxf.text,  let date = usedDate else {
                print("Failed to read revenue data")
                return
            }
            
            if(revenue != nil){
                guard let revenueID = revenue?.ID else{ return }
                FirebaseService.shared.updateRevenue(withID: revenueID, value: value, description: description, date: date, received: received) { error in
                    guard let error = error else {
                        return
                    }
                    AlertsManager.shared.simpleAlert(withText: "Update failed, try later", toView: self)
                    print(error)
                }
            }else{
                FirebaseService.shared.writeRevenue(value: value, description: description, date: date, received: received) { error in
                    guard let error = error else {
                        return
                    }
                    AlertsManager.shared.simpleAlert(withText: "Expense create failed, try later", toView: self)
                    print(error)
                }
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func viewTapped(gestureRecognizer : UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    @objc func dateChanged(datePicker : UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateTxf.text = dateFormatter.string(from: datePicker.date)
        
        usedDate = datePicker.date
        
        view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    
}
