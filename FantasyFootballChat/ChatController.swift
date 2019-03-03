//
//  ChatController.swift
//  FantasyFootballChat
//
//  Created by Андрей Гончаров on 14/03/2018.
//  Copyright © 2018 Goncharov Andrei. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class ChatController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            observeMessages()
            }
        }
    
    var dialogues = [Dialogue]()
    
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.id else {
            return
            }
        let userMessagesRef = Database.database().reference().child("user-dialogues").child(uid).child(toId)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messagesRef = Database.database().reference().child("messages").child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let value = snapshot.value as? NSDictionary {
                    self.dialogues.append(Dialogue(dictionary: value as! [String : AnyObject]))
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                        let indexPath = NSIndexPath(item: self.dialogues.count - 1 , section: 0)
                        self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
                }
            }
                }, withCancel: nil)
            }, withCancel: nil)
    }

    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBackBarButton))
        navigationItem.leftBarButtonItem?.tintColor = UIColor(red: 10/255 , green: 80/255, blue: 10/255, alpha: 1)
        collectionView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatDialogueCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive
    }
    
    lazy var inputContainerView: ChatInputContainerView = {
        let chatInputContainerView = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        chatInputContainerView.chatController = self
        return chatInputContainerView
    }()
    
    // load image
    @objc func handleUploadImage() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
            // video selected
            handeVideoSelectedForUrl(url: videoUrl as NSURL)
        } else {
            // image selected
            handleImageSelectedForInfo(info: info as [String : AnyObject])
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // video URL selected
    private func handeVideoSelectedForUrl(url: NSURL) {
        let fileName = NSUUID().uuidString + ".mov"
        let uploadTask = Storage.storage().reference().child("message-movies").child(fileName).putFile(from: url as URL, metadata: nil, completion: { (metadata, error) in
            if error != nil {
                print("Failed to upload", error!)
                return
            }
            if let videoUrl = metadata?.downloadURL()?.absoluteString {
                if let thumbnailImage = self.thumbnailImageForFileUrl(fileUrl: url) {
                    self.uploadToFirebaseStorageUsingImage(image: thumbnailImage, completion: { (imageUrl) in
                        let properties = ["imageUrl": imageUrl, "imageWidth": thumbnailImage.size.width, "imageHeight": thumbnailImage.size.height, "videoUrl": videoUrl] as [String : AnyObject]
                    self.sendMessageWithProperties(properties: properties)
                    })
                }
            }
        })
        uploadTask.observe(.progress) { (snapshot) in
            if let completedUnitCount = snapshot.progress?.completedUnitCount {
                self.navigationItem.title = String(completedUnitCount) + " Bytes"
            }
        }
        uploadTask.observe(.success) { (snapshot) in
            self.navigationItem.title = self.user?.name
        }
    }
    
    private func thumbnailImageForFileUrl(fileUrl: NSURL) -> UIImage? {
        let asset = AVAsset(url: fileUrl as URL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
 
        } catch let err {
            print(err)
        }
        return nil
    }
    
    // image selected
    private func handleImageSelectedForInfo(info: [String:AnyObject]) {
        var selectedFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as! UIImage? {
            selectedFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as! UIImage? {
            selectedFromPicker = originalImage
        }
        if let selectedImage = selectedFromPicker {
            uploadToFirebaseStorageUsingImage(image: selectedImage, completion: { (imageUrl) in
                self.sendMessageWithImageUrl(imageUrl: imageUrl, image: selectedImage)
            })
        }
    }
    
    // send image to Firebase
    private func uploadToFirebaseStorageUsingImage(image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print("Failed to upload image", error!)
                    return
                }
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    completion(imageUrl)
                }
            })
        }
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
            }
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: .UIKeyboardDidShow, object: nil)
    }
    
    @objc func handleKeyboardDidShow(notification: Notification) {
        if dialogues.count > 0 {
        let indexPath = NSIndexPath(item: dialogues.count - 1, section: 0)
        collectionView?.scrollToItem(at: indexPath as IndexPath, at: .top, animated: true)
        }
    }
    
    // keyboard hide
    @objc func handleKeyboardWillHide(notification: Notification) {
        containerViewBottomAnchor?.constant = 0
    }
    
    @objc func handleKeyboardWillShow(notification: Notification) {
        if let keyboardFrame = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            containerViewBottomAnchor?.constant = -keyboardFrame.height
            let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
            UIView.animate(withDuration: keyboardDuration!, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dialogues.count
    }
    
    // custom cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatDialogueCell
        cell.chatConroller = self
        
        let dialogue = dialogues[indexPath.item]
        cell.dialogue = dialogue
        cell.textView.text = dialogues[indexPath.item].text
        
        setupCell(cell: cell, dialogue: dialogue)
        
        if let text = dialogue.text {
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
            cell.textView.isHidden = false
        } else if dialogue.imageUrl != nil {
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }
        if dialogue.videoUrl != nil {
            cell.playButton.isHidden = false
        } else {
            cell.playButton.isHidden = true
        }
        if dialogue.imageUrl != nil {
            cell.zoomButton.isHidden = false
        } else {
            cell.zoomButton.isHidden = true
        }
    
        return cell
    }
    
    // cell setup
    private func setupCell(cell: ChatDialogueCell, dialogue: Dialogue) {
        if let profileImageUrl = self.user?.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithURLString(urlString: profileImageUrl)
        }
        
        if dialogue.fromId == Auth.auth().currentUser?.uid { 
            cell.bubbleView.backgroundColor = UIColor(red: 10/255 , green: 80/255, blue: 10/255, alpha: 1)
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true
            cell.bubbleRightAnchor?.isActive = true
            cell.bubbleLeftAnchor?.isActive = false
        } else {
            cell.bubbleView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = false
            cell.bubbleRightAnchor?.isActive = false
            cell.bubbleLeftAnchor?.isActive = true
        }
     
        if let dialougeImageUrl = dialogue.imageUrl {
            cell.messageImageView.loadImageUsingCacheWithURLString(urlString: dialougeImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
        } else {
            cell.messageImageView.isHidden = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        let dialogue = dialogues[indexPath.item]
        if let text = dialogue.text {
            height = estimateFrameForText(text: text).height + 20
        } else if dialogue.imageUrl != nil {
            let imageWidth = dialogue.imageWidth?.floatValue
            let imageHeight = dialogue.imageHeight?.floatValue
            // h1 = h2 / w1 * w2
            height = CGFloat(imageHeight! / imageWidth! * 200)
        }
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    // estimate size for text frame
    private func estimateFrameForText(text: String) -> CGRect {
        return NSString(string: text).boundingRect(with: CGSize(width: 200, height: 1000 ), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    @objc func handleBackBarButton() {
        let dialoguesController = DialoguesController()
        navigationController?.pushViewController(dialoguesController, animated: true)
    }
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    // send message
    @objc func handleSend() {
        let properties = ["text": inputContainerView.inputTextField.text!] as [String : AnyObject]
        sendMessageWithProperties(properties: properties)
    }
    
    private func sendMessageWithImageUrl(imageUrl: String, image: UIImage) {
        let properties = ["imageUrl": imageUrl, "imageWidth": image.size.width, "imageHeight": image.size.height] as [String : AnyObject]
        sendMessageWithProperties(properties: properties)
    }
    
    // send message setup
    private func sendMessageWithProperties(properties: [String:AnyObject]) {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timestamp = NSDate().timeIntervalSince1970
        var values = ["toId": toId, "fromId": fromId, "timestamp": timestamp] as [String : Any]
        properties.forEach({values[$0] = $1})
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            
            self.inputContainerView.inputTextField.text = nil
            
            let userDialoguesRef = Database.database().reference().child("user-dialogues").child(fromId).child(toId)
            let dialogueId = childRef.key
            userDialoguesRef.updateChildValues([dialogueId: 1])
            
            let recipientUserDialoguesRef = Database.database().reference().child("user-dialogues").child(toId).child(fromId)
            recipientUserDialoguesRef.updateChildValues([dialogueId: 1])
        }
    }
    
    var startingFrame: CGRect?
    var blackBackGroundView: UIView?
    var startingImageView: UIImageView?
    
    // zoomIn for start chat view
    func performZoomInForStartImageView(startImageView: UIImageView) {
        self.startingImageView = startImageView
        self.startingImageView?.isHidden = true
        startingFrame = startImageView.superview?.convert(startImageView.frame, to: nil)
        let zoomImageView = UIImageView(frame: startingFrame!)
        
        zoomImageView.backgroundColor = UIColor.black
        zoomImageView.image = startImageView.image
        zoomImageView.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(performZoomOut)))
        zoomImageView.isUserInteractionEnabled = true
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackGroundView = UIView(frame: keyWindow.frame)
            blackBackGroundView?.backgroundColor = UIColor.black
            blackBackGroundView?.alpha = 0
            keyWindow.addSubview(blackBackGroundView!)
            keyWindow.addSubview(zoomImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackBackGroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                zoomImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomImageView.center = keyWindow.center
            }, completion: { (completed: Bool) in
            })
        }
    }
    
    // zoomOut for chat view
    @objc func performZoomOut(tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view as? UIImageView {
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.layer.masksToBounds = true
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackGroundView?.alpha = 0
                self.inputContainerView.alpha = 1
            }, completion: { (completed: Bool) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
    }
}



