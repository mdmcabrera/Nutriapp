//
//  SelfSizedTableView.swift
//  NutriApp
//
//  Created by Mar Cabrera on 02/12/2019.
//  Copyright © 2019 Mar Cabrera. All rights reserved.
//

import UIKit

class SelfSizedTableView: UITableView {

    var maxHeight: CGFloat = UIScreen.main.bounds.height

    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
        self.layoutIfNeeded()
    }

    override var intrinsicContentSize: CGSize {
        let height = min(contentSize.height, maxHeight)
        return CGSize(width: contentSize.width, height: height)
    }

}
