//
//  SessionManager.swift
//  NutriApp
//
//  Created by Mar Cabrera on 02/10/2019.
//  Copyright © 2019 Mar Cabrera. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

/**
 Class that helps with login functionality related to Keychain Services. 
 */
class SessionManager {

    /// sets user token
    class func setCurrentLoginID(_ struserToken: String) {
        let saveSuccessful: Bool = KeychainWrapper.standard.set(struserToken, forKey: "userToken")
        print("Save was successful: \(saveSuccessful)")
    }

    /// checks if user is logged in
    class func isUserLoggedIn() -> Bool {

        guard let str = KeychainWrapper.standard.string(forKey: "userToken") else {
            return false
        }
        return str.count > 0 ? true: false

    }

    /// gets the token of the user
    class func loggedUserId() -> String {

        let retrievedToken: String? = KeychainWrapper.standard.string(forKey: "userToken")
        print("Retrieved password is: \(retrievedToken)")

        return retrievedToken == nil ? "": retrievedToken!
    }

    class func logout() {
        let removeSuyccessful: Bool = KeychainWrapper.standard.removeObject(forKey: "userToken")
        print("Remove was successful: \(removeSuyccessful)")
    }
}
