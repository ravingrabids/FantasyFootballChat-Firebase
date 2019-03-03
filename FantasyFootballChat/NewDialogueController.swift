//
//  NewDialogueController.swift
//  FantasyFootballChat
//
//  Created by Андрей Гончаров on 14/03/2018.
//  Copyright © 2018 Goncharov Andrei. All rights reserved.
//

import UIKit
import Firebase

class NewDialogueController: UITableViewController {
    
    let cellId = "cellId"
    var users = [User]()
    let userCell = UserCell()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 10/255 , green: 80/255, blue: 10/255, alpha: 1)
        fetchUsers()
    }
    
    // get users
    func fetchUsers() {
        let rootRef = Database.database().reference()
        let query = rootRef.child("users").queryOrdered(byChild: "Name")
        query.observe(.value) { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                if let value = child.value as? NSDictionary {
                    let user = User()
                    let id = child.key
                    let name = value["Name"] as? String ?? "Name not found"
                    let email = value["Email"] as? String ?? "Email not found"
                    let profileImageUrl = value["ProfileImageUrl"] as? String ?? "ProfileImageUrl not found"
                    user.name = name
                    user.email = email
                    user.profileImageUrl = profileImageUrl
                    user.id = id
                    self.users.append(user)
                    DispatchQueue.main.async { self.tableView.reloadData() }
                    }
                }
            }
        }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    // custom cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let user = users[indexPath.row]
        
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        if let profileImageUrl = user.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithURLString(urlString: profileImageUrl)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    var dialoguesController: DialoguesController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.dialoguesController?.handleShowChatControllerForUser(user: user)
        }
    }
    
    
}


