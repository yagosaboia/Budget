//
//  Expenses.swift
//  Budget
//
//  Created by Yuri Saboia Felix Frota on 24/04/19.
//  Copyright © 2019 com.yagoapps. All rights reserved.
//

import Foundation

class Expenses {
    let value : String
    let description : String
    let date : String
    let paid : String
    
    init(with value : String, description: String, date : String, paid : String){
        self.value = value
        self.description = description
        self.date = date
        self.paid = paid
    }
}
