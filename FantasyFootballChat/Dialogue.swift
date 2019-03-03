//
//  Dialogue.swift
//  FantasyFootballChat
//
//  Created by Андрей Гончаров on 22/03/2018.
//  Copyright © 2018 Goncharov Andrei. All rights reserved.
//

import UIKit
import Firebase

class Dialogue: NSObject {
    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
    var imageUrl: String?
    var imageHeight: NSNumber?
    var imageWidth: NSNumber?
    var videoUrl: String?
    
    // get Id of user, sender or reciever
    func chatPartnerId() -> String {
        if fromId == Auth.auth().currentUser?.uid {
            return toId!
        } else {
            return fromId!
            }
    }
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        fromId = dictionary["fromId"] as? String
        text = dictionary["text"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
        toId = dictionary["toId"] as? String
        imageUrl = dictionary["imageUrl"] as? String
        imageHeight = dictionary["imageHeight"] as? NSNumber
        imageWidth = dictionary["imageWidth"] as? NSNumber
        videoUrl = dictionary["videoUrl"] as? String
    }
}
