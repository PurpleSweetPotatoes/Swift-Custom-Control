// *******************************************
//  File Name:      ContactManager.swift       
//  Author:         MrBai
//  Created Date:   2019/9/16 4:33 PM
//    
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************
    

import UIKit
import Contacts
import ContactsUI

struct ContactManager {
    
    static public func requestContacts() -> [CNContact] {
        var models = [CNContact]()
        
        if CNContactStore.authorizationStatus(for: .contacts) != .authorized { return models }
        
        let store = CNContactStore()
        let keys = [CNContactIdentifierKey, CNContactViewController.descriptorForRequiredKeys() ] as! [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch:keys)
        request.sortOrder = .familyName
        
        //遍历所有联系人
        do {
            try store.enumerateContacts(with: request, usingBlock: { (contact : CNContact, stop : UnsafeMutablePointer<ObjCBool>) in
                models.append(contact)
            })
        } catch let error {
            print(error)
        }
        
        return models
    }
    
    static public func addContact(phone: String, name: String? = nil) -> CNContactViewController {
        let contact = CNMutableContact()
        let phoneInfo = CNLabeledValue(label: CNLabelHome, value: CNPhoneNumber(stringValue: phone))
        contact.phoneNumbers = [phoneInfo]
        
        if let na = name {
            contact.familyName = na
        }

        return CNContactViewController(forNewContact: contact)
    }
}
