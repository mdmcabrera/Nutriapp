//
//  ViewController.swift
//  NutriApp
//
//  Created by Mar Cabrera on 25/09/2019.
//  Copyright © 2019 Mar Cabrera. All rights reserved.
//

import UIKit
import AuthenticationServices
import MaterialComponents.MaterialButtons

class LoginViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var mainScreenButton: UIButton!
    
    //MARK: - Properties
    var userCredentials = ""
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppleSignInButton()
        view.setGradientBackground(colorOne: UIColor(red:0.74, green:0.76, blue:0.78, alpha:1.0), colorTwo: UIColor(red:0.17, green:0.24, blue:0.31, alpha:1.0))
    }

    override func viewDidAppear(_ animated: Bool) {

        if SessionManager.isUserLoggedIn() == true {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "SettingsTableViewController") as! SettingsTableViewController
            self.present(newViewController, animated: true, completion: nil)
        }
    }

    func setupAppleSignInButton() {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(appleIDButtonTapped), for: .touchUpInside)
        self.view.addSubview(button)

        button.centerXAnchor.constraint(equalToSystemSpacingAfter: view.centerXAnchor, multiplier: 1.0).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 40).isActive = true
        button.widthAnchor.constraint(equalToConstant: 200).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.cornerRadius = 8
    }

    @objc func appleIDButtonTapped() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    @IBAction func mainViewButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "mainViewSegue", sender: self)
    }
}

//MARK: - Apple Sign In Delegate
extension LoginViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization){
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {

            let dataToken = credential.identityToken!
            let stringToken = String(data: dataToken, encoding: String.Encoding.utf8)!

            SessionManager.setCurrentLoginID(stringToken)

            performSegue(withIdentifier: SegueIdentifiers.signInWithApple, sender: self)
        }
    }

    // Error
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error){
        // TODO: Implement error handling
        print("Something bad happened", error.localizedDescription)
    }

}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {

    // Which window whe're working with
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }


}

