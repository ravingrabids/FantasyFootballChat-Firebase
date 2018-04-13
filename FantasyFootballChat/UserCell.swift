//
//  UserCell.swift
//  FantasyFootballChat
//
//  Created by Андрей Гончаров on 26/03/2018.
//  Copyright © 2018 Goncharov Andrei. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    var dialogue: Dialogue? {
        didSet {
            setupNameAndProfileImage()
            detailTextLabel?.text = dialogue?.text
            if let seconds = dialogue?.timestamp?.doubleValue {
                let timestampDate = NSDate(timeIntervalSince1970: seconds)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                timeLabel.text = dateFormatter.string(from: timestampDate as Date)
                }
            }
        }
    
    private func setupNameAndProfileImage() {
        if let id = dialogue?.chatPartnerId() {
            let ref = Database.database().reference().child("users").child(id)
            ref.observe(.value, with: { (snapshot) in
                if let value = snapshot.value as? [String: AnyObject] {
                    let textName = value["Name"] as? String ?? "name not found"
                    if let profileImageUrl = value["ProfileImageUrl"] as? String {
                        self.profileImageView.loadImageUsingCacheWithURLString(urlString: profileImageUrl)
                    }
                    self.textLabel?.text = textName
                    }
                }, withCancel: nil)
            }
        }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 56, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 56, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
        }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
        }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        // label.text = "HH.MM.SS"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
        }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        // constraints
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 2).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        // constraints
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: textLabel!.heightAnchor).isActive = true
        }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        }
    }
