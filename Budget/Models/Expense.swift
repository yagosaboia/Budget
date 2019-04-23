//
//  Expense.swift
//  Budget
//
//  Created by Yago Saboia Felix Frota on 23/04/19.
//  Copyright © 2019 com.yagoapps. All rights reserved.
//

import Foundation

class Expense{
    var value : Float
    var description : String
    var date: NSDate
    var paid : Bool
    
    init(value: Float, description : String, date : NSDate, paid : Bool) {
        self.value = value
        self.description = description
        self.date = date
        //        if let desc = description{
        //        self.description = desc;
        //        }
        //        if let date1 = date {
        //            self.date = date1;
        //        }
        self.paid = paid
        
    }
}
