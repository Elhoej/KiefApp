//
//  ChatLogController.swift
//  KiefApp
//
//  Created by Simon Elhoej Steinmejer on 5/26/17.
//  Copyright © 2017 Simon Elhoej Steinmejer. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    var user: User?
    {
        didSet
        {
            navigationItem.title = user?.username
            observeMessages()
        }
    }
    
    var messages = [Message]()
    var mainTabBarController: MainTabBarController?
    
    let activityIndicatorView: UIActivityIndicatorView =
    {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.color = UIColor.black
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        
        return aiv
    }()
    
    func observeMessages()
    {
        guard let uid = FIRAuth.auth()?.currentUser?.uid, let toId = user?.id else { return }
        
        let userMessageRef = FIRDatabase.database().reference().child("user-messages").child(uid).child(toId)
        
        attemptToReloadTable()
        
        userMessageRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            
            let messagesRef = FIRDatabase.database().reference().child("messages").child(messageId)
            
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
                
                let message = Message(dictionary: dictionary)
                
                if message.toId == FIRAuth.auth()?.currentUser?.uid
                {
                    if message.didRead == "0"
                    {
                        messagesRef.updateChildValues(["didRead": "1"])
                        self.mainTabBarController?.badgeCount -= 1
                        if (self.mainTabBarController?.badgeCount)! < 1
                        {
                            self.mainTabBarController?.tabBar.items?[2].badgeValue = nil
                        }
                        else
                        {
                            self.mainTabBarController?.tabBar.items?[2].badgeValue = String(describing: self.mainTabBarController?.badgeCount)
                        }
                    }
                }
                
                self.messages.append(Message(dictionary: dictionary))
                
                self.attemptToReloadTable()

            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    func attemptToReloadTable()
    {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    var timer: Timer?
    
    func handleReloadTable()
    {
        DispatchQueue.main.async(execute: {
            self.activityIndicatorView.stopAnimating()
            self.collectionView?.reloadData()
            self.inputContainerView.isUserInteractionEnabled = true
            self.setupKeyboardObservers()
            
            if self.messages.count > 0
            {
                let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
            }
        })
    }
    
    let cellId = "cellId"
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        
        self.tabBarController?.tabBar.isHidden = true
        
        navigationController?.isNavigationBarHidden = false
        
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.addSubview(activityIndicatorView)
        activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicatorView.startAnimating()
        
        collectionView?.contentInset = UIEdgeInsetsMake(8, 0, 8, 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
        
        fetchCurrentProfileImageUrl()
    }

    lazy var inputContainerView: ChatInputContainerView =
    {
        let chatInputContainerView = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        chatInputContainerView.chatLogController = self
        return chatInputContainerView
    }()
    
    func handleUploadTap()
    {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? NSURL
        {
            handleSelectedVideo(videoUrl)
        }
        else
        {
            handleSelectedImage(info: info as [String : Any])
        }
        
        dismiss(animated: true, completion: nil)

    }
    
    private func handleSelectedVideo(_ url: NSURL)
    {
        let filename = NSUUID().uuidString + ".mov"
        let uploadTask = FIRStorage.storage().reference().child("message_movies").child(filename).putFile(url as URL, metadata: nil, completion: { (metadata, error) in
            
            if error != nil
            {
                print("Failed to upload video")
                return
            }
            
            if let videoUrl = metadata?.downloadURL()?.absoluteString
            {
                
                if let thumbnailImage = self.thumbnailImageForFileUrl(fileUrl: url)
                {
                    self.uploadToFirebaseStorageUsingImage(thumbnailImage, completion: { (imageUrl) in
                        
                        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": thumbnailImage.size.width as AnyObject, "imageHeight": thumbnailImage.size.height as AnyObject, "videoUrl": videoUrl as AnyObject]
                        
                        self.sendMessageWithProperties(properties: properties)
                    })
                }
            }
        })
        
        uploadTask.observe(.progress) { (snapshot) in
            
            if let completedUnitCount = snapshot.progress?.completedUnitCount
            {
                let totalUnitCount = snapshot.progress?.totalUnitCount
                let byteCountFormatter = ByteCountFormatter()
                byteCountFormatter.allowedUnits = [.useMB]
                byteCountFormatter.countStyle = .file
                self.navigationItem.title = byteCountFormatter.string(fromByteCount: completedUnitCount) + " / " + byteCountFormatter.string(fromByteCount: totalUnitCount!)
            }
        }
        
        uploadTask.observe(.success) { (snapshot) in
            
            self.navigationItem.title = self.user?.username
        }
        
    }
    
    private func thumbnailImageForFileUrl(fileUrl: NSURL) -> UIImage?
    {
        let asset = AVAsset(url: fileUrl as URL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do
        {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        }
        catch let err
        {
            print(err)
        }
        
        return nil
    }
    
    private func handleSelectedImage(info: [String: Any])
    {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage
        {
            selectedImageFromPicker = editedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage
        {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker
        {
            uploadToFirebaseStorageUsingImage(selectedImage, completion: { (imageUrl) in
                
                self.sendMessageWithImageUrl(imageUrl: imageUrl, image: selectedImage)
            })
        }
    }
    
    private func uploadToFirebaseStorageUsingImage(_ image: UIImage, completion: @escaping (_ imageUrl: String) -> ())
    {
        let imageName = NSUUID().uuidString
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2)
        {
            let ref = FIRStorage.storage().reference().child("message_images").child(imageName).put(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil
                {
                    print("Failed to upload image:", error!)
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString
                {
                    completion(imageUrl)
                }
                
            })
            
            ref.observe(.progress) { (snapshot) in
                
                if let completedUnitCount = snapshot.progress?.completedUnitCount
                {
                    let totalUnitCount = snapshot.progress?.totalUnitCount
                    let byteCountFormatter = ByteCountFormatter()
                    byteCountFormatter.allowedUnits = [.useKB]
                    byteCountFormatter.countStyle = .file
                    self.navigationItem.title = byteCountFormatter.string(fromByteCount: completedUnitCount) + " / " + byteCountFormatter.string(fromByteCount: totalUnitCount!)
                }
            }
            
            ref.observe(.success) { (snapshot) in
                
                self.navigationItem.title = self.user?.username
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }
    
    
    override var inputAccessoryView: UIView?
    {
        get
        {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool
    {
        return true
    }
    
    func setupKeyboardObservers()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name:NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    
    func keyboardDidShow(notification:NSNotification)
    {
        if messages.count > 0
        {
            let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
            self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    //To fix memory leak with keyboardDidShow
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        cell.chatLogConroller = self
        
        let message = messages[indexPath.item]
        
        cell.message = message
        
        if let seconds = message.timestamp?.doubleValue
        {
            let timestampDate = Date(timeIntervalSince1970: seconds)
            let currentTime = Int(Date().timeIntervalSince1970)
            let dateFormatter = DateFormatter()

            if currentTime - (message.timestamp?.intValue)! > 86400 && currentTime - (message.timestamp?.intValue)! < 518400
            {
                dateFormatter.dateFormat = "EEE hh:mm a"
                cell.timeStampView.text = dateFormatter.string(from: timestampDate)
            }
            else if currentTime - (message.timestamp?.intValue)! > 518400
            {
                dateFormatter.dateFormat = "dd MMM"
                cell.timeStampView.text = dateFormatter.string(from: timestampDate)
            }
            else
            {
                dateFormatter.dateFormat = "hh:mm a"
                cell.timeStampView.text = dateFormatter.string(from: timestampDate)
            }
        }
        
        cell.textView.text = message.text
        
        setupCell(cell, message)
        
        if let text = message.text
        {
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 20
            cell.textView.isHidden = false
        }
        else if message.imageUrl != nil
        {
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }
        
        cell.playButton.isHidden = message.videoUrl ==  nil
        
        
        return cell
    }
    
    var currentProfileImageUrl: String = ""
    func fetchCurrentProfileImageUrl()
    {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        FIRDatabase.database().reference().child("users").child(uid).child("profileImageUrl").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let profileImageUrl = snapshot.value as? String
            {
                self.currentProfileImageUrl = profileImageUrl
            }
            
        }, withCancel: nil)
    }
    
    private func setupCell(_ cell: ChatMessageCell,_ message: Message)
    {
        
        if message.fromId == FIRAuth.auth()?.currentUser?.uid
        {
            cell.profileImageView.loadImageUsingCacheWithUrlString(currentProfileImageUrl)
        
            //outgoing will be blue
            cell.bubbleView.backgroundColor = UIColor.rgb(red: 0, green: 137, blue: 249)
            cell.textView.textColor = UIColor.white
            cell.profileImageViewRightAnchor?.isActive = true
            cell.profileImageViewLeftAnchor?.isActive = false
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.timestampRightAnchor?.isActive = true
            cell.timestampLeftAnchor?.isActive = false
            cell.timeStampView.textAlignment = .right
            
        }
        else
        {
            if let profileImageUrl = self.user?.profileImageUrl
            {
                cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
            }
            
            //incoming will be grey
            cell.bubbleView.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
            cell.textView.textColor = UIColor.black
            cell.profileImageViewRightAnchor?.isActive = false
            cell.profileImageViewLeftAnchor?.isActive = true
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.timestampRightAnchor?.isActive = false
            cell.timestampLeftAnchor?.isActive = true
            cell.timeStampView.textAlignment = .left
        }
        
        if let messageImageUrl = message.imageUrl
        {
            cell.messageImageView.loadImageUsingCacheWithUrlString(messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
        }
        else
        {
            cell.messageImageView.isHidden = true
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        var height: CGFloat = 80
        let message  = messages[indexPath.item]
        
        if let text = message.text
        {
            height = estimateFrameForText(text: text).height + 33
        }
        else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue
        {
            height = CGFloat(imageHeight / imageWidth * 200) + 13
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    fileprivate func estimateFrameForText(text: String) -> CGRect
    {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16)], context: nil)
    }
    
    func handleSend()
    {
        inputContainerView.sendButton.setTitle("Sending", for: .normal)
        inputContainerView.sendButton.isEnabled = false
        
        let properties =  ["text": inputContainerView.inputTextField.text!]
        sendMessageWithProperties(properties: properties as [String : AnyObject])
    }
    
    private func sendMessageWithImageUrl(imageUrl: String, image: UIImage)
    {
        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": image.size.width as AnyObject, "imageHeight": image.size.height as AnyObject]
        
        sendMessageWithProperties(properties: properties)
    }
    
    private func sendMessageWithProperties(properties: [String: AnyObject])
    {
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let timestamp = Int(Date().timeIntervalSince1970)
        var values: [String: AnyObject] = ["toId": toId, "fromId": fromId, "timestamp": timestamp, "didRead": "0"] as [String : Any] as [String : AnyObject]
        
        properties.forEach({values[$0] = $1})
        
        childRef.updateChildValues(values) { (error, ref) in
            
            if error != nil
            {
                print(error ?? "")
                return
            }
            
            self.inputContainerView.inputTextField.text = nil
            
            let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(fromId).child(toId)
            
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            let recipientUserMessageRef = FIRDatabase.database().reference().child("user-messages").child(toId).child(fromId)
            recipientUserMessageRef.updateChildValues([messageId: 1])
            
            self.composePushNotification(uid: fromId, properties: properties)
            
            self.inputContainerView.sendButton.setTitle("Send", for: .normal)
        }
    }
    
    func composePushNotification(uid: String, properties: [String: AnyObject])
    {
            guard let token = self.user?.fcmToken else { return }
        FIRDatabase.database().reference().child("users").child(uid).child("username").observeSingleEvent(of: .value, with: { (snapshot) in
            
            print(snapshot.value as! String)
            
            var pushTitle: String = ""
            var pushMessage = ""
            
            if let currentUsername = snapshot.value as? String
            {
               pushTitle = currentUsername + " sent you a message"
            }
            else
            {
                pushTitle = "Someone sent you a message"
            }
            
            if let pushText = properties["text"] as? String
            {
                if pushText.characters.count < 50
                {
                    pushMessage = pushText
                }
                else
                {
                    pushMessage = pushText.substring(to: 50) + "..."
                }
            }
            else
            {
                pushMessage = "Sent an image"
            }
            
            self.sendPush(title: pushTitle, message: pushMessage, reciever: token)
            
        }, withCancel: nil)

    }
    
    func sendPush(title: String, message: String, reciever: String)
    {
        if let url = URL(string: "https://fcm.googleapis.com/fcm/send")
        {
            var urlRequest: URLRequest = URLRequest(url: url)
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.addValue("key = AIzaSyCbVQr0hNdhagGAYZ3JmTicNc9FZT8kr_A", forHTTPHeaderField: "Authorization")
            
            let dic: Dictionary<String, Any> =
                [
                    "to" : "\(reciever)",
                    "priority" : "high",
                    "notification" :
                        [
                            "badge" : "1",
                            "sound" : "default",
                            "body" : "\(message)",
                            "title" : "\(title)"
                    ]
            ]
            
            do
            {
                let data = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
                urlRequest.httpBody = data
                urlRequest.httpMethod = "POST"
                print("JSON Object Serialized")
            }
            catch
            {
                print("Couldn't post JSON")
            }
            
            let task = URLSession.shared.dataTask(with: urlRequest, completionHandler:
            {
                data, response, error in
                print("Inside Task")
                if error != nil
                {
                    print("Push" + (error?.localizedDescription)!)
                }
                if response != nil
                {
                    print(response!)
                }
            })
            task.resume()
        }
    }
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    //Image zooming logic
    func performZoomInForStartingImageView(startingImageView: UIImageView)
    {
        self.inputContainerView.inputTextField.resignFirstResponder()
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow
        {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
        
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackBackgroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                
                zoomingImageView.center = keyWindow.center
                
            }, completion: nil)
            
        }
    }
    
    func handleZoomOut(tapGesture: UITapGestureRecognizer)
    {
        if let zoomOutImageView = tapGesture.view
        {
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
                
            }, completion: { (completed: Bool) in
                
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
    }
    
}















