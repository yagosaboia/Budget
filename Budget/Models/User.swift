//
//  User.swift
//  Budget
//
//  Created by Yago Saboia Felix Frota on 24/04/19.
//  Copyright © 2019 com.yagoapps. All rights reserved.
//

import HandyJSON
class User : HandyJSON {
    var userID: String?
    var email: String?
    var expenses: [String: Bool]?
    required init() {
    }
}

