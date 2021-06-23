//
//  FirebaseService.swift
//  Budget
//
//  Created by Yago Saboia Felix Frota on 25/04/19.
//  Copyright © 2019 com.yagoapps. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
class FirebaseService{
    static var shared = FirebaseService()
    var databaseRef : DatabaseReference
    var user : FirebaseAuth.User?
    
    private init() {
        databaseRef = Database.database().reference()
        user = Auth.auth().currentUser
    }
    
    func logUserIn(withEmail email : String, password : String,view: UIViewController, completion: @escaping (_ error: Error?) -> ()){
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            guard let newUser = result?.user else { return }
            self.user = newUser
            
            if let error = error {
                print("failed to sign in user with error: ", error.localizedDescription)
                completion(error)
            }
            
            completion(nil)
        }
    }
    
    
    func createUser(withEmail email : String, password : String, completion: @escaping (_ error: Error?) -> ()){
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            
            
            if let error = error {
                print("failed to sign up user with error: ", error.localizedDescription)
                completion(error)
            }
            
            guard let newUser = result?.user else { return }
            self.user = newUser
            
            let values = ["email" : email]
            
            self.databaseRef.child("users").child(newUser.uid).updateChildValues(values, withCompletionBlock: { (error, ref) in
                
                if let error = error {
                    print("failed to update database values with error: ", error.localizedDescription)
                    completion(error)
                }
                
                print("Sucessfully signed up")
                completion(nil)
                
            })
        }
    }
    
    
    
    func loadExpenses(completion: @escaping (_ expenses: [Expense]) -> ()) {
        var expenses: [Expense] = []
        
        guard let uid = user?.uid else {
            print("Failed to retrive user key in loadExpenses")
            return
        }
        
        databaseRef.child("users").child(uid).child("expenses").observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                
                let snap = child as! DataSnapshot
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                
                guard let data = snap.data else {
                    print("Failed to read a expense")
                    return
                }
                print("\(String(decoding: data, as: UTF8.self))")
                do{
                    var expense = try decoder.decode(Expense.self, from: data)
                    expense.ID = snap.key
                    expenses.append(expense)
                }catch{
                    print(error)
                }
                
            }
            
            DispatchQueue.main.async {
                completion(expenses)
            }
        }
    }
    
    func loadRevenues(completion: @escaping (_ revenues: [Revenue]) -> ()){
        var revenues: [Revenue] = []
        
        guard let uid = user?.uid else {
            print("Failed to retrive user key in loadRevenues")
            return
        }
        
        let userRef = databaseRef.child("users").child(uid)
        
        let revenuesRef = userRef.child("revenues")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        revenuesRef.observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                
                let snap = child as! DataSnapshot
                guard let data = snap.data, var revenue = try? decoder.decode(Revenue.self, from: data) else {
                    print("Failed to read a revenue")
                    return
                }
                
                revenue.ID = snap.key
                revenues.append(revenue)
            }
            
            DispatchQueue.main.async {
                completion(revenues)
            }
        }
    }
    
    func writeExpense(value: Double,description: String, date: Date, paid : Bool, completion: @escaping (_ error: Error?) -> ()) {
        
        //remake this guard let to check for the 2 conditions
        guard let uid = user?.uid, let newKey = databaseRef.childByAutoId().key else {
            print("Failed to retrive user key or generate a key in writeExpenses")
            return
        }
        let timestamp = date.timeIntervalSince1970
        
        databaseRef.child("users").child(uid).child("expenses").child(newKey).setValue(["value" : value, "description" : description, "date" : timestamp, "paid" : paid]) { error, _ in
            guard let errorMessage = error?.localizedDescription else { return }
            print(errorMessage)
            
        }
        
    }
    func updateExpense(withID expenseID: String, value: Double, description: String, date: Date, paid : Bool, completion: @escaping (_ error: Error?) -> ()) {
        
        guard let uid = user?.uid else {
            print("Failed to retrive user key in updateExpenses")
            return
        }
        
        let timestamp = date.timeIntervalSince1970
        
        databaseRef.child("users").child(uid).child("expenses").child(expenseID).updateChildValues(["value" : value, "description" : description, "date" : timestamp, "paid" : paid]) {error, _ in
            guard let errorMessage = error?.localizedDescription else { return }
            print(errorMessage)
        }
        
    }
    
    func removeExpense(withID expenseID: String, completion: @escaping (_ error: Error?) -> ()){
        
        guard let uid = user?.uid else {
            print("Failed to retrive user key in removeExpenses")
            return
        }
        
        databaseRef.child("users").child(uid).child("expenses").child(expenseID).removeValue { error, _ in
            guard let errorMessage = error?.localizedDescription else { return }
            print(errorMessage)
        }
        
    }
    
    func writeRevenue(value: Double, description: String, date: Date, received: Bool, completion: @escaping (_ error: Error?) -> ()) {
        
        guard let uid = user?.uid, let newKey = databaseRef.childByAutoId().key else {
            print("Failed to retrive user key in writeRevenue")
            return
        }
        
        let timestamp = date.timeIntervalSince1970
        
        databaseRef.child("users").child(uid).child("revenues").child(newKey).setValue(["value" : value, "description" : description, "date" : timestamp, "received" : received]) { error, _ in
            guard let errorMessage = error?.localizedDescription else { return }
            print(errorMessage)
            
        }
    }
    func updateRevenue(withID revenueID: String, value: Double, description: String, date: Date, received: Bool, completion: @escaping (_ error: Error?) -> ()) {
        
        guard let uid = user?.uid else {
            print("Failed to retrive user key in updateRevenue")
            return
        }
        
        let timestamp = date.timeIntervalSince1970
        
        databaseRef.child("users").child(uid).child("revenues").child(revenueID).updateChildValues(["value" : value, "description" : description, "date" : timestamp, "received" : received]) {error, _ in
            guard let errorMessage = error?.localizedDescription else { return }
            print(errorMessage)
        }
    }
    
    func removeRevenue(withID revenueID: String, completion: @escaping (_ error: Error?) -> ()){
        
        guard let uid = user?.uid else {
            print("Failed to retrive user key in removeRevenue")
            return
        }
        
        databaseRef.child("users").child(uid).child("revenues").child(revenueID).removeValue { error, _ in
            guard let errorMessage = error?.localizedDescription else { return }
            print(errorMessage)
        }
    }
    
}
