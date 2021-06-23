//
//  FirebaseExtension.swift
//  Budget
//
//  Created by Yago Saboia on 18/06/21.
//  Copyright © 2021 com.yagoapps. All rights reserved.
//

import Firebase


extension DataSnapshot{
    var data: Data? {
        guard let value = value, !(value is NSNull) else { return nil }
        return try? JSONSerialization.data(withJSONObject: value)
    }
    var json: String? { data?.string }
}

extension Data{
    var string: String? { String(data: self, encoding: .utf8)}
}
