//
//  Expense.swift
//  Budget
//
//  Created by Yago Saboia Felix Frota on 23/04/19.
//  Copyright © 2019 com.yagoapps. All rights reserved.
//

import Foundation

struct Expense : Codable{
    var ID: String?
    var value: Double?
    var description: String?
    var date: Date?
    var paid: Bool?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        value = try container.decode(Double.self, forKey: .value)
        description = try container.decode(String.self, forKey: .description)
        date = try container.decode(Date.self, forKey: .date)
        paid = try container.decode(Bool.self, forKey: .paid)
    }
    
    
}
