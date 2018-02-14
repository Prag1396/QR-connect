//
//  ContactsInviteVC.swift
//  ComCard
//
//  Created by Pragun Sharma on 2/13/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit
import Contacts
import MessageUI

class ContactsInviteVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var mytableview: UITableView!
    
    var store = CNContactStore()
    var contactArray = [ContactStruct]()
    var filteredcontactArray = [ContactStruct]()
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        mytableview.delegate = self
        mytableview.dataSource = self
        searchbar.delegate = self
        searchbar.keyboardAppearance = .dark
        mytableview.tableFooterView = UIView()
        setUpTableInfo()
        // Do any additional setup after loading the view.
    }
    
    @objc func backgroundTapped() {
        view.endEditing(true)
    }

    func setUpTableInfo() {
        
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        
        do {
            try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointerIfYouWantToStopEnumerating) in
               let name = contact.givenName
               let familyName = contact.familyName
               let phoneNumber = contact.phoneNumbers.first?.value.stringValue ?? String()
                
                let contactToAppend = ContactStruct(givenName: name , familyName: familyName, phoneNumber: phoneNumber)
                self.contactArray.append(contactToAppend)
                self.contactArray.sort(by: { (contactname1, contactname2) -> Bool in
                    return contactname1.givenName < contactname2.givenName
                })
                
            })
            DispatchQueue.main.async {
                self.mytableview.reloadData()
            }
        } catch let err {
            print(err.localizedDescription)
        }
        
    }
    
    
    @IBAction func backbtnpressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
               self.dismiss(animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearching == true {
            return filteredcontactArray.count
        }
        return contactArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactcell", for: indexPath) as! ContacCell
        
        var contactToDisplay: ContactStruct!
        
        if isSearching == true {
            contactToDisplay = filteredcontactArray[indexPath.row]
        } else {
            contactToDisplay = contactArray[indexPath.row]
        }
        
        cell.updateUI(contact: contactToDisplay)
        
        return cell
    }
    
    @IBAction func didpressInvite(_ sender: Any) {
        if let cell = (sender as AnyObject).superview??.superview as? ContacCell {
            if let indexPath = mytableview.indexPath(for: cell) {
                if isSearching == true {
                    self.sendInvite(contact: filteredcontactArray[indexPath.row])
                } else {
                    self.sendInvite(contact: contactArray[indexPath.row])
                }
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchbar.text == nil || searchbar.text?.isEmpty == true {
            isSearching = false
            view.endEditing(true)
            
        } else {
            isSearching = true
            filteredcontactArray = contactArray.filter({$0.givenName.range(of: searchText) != nil})
        }
        DispatchQueue.main.async {
            self.mytableview.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            self.mytableview.reloadData()
        }
        searchBar.resignFirstResponder()
    }

    func sendInvite(contact: ContactStruct) {
        if MFMessageComposeViewController.canSendText() {
            let message: MFMessageComposeViewController = MFMessageComposeViewController()
            message.messageComposeDelegate = self
            message.recipients = [contact.phoneNumber]
            message.body = "Hi, I highly reccomend using QRConnect. QRConnect significantly reduces the chances of you losing your precious belongings."
            self.present(message, animated: true, completion: nil)
        } else {
            
            let alert = UIAlertController(title: "WARNING", message: "Your device does not have the ability to send text messages", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
