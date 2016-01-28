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
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userIdTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        let username = usernameTextField.text
        let password = passwordTextField.text
        return username != "" && password != "" && userIdTextField.text != ""
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let username = usernameTextField.text
        let password = passwordTextField.text
        let userId = userIdTextField.text
        let next = segue.destinationViewController as! ViewController
        next.username = username
        next.password = password
        next.userId = userId
        self.presentViewController(next, animated: true, completion: nil)
    }
}