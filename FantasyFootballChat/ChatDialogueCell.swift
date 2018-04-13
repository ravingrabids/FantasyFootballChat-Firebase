//
//  ChatDialogueCell.swift
//  FantasyFootballChat
//
//  Created by Андрей Гончаров on 26/03/2018.
//  Copyright © 2018 Goncharov Andrei. All rights reserved.
//

import UIKit
import AVFoundation

class ChatDialogueCell: UICollectionViewCell {
    
    var chatConroller: ChatController?
    var dialogue: Dialogue?
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    let zoomButton: UIButton = {
        let zoom = UIButton()
        zoom.translatesAutoresizingMaskIntoConstraints = false
        zoom.addTarget(self, action: #selector(handleZoom), for: .touchUpInside)
        return zoom
    }()
    
    let playButton: UIButton = {
        let play = UIButton()
        let image = UIImage(named: "playButton")
        play.setImage(image, for: .normal)
        play.layer.masksToBounds = true
        play.translatesAutoresizingMaskIntoConstraints = false
        play.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        return play
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.backgroundColor = UIColor.clear
        tv.textColor = UIColor.white
        tv.isEditable = false
        return tv
        }()
    
    let profileImageView: UIImageView = {
        let profileImage = UIImageView()
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        profileImage.layer.cornerRadius = 16
        profileImage.layer.masksToBounds = true
        profileImage.contentMode = .scaleAspectFill
        return profileImage
    }()
    
    let bubbleView: UIView = {
        let bubble = UIView()
        bubble.backgroundColor = UIColor(red: 10/255 , green: 80/255, blue: 10/255, alpha: 1)
        bubble.translatesAutoresizingMaskIntoConstraints = false
        bubble.layer.cornerRadius = 16
        bubble.layer.masksToBounds = true
        return bubble
        }()
    
    let messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleZoomTap))
        tapGesture.numberOfTapsRequired = 1
        return imageView
    }()
    
    @objc func handleZoomTap(tapGesture: UITapGestureRecognizer) {
        if dialogue?.videoUrl != nil {
            return
        }
        if let imageView = tapGesture.view as? UIImageView {
            self.chatConroller?.performZoomInForStartImageView(startImageView: imageView)
        }
    }
    
    @objc func handleZoom() {
        if let imageView = bubbleView as? UIImageView {
        self.chatConroller?.performZoomInForStartImageView(startImageView: imageView)
        }
    }
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    @objc func handlePlay() {
        if let videoUrlString = dialogue?.videoUrl {
            let url = NSURL(string: videoUrlString)
            player = AVPlayer(url: url! as URL)
            playerLayer = AVPlayerLayer(layer: player!)
            playerLayer?.frame = bubbleView.bounds
            bubbleView.layer.addSublayer(playerLayer!)
            player?.play()
            activityIndicatorView.startAnimating()
            playButton.isHidden = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        activityIndicatorView.stopAnimating()
    }
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleRightAnchor: NSLayoutConstraint?
    var bubbleLeftAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)

        bubbleView.addSubview(messageImageView)

        // constraints
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        
        bubbleView.addSubview(zoomButton)

        // constraints
        zoomButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        zoomButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        zoomButton.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        zoomButton.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
       
        bubbleView.addSubview(playButton)

        // constraints
        playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        bubbleView.addSubview(activityIndicatorView)
        
        // constraints
        activityIndicatorView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // constraints
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        // constraints
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 10).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -10).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        // constraints
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        bubbleRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10)
        bubbleRightAnchor?.isActive = true
        bubbleLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10)
        bubbleLeftAnchor?.isActive = false 
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Fatal error with init")
        }
    
    
}

