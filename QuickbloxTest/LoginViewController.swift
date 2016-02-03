//
//  LoginViewController.swift
//  QuickbloxTest
//
//  Created by Martin Svensson on 2016-01-28.
//  Copyright © 2016 Spinit. All rights reserved.
//

import Foundation

class LoginViewController : UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userIdTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordTextField.secureTextEntry = true
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        let email = emailTextField.text
        let password = passwordTextField.text
        return email != "" && password != "" && userIdTextField.text != ""
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let email = emailTextField.text
        let password = passwordTextField.text
        let userId = userIdTextField.text
        let next = segue.destinationViewController as! ViewController
        next.email = email
        next.password = password
        next.userId = userId
        self.presentViewController(next, animated: true, completion: nil)
    }
}