//
//  AlertDismiss.swift
//  Budget
//
//  Created by Yago Saboia on 21/05/21.
//  Copyright © 2021 com.yagoapps. All rights reserved.
//

import Foundation

enum AlertMessages: CustomStringConvertible{
    case ok
    case dismiss
    case confirm
    
    var description : String {
        switch self {
        // Use Internationalization, as appropriate.
        case .ok: return "Ok"
        case .dismiss: return "Dismiss"
        case .confirm: return "Confirm"
        }
    }
    
    
}
