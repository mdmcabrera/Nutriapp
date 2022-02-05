//
//  UITextField+Extension.swift
//  NutriApp
//
//  Created by Mar Cabrera on 11/11/2019.
//  Copyright © 2019 Mar Cabrera. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    /// Creates a toolbar on top of the keyboard to display buttons of Done and Cancel to dismiss the keyboard
    func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
        let onCancel = onCancel ?? (target: self, action: #selector(cancelButtonTapped))
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))

        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: onCancel.target, action: onCancel.action),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .plain, target: onDone.target, action: onDone.action)
            ]
        toolbar.sizeToFit()

        self.inputAccessoryView = toolbar
    }

    @objc func doneButtonTapped() { self.resignFirstResponder() }
    @objc func cancelButtonTapped() { self.resignFirstResponder() }
}
