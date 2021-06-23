//
//  RevenueCell.swift
//  Budget
//
//  Created by Yago Saboia Felix Frota on 25/04/19.
//  Copyright © 2019 com.yagoapps. All rights reserved.
//

import UIKit

class RevenueCell : UITableViewCell{

    
    @IBOutlet weak var descript: UILabel!
    
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var value: UILabel!
    
    @IBOutlet weak var received: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}
