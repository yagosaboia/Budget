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
    
    
    @IBOutlet weak var logoutBtn: UIBarButtonItem!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    //var handle: AuthStateDidChangeListenerHandle?
    //var dbHandle : DatabaseHandle?
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
        
        logoutBtn.title = "Logout"
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    @IBAction func refreshAction(_ sender: Any) {
        loadData()
    }
    
    
    @IBAction func addAction(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        
        let addExpenseAction = UIAlertAction(title: "Add Expense", style: .default) { _ in
            self.performSegue(withIdentifier: "AddEditBudget", sender: TransactionType.expense)
        }
        let addRevenueAction = UIAlertAction(title: "Add Revenue", style: .default) { _ in
            self.performSegue(withIdentifier: "AddEditBudget", sender: TransactionType.revenue)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        optionMenu.addAction(addExpenseAction)
        optionMenu.addAction(addRevenueAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
        
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            
            let storyboard = UIStoryboard(name: "LogScreen", bundle: nil)
            
            let viewController = storyboard.instantiateViewController(withIdentifier: "logInController") as! LogInController
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true, completion: nil)
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let addEdit = segue.destination as? BudgetController else {return}
        
        if let sender = sender as? TransactionType{
            switch sender{
            case .expense:
                addEdit.transAction = .add
                addEdit.transType = .expense
            case .revenue:
                addEdit.transAction = .edit
                addEdit.transType = .revenue
            }
        }else{
            switch sender{
            case is Expense:
                    addEdit.expense = sender as? Expense
                    addEdit.transAction = .edit
                    addEdit.transType = .expense
            case is Revenue:
                    addEdit.revenue = sender as? Revenue
                    addEdit.transAction = .edit
                    addEdit.transType = .revenue
            default:
                print("Uncorrect type at prepareForSegue - MainController")
                AlertsManager.shared.simpleAlert(withText: "Ops! something went wrong", toView: self)
            }
        }
    }
    
    func loadAll(){
        //NEED TO REWORK BALANCE LOGIC
        var balance: Double = 0
        var allExpenses: Double = 0
        var notPaid: Double = 0
        
        for revenue in revenues{
            if let value = revenue.value{
                balance += value
            }
        }
        for expense in expenses{
            guard let value = expense.value, let paid = expense.paid else { return }
            if paid{
                balance -= value
            }else{
                notPaid += value
            }
            allExpenses += value
        }
        
        let formatter = NumberFormatter()
        
        //balance is negative until logic fixes
        if balance < 0{
            balance = 0
        }
        
        formatter.numberStyle = NumberFormatter.Style.currency
        
        accountBalance.text = formatter.string(for: balance)
        accountExpenses.text = formatter.string(for: allExpenses)
        accountNotPaid.text = formatter.string(for: notPaid)
    }
    
    func loadData(){
        FirebaseService.shared.loadExpenses() { retrieved in
            self.expenses = retrieved
        }
        
        FirebaseService.shared.loadRevenues() { retrieved in
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
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        if(indexPath.section == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCells", for: indexPath) as!  ExpenseCell
            let expense = expenses[indexPath.row]
            
            guard let value = expense.value, let description = expense.description, let date = expense.date, let paid = expense.paid else {
                print("Failure to read expense cell in cellForRow at MainController")
                return cell
            }
            
            cell.value.text = formatter.string(for: value)
            cell.descript.text = description
            cell.date.text = dateFormatter.string(from: date)
            if(paid == true){
                cell.paid.text = "Paid"
            }else{
                cell.paid.text = "Not paid"
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "RevenueCells", for: indexPath) as!  RevenueCell
            let revenue = revenues[indexPath.row]
            
            guard let value = revenue.value, let description = revenue.description, let date = revenue.date, let received = revenue.received else {
                print("Failure to read expense cell in cellForRow at MainController")
                return cell
            }
            
            cell.value.text = formatter.string(for: value)
            cell.descript.text = description
            cell.date.text = dateFormatter.string(from: date)
            if(received == true){
                cell.received.text = "Received"
            }else{
                cell.received.text = "Not received"
            }
            
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
                FirebaseService.shared.removeExpense(withID: expenses[indexPath.row].ID!) { (error) in
                    guard let error = error else {
                        self.expenses.remove(at :indexPath.row )
                        tableView.reloadData()
                        return
                    }
                    AlertsManager.shared.simpleAlert(withText: "Failed to delete, try later", toView: self)
                    print(error)
                }
            }else{
                FirebaseService.shared.removeRevenue(withID: revenues[indexPath.row].ID!){ (error) in
                    guard let error = error else {
                        self.revenues.remove(at :indexPath.row )
                        tableView.reloadData()
                        return
                    }
                    AlertsManager.shared.simpleAlert(withText: "Failed to delete, try later", toView: self)
                    print(error)
            }
            }
        }
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if(indexPath.section == 0){
            let expense = expenses[indexPath.row]
            performSegue(withIdentifier: "AddEditBudget", sender: expense)
            }else{
                let revenue = revenues[indexPath.row]
                performSegue(withIdentifier: "AddEditBudget", sender: revenue)
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
