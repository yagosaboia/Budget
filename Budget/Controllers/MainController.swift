//
//  ViewController.swift
//  Budget
//
//  Created by Yago Saboia Felix Frota on 23/04/19.
//  Copyright © 2019 com.yagoapps. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class MainController: UIViewController{
    
    
    
    @IBOutlet weak var accountBalance: UILabel!
    
    
    @IBOutlet weak var accountExpenses: UILabel!
    
    @IBOutlet weak var accountNotPaid: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var handle: AuthStateDidChangeListenerHandle?
    var dbHandle : DatabaseHandle?
    var expenses : [Expense] = [] {
        didSet {
            tableView.reloadData()
            loadAll()
        }
    }
    var revenues: [Revenue] = [] {
        didSet {
            tableView.reloadData()
            loadAll()
        }
    }
    var searchExpenses = [Expense]()
    var searchRevenues = [Revenue]()
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
//        self.loadData()
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
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    @IBAction func addBtt(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        
        let addExpenseAction = UIAlertAction(title: "Add Expense", style: .default) { _ in
            self.performSegue(withIdentifier: "addSegue", sender: Type.expense)
        }
        let addRevenueAction = UIAlertAction(title: "Add Revenue", style: .default) { _ in
            self.performSegue(withIdentifier: "addSegue", sender: Type.revenue)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        optionMenu.addAction(addExpenseAction)
        optionMenu.addAction(addRevenueAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
        
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
        
        if let expense = sender as? Expense {
            guard let editExpense = segue.destination as? AddBudgetController else {return}
            editExpense.expense = expense
            editExpense.type = .edit
        }else if let revenue = sender as? Revenue{
            guard let editRevenue = segue.destination as? AddBudgetController else { return }
            editRevenue.revenue = revenue
            editRevenue.type = .edit
        }
        else {
            guard let addExpense = segue.destination as? AddBudgetController, let type = sender as? Type else {return}
            addExpense.type = type
        }
    }
    
    func loadAll(){
        var total: Double = 0.00
        for revenue in revenues{
                var trValue = revenue.value!
                trValue.removeFirst()
                let amt = Double(trValue)
                total+=amt!
            }
        var totalAmount = ("$"+String(total))
        accountBalance.text = totalAmount
        
        total = 0.00
        for expense in expenses{
                var trValue = expense.value!
                trValue.removeFirst()
                let amt = Double(trValue)
                total+=amt!
            }
        totalAmount = ("$"+String(total))
        accountExpenses.text = totalAmount
    
    
    
        total = 0.00
        for expense in expenses{
            if(expense.paid == "not paid"){
                var trValue = expense.value!
                trValue.removeFirst()
                let amt = Double(trValue)
                total+=amt!
            }
        }
        totalAmount = ("$"+String(total))
        accountNotPaid.text = totalAmount
    }
    
    func loadData(){
        let user = Auth.auth().currentUser
        guard let uid = user?.uid else {
            return
        }
        FirebaseService.shared.loadExpenses(uid) { retrieved in
            self.expenses = retrieved
        }
        
        FirebaseService.shared.loadRevenues(uid) { retrieved in
            self.revenues = retrieved
        }
    }
    
}

extension MainController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searching == true){
            if section == 0 {
                return searchExpenses.count
            }
            return searchRevenues.count
        }else {
            if section == 0 {
                return expenses.count
            }
            return revenues.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Expenses" : "Revenue"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCells", for: indexPath) as!  ExpenseCell
            let expense = expenses[indexPath.row]
            cell.value.text = expense.value
            cell.descript.text = expense.description
            cell.date.text = expense.date
            cell.paid.text = expense.paid
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "RevenueCells", for: indexPath) as!  RevenueCell
            
            let revenue = revenues[indexPath.row]
            cell.value.text = revenue.value
            cell.descript.text = revenue.description
            cell.date.text = revenue.date
            return cell
        }
    }
    
        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            guard editingStyle == .delete else { return }
            
            
            let user = Auth.auth().currentUser
            guard let uid = user?.uid else {
                return
            }
            if(indexPath.section == 0){
                FirebaseService.shared.removeExpense(uid: uid, expenseID: expenses[indexPath.row].ID!) { (error) in
                    guard let error = error else {
                        self.expenses.remove(at :indexPath.row )
                        tableView.reloadData()
                        return
                    }
                    AlertsManager.shared.alertSpecs(withText: "Failed to delete, try later", view: self)
                    print(error)
                }
            }else{
                FirebaseService.shared.removeRevenue(uid: uid, revenueID: revenues[indexPath.row].ID!){ (error) in
                    guard let error = error else {
                        self.revenues.remove(at :indexPath.row )
                        tableView.reloadData()
                        return
                    }
                    AlertsManager.shared.alertSpecs(withText: "Failed to delete, try later", view: self)
                    print(error)
            }
            }
        }
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if(indexPath.section == 0){
            let expense = expenses[indexPath.row]
            performSegue(withIdentifier: "addSegue", sender: expense)
            }else{
                let revenue = revenues[indexPath.row]
                performSegue(withIdentifier: "addSegue", sender: revenue)
            }
        }
    
}

extension MainController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchExpenses = expenses.filter({$0.description?.prefix(searchText.count).lowercased() == searchText.lowercased()})
        searchRevenues = revenues.filter({$0.description?.prefix(searchText.count).lowercased() == searchText.lowercased()})
        searching = true
        if(searchText.count == 0){
            searching = false
        }
        tableView.reloadData()
    }
}
