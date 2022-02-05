//
//  MealHeaderButton.swift
//  NutriApp
//
//  Created by Mar Cabrera on 09/01/2020.
//  Copyright © 2020 Mar Cabrera. All rights reserved.
//

import UIKit

class MealHeaderButton: UIButton {
    override func awakeFromNib() {
        self.frame.size = CGSize(width: 300, height: 40)
        self.backgroundColor = .black
        self.tintColor = .white
        self.layer.cornerRadius = 20
    }
}
