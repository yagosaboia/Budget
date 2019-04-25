//
//  ViewController.swift
//  Budget
//
//  Created by Yago Saboia Felix Frota on 23/04/19.
//  Copyright © 2019 com.yagoapps. All rights reserved.
//
//Ajeitar o sync e tela de loading

import UIKit
import Firebase
import FirebaseAuth

class MainController: UIViewController{
    
    
    @IBOutlet weak var value: UILabel! //change to totalAmount
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var handle: AuthStateDidChangeListenerHandle?
    var dbHandle : DatabaseHandle?
    var expenses : [Expense] = [] {
        didSet {
            tableView.reloadData()
            loadValue()
        }
    }
    var searchExpenses = [Expense]()
    var searching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = UITableView.automaticDimension
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if Auth.auth().currentUser != nil {
                // User is signed in.
                // ...
                self.loadData()
            } else {
                // No user is signed in.
                // ...
                
                
            self.performSegue(withIdentifier: "newUser", sender: self)
            }
            
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    //fix the transition from maincontroller to login controller when user is nil
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    @IBAction func logoutBtt(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let editExpense = segue.destination as? ExpenseController else {return}
        editExpense.expense = sender as? Expense
    }
    
    //verify if the unwrap is correct and change variable to totalAmount
    func loadValue(){

        var total = 0.00
        for expense in expenses{
            if(expense.paid == "not paid"){
            var trValue = expense.value!
            print(trValue)
            trValue.removeFirst()
            let amt = Double(trValue)
            total+=amt!
            }
        }
        let totalAmount = ("$"+String(total))
        value.text = totalAmount
    }
    
    func loadData(){
        let user = Auth.auth().currentUser
        guard let uid = user?.uid else {
            return
        }
        expenses = []
        let expensesRef = Database.database().reference(withPath: "expenses" )
        expensesRef.observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let expenseDict = snap.value as! [String : Any]
                let userID = expenseDict["userID"] as! String
                if uid == userID {
                    let expense = Expense.deserialize(from: expenseDict)
                    expense?.ID = snap.key
                    self.expenses.append(expense!)
                }
            }
        }
        
    }
    
}

extension MainController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searching == true){
            return searchExpenses.count
        }else{
        return expenses.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCells", for: indexPath) as!  ExpenseCell
        if (searching == true){
            
        }else{
        cell.value.text = expenses[indexPath.row].value
        cell.descript.text = expenses[indexPath.row].description
        cell.date.text = expenses[indexPath.row].date
        cell.paid.text = expenses[indexPath.row].paid
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let expenseRef = Database.database().reference(withPath: "expenses").child(expenses[indexPath.row].ID!)
        expenseRef.removeValue { error, _ in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        let user = Auth.auth().currentUser
        guard let uid = user?.uid else {
            return
        }
        let userRef = Database.database().reference(withPath : "users").child(uid).child("expenses").child(expenses[indexPath.row].ID!)
        userRef.removeValue { error, _ in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        expenses.remove(at :indexPath.row )
        self.tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let expense = expenses[indexPath.row]
        performSegue(withIdentifier: "expenseSegue", sender: expense)
    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        performSegue(withIdentifier: "budgetSegue", sender: indexPath.row)
//    }
}

extension MainController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchExpenses = expenses.filter({$0.description?.prefix(searchText.count).lowercased() == searchText.lowercased()})
        searching = true
        if(searchText.count == 0){
            searching = false
        }
        tableView.reloadData()
    }
}
