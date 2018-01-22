//
//  ChatVC.swift
//  ComCard
//
//  Created by Pragun Sharma on 1/21/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit

class ChatVC: UIViewController, UINavigationBarDelegate {

    @IBOutlet weak var navbar: UINavigationBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        navbar.delegate = self
        navbar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.darkGray]
        navbar.barTintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.6)
        navbar.setTitleVerticalPositionAdjustment(9, for: .default)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
