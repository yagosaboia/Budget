//
//  Expense.swift
//  Budget
//
//  Created by Yago Saboia Felix Frota on 23/04/19.
//  Copyright © 2019 com.yagoapps. All rights reserved.
//

import Foundation
import HandyJSON

class Expense : HandyJSON{
    var ID : String?
    var userID : String?
    var value : String?
    var description : String?
    var date : String?
    var paid : String?
    
    required init(){
        
    }
    
    
}
