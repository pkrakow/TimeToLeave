//
//  LoginViewController.swift
//  TimeToLeave
//
//  Created by Paul Krakow on 3/23/16.
//  Copyright © 2016 Paul Krakow. All rights reserved.
//

import UIKit
import AWSCore

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Initialize the AmazonClientManager
        
        if AmazonClientManager.sharedInstance.isConfigured() {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
            AmazonClientManager.sharedInstance.resumeSession {
                (task) -> AnyObject! in
                dispatch_async(dispatch_get_main_queue()) {
                    
                }
                return nil
            }
        } else {
            let missingConfigAlert = UIAlertController(title: "Missing Configuration", message: "Please check Constants.swift and set appropriate values", preferredStyle: .Alert)
            missingConfigAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(missingConfigAlert, animated: true, completion: nil)
        }
        
        // if AmazonClientManager.sharedInstance.isLoggedIn() {
        if AmazonClientManager.sharedInstance.isLoggedInWithFacebook() {
            
            // Reload FB session to refresh token 
            AmazonClientManager.sharedInstance.reloadFBSession()
            
            // Get the user ID for this user
            //User.sharedInstance!.getUniqueUserID()
            //print("User.sharedInstance.uniqueUserID: ", User.sharedInstance!.uniqueUserID)
            
            // If the user is already logged in, segue to the DestinationTableViewController
            performSegueWithIdentifier("IsLoggedIn", sender: self)
            
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Actions
    @IBAction func loginButton(sender: UIButton) {
        //print("login button test")
        
        AmazonClientManager.sharedInstance.loginFromView(self) {
            (task: AWSTask!) -> AnyObject! in
            dispatch_async(dispatch_get_main_queue()) {
                if AmazonClientManager.sharedInstance.isLoggedInWithFacebook() {                    
                    // If the login was successful, segue to the DestinationTableViewController
                    self.performSegueWithIdentifier("IsLoggedIn", sender: self)
                }

            }
            return nil
        }
        

    }
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
