//
//  Revenue.swift
//  Budget
//
//  Created by Yago Saboia Felix Frota on 25/04/19.
//  Copyright © 2019 com.yagoapps. All rights reserved.
//

import Foundation


struct Revenue : Codable{
    var ID: String?
    var value: Double?
    var description: String?
    var date: Date?
    var received: Bool?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        value = try container.decode(Double.self, forKey: .value)
        description = try container.decode(String.self, forKey: .description)
        date = try container.decode(Date.self, forKey: .date)
        received = try container.decode(Bool.self, forKey: .received)
    }
}
