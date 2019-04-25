//
//  ExpenseCell.swift
//  Budget
//
//  Created by Yago Saboia Felix Frota on 23/04/19.
//  Copyright © 2019 com.yagoapps. All rights reserved.
//

import UIKit

class ExpenseCell : UITableViewCell{
    
    
    
    
    
    @IBOutlet weak var descript: UILabel!
    
    @IBOutlet weak var value: UILabel!
    
    
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var paid: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}
