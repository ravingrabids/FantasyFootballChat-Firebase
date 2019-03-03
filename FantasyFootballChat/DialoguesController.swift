//
//  DialoguesController.swift
//  FantasyFootballChat
//
//  Created by Андрей Гончаров on 14/03/2018.
//  Copyright © 2018 Goncharov Andrei. All rights reserved.
//

import UIKit
import Firebase

class DialoguesController: UITableViewController {
    
    var dialogues = [Dialogue]()
    var dialouguesDictionary = [String: Dialogue]()
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkForUserLoggedIn()
        setupNavigationItems()
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        tableView.allowsSelectionDuringEditing = true
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // cell editing style
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let uid = Auth.auth().currentUser?.uid
        let dialogue = self.dialogues[indexPath.row]
        Database.database().reference().child("user-dialogues").child(uid!).child(dialogue.chatPartnerId()).removeValue { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            self.dialouguesDictionary.removeValue(forKey: dialogue.chatPartnerId())
            self.attemptReloadTable()
        }
    }
    
    // navigation items
    func setupNavigationItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign out", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.leftBarButtonItem?.tintColor = UIColor(red: 10/255 , green: 80/255, blue: 10/255, alpha: 1)
        let newDialogueImage = UIImage(named: "newDialogue")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: newDialogueImage, style: .plain, target: self, action: #selector(handleNewDialogue))
        navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 10/255 , green: 80/255, blue: 10/255, alpha: 1)
    }
    
    // get dialogues
    func observeUserDialogues() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("user-dialogues").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            let userId = snapshot.key
            Database.database().reference().child("user-dialogues").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                let dialogueId = snapshot.key
                self.fetchDialogueWithDialogueId(dialogueId: dialogueId)
                }, withCancel: nil)
            }, withCancel: nil)
        ref.observe(.childRemoved, with: { (snapshot) in
            self.dialouguesDictionary.removeValue(forKey: snapshot.key)
            self.attemptReloadTable()
        }, withCancel: nil)
    }

    // fetch dialogue (with dialogueId)
    private func fetchDialogueWithDialogueId(dialogueId: String) {
        let dialoguesReference = Database.database().reference().child("messages").child(dialogueId)
        dialoguesReference.observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                let dialogue = Dialogue(dictionary: value as! [String : AnyObject])
                let chatPartnerId = dialogue.chatPartnerId()
                self.dialouguesDictionary[chatPartnerId] = dialogue
                self.attemptReloadTable()
            }
        }, withCancel: nil)
    }
    
    var timer: Timer?
    
    private func attemptReloadTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    @objc func handleReloadTable() {
        self.dialogues = Array(self.dialouguesDictionary.values)
        self.dialogues.sort(by: { (dialogue1, dialogue2) -> Bool in
            return dialogue1.timestamp!.intValue > dialogue2.timestamp!.intValue
        })
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
        
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dialogues.count
    }
    
    // custom cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let dialogue = dialogues[indexPath.row]
        cell.dialogue = dialogue
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    // cell selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dialogue = dialogues[indexPath.row]
        let chatPartnerId = dialogue.chatPartnerId()
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? [String: AnyObject] {
                    let user = User()
                    let id = chatPartnerId
                    let name = value["Name"] as? String ?? "Name not found"
                    let email = value["Email"] as? String ?? "Email not found"
                    let profileImageUrl = value["ProfileImageUrl"] as? String ?? "ProfileImageUrl not found"
                    user.name = name
                    user.email = email
                    user.profileImageUrl = profileImageUrl
                    user.id = id
                self.handleShowChatControllerForUser(user: user)
            }
        }, withCancel: nil)
    }
    
    // add new dialogue
    @objc func handleNewDialogue() {
        let newDialogueController = NewDialogueController()
        newDialogueController.dialoguesController = self
        let navigationController =  UINavigationController(rootViewController: newDialogueController)
        present(navigationController, animated: true, completion: nil)
    }

    // if user  isn't log in
    func checkForUserLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
            }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                let name = dictionary["Name"] as? String ?? "Name not found"
                user.name = name
                self.setupNavBarWithUser(user: user)
                }
            }, withCancel: nil)
    }
    
    // chat for user control
    @objc func handleShowChatControllerForUser(user: User) {
        let chatController = ChatController(collectionViewLayout: UICollectionViewFlowLayout())
        chatController.user = user
        navigationController?.pushViewController(chatController, animated: true)
    }
    
    // logout proccess
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        let loginController = LoginController()
        loginController.dialoguesController = self
        present(loginController, animated: true, completion: nil)
    }
    
    func setupNavBarWithUser(user: User) {
        dialogues.removeAll()
        dialouguesDictionary.removeAll()
        tableView.reloadData()
        observeUserDialogues()
        
        self.navigationItem.title = user.name
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
       
        let nameLabel = UILabel()
        nameLabel.text = user.name
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(nameLabel)
        
        //constraints
        nameLabel.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: titleView.heightAnchor).isActive = true
        nameLabel.widthAnchor.constraint(equalTo: titleView.widthAnchor).isActive = true
        
        let nameTitleButton = UIButton()
        nameTitleButton.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(nameTitleButton)
        
        // constraints
        nameTitleButton.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        nameTitleButton.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        nameTitleButton.heightAnchor.constraint(equalTo: titleView.heightAnchor).isActive = true
        nameTitleButton.widthAnchor.constraint(equalTo: titleView.widthAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

