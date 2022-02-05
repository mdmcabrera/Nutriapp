//
//  EdamamProductTableCell.swift
//  NutriApp
//
//  Created by Mar Cabrera on 17/01/2020.
//  Copyright © 2020 Mar Cabrera. All rights reserved.
//

import UIKit

class EdamamProductTableCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
