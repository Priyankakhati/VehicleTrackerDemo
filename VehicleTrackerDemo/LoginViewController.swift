//
//  LoginViewController.swift
//  VehicleTrackerDemo
//
//  Created by Drivool on 3/22/17.
//  Copyright © 2017 Drivool. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var edtGAPN: UITextField!
    static let PREF_GAPN = "pref_gapn"
    let defaults = UserDefaults.standard
    @IBAction func btnConnectGAPN(_ sender: UIButton) {
         performConnect()
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        edtGAPN?.text = defaults.string(forKey: LoginViewController.PREF_GAPN)
        edtGAPN.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //textField code
        textField.resignFirstResponder()  //if desired
        performConnect()
        return true
    }
    
    func performConnect() {
        
        print ("btnConnect clicked");
        
        let vctrlVehicleTracker = self.storyboard?.instantiateViewController(withIdentifier: "vehicle_tracker") as! ViewController
        
        // Set "Hello World" as a value to myStringValue
        defaults.set((edtGAPN?.text)!, forKey: LoginViewController.PREF_GAPN)
        if(edtGAPN?.text?.isEmpty)!{
             vctrlVehicleTracker.mstrGAPN = "mum-intel-camp"
        }else{
            vctrlVehicleTracker.mstrGAPN = (edtGAPN?.text)!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        
        // Take user to SecondViewController
        self.navigationController?.pushViewController(vctrlVehicleTracker, animated: true)
        //performSegue(withIdentifier: "vehicle_tracker", sender: sender)
    }
    

}
