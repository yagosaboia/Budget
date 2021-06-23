//
//  User.swift
//  Budget
//
//  Created by Yago Saboia Felix Frota on 24/04/19.
//  Copyright © 2019 com.yagoapps. All rights reserved.
//

import Foundation

struct User : Codable {
    var userID: String?
    var email: String?
    //For use when coreData is implemented - Used so you don't need to refresh all elements if there's no change(maybe use a type of count to check
    //for changes on expenses and revenues?
    //var lastModified: Date?
    var expenses: [String : Expense]?
    var revenues: [String : Revenue]?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        userID = try container.decode(String.self, forKey: .userID)
        email = try container.decode(String.self, forKey: .email)
        
        //lastModified = try container.decode(Date.self, forKey: .lastModified)
        
        expenses = try container.decode([String : Expense].self, forKey: .expenses)
        
        revenues = try container.decode([String : Revenue].self, forKey: .revenues)
    }
}

