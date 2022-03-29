// *******************************************
//  File Name:      ContactManager.swift
//  Author:         MrBai
//  Created Date:   2019/9/16 4:33 PM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************

import Contacts
import ContactsUI
import UIKit

struct ContactManager {
    public static func requestContacts() -> [CNContact] {
        var models = [CNContact]()

        if CNContactStore.authorizationStatus(for: .contacts) != .authorized { return models }

        let store = CNContactStore()
        let keys = [CNContactIdentifierKey, CNContactViewController.descriptorForRequiredKeys()] as! [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys)
        request.sortOrder = .familyName

        // 遍历所有联系人
        do {
            try store.enumerateContacts(with: request, usingBlock: { (contact: CNContact, _: UnsafeMutablePointer<ObjCBool>) in
                models.append(contact)
            })
        } catch {
            print(error)
        }

        return models
    }

    public static func addContact(phone: String, name: String? = nil) -> CNContactViewController {
        let contact = CNMutableContact()
        let phoneInfo = CNLabeledValue(label: CNLabelHome, value: CNPhoneNumber(stringValue: phone))
        contact.phoneNumbers = [phoneInfo]

        if let na = name {
            contact.familyName = na
        }

        return CNContactViewController(forNewContact: contact)
    }
}
