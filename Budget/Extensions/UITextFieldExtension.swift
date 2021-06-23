//
//  UITextFieldExtension.swift
//  Budget
//
//  Created by Yago Saboia on 21/06/21.
//  Copyright © 2021 com.yagoapps. All rights reserved.
//

import Foundation
import UIKit

extension UITextField{
    func disableAutoFill() {
            if #available(iOS 12, *) {
                textContentType = .oneTimeCode
            } else {
                textContentType = .init(rawValue: "")
            }
        }
}
