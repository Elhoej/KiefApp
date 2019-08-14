//
//  StatusController.swift
//  KiefApp
//
//  Created by Simon Elhoej Steinmejer on 4/25/17.
//  Copyright © 2017 Simon Elhoej Steinmejer. All rights reserved.
//

import UIKit
import Firebase

class StatusController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout
{
    let cellId = "cellId"
    let headerId = "headerId"
    var header: HeaderContainerView?
    var mainTabBarController: MainTabBarController?
    var users = [User]()
    var user: User?
    var activities = [Activity]()
    var activitiesDictionary = [String: Activity]()
    var checkTimer = Timer()
    var hammerTimer = Timer()
    var closeTime: Int?
    var timer: Timer?
    
    let activityIndicatorView: UIActivityIndicatorView =
    {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        
        return aiv
    }()
    
    func observeNotifications()
    {
        let ref = FIRDatabase.database().reference().child("activities")
        
        attemptReloadOfTable()
        
        ref.observe(.childAdded, with: { (snapshot) in
    
            if let dictionary = snapshot.value as? [String: AnyObject]
            {
                let activity = Activity(dictionary: dictionary)
                self.activitiesDictionary[activity.id!] = activity
                self.attemptReloadOfTable()
            }
                    
        }, withCancel: nil)
        
        ref.observe(.childChanged, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]
            {
                let activity = Activity(dictionary: dictionary)
                self.activitiesDictionary.updateValue(activity, forKey: snapshot.key)
                
                self.attemptReloadOfTable()
            }
            
        }, withCancel: nil)
        
        ref.observe(.childRemoved, with: { (snapshot) in
            
            self.activitiesDictionary.removeValue(forKey: snapshot.key)
            
            self.attemptReloadOfTable()
 
        }, withCancel: nil)
    }
    
    private func attemptReloadOfTable()
    {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    func handleReloadTable()
    {
        self.activities = Array(self.activitiesDictionary.values)
        
        self.activities.sort { (activity1, activity2) -> Bool in
            
            return (activity1.timestamp?.int32Value)! > (activity2.timestamp?.int32Value)!
        }
        
        DispatchQueue.main.async(execute:
        {
            self.activityIndicatorView.stopAnimating()
            self.collectionView?.reloadData()
        })
    }

    override func viewWillAppear(_ animated: Bool)
    {
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        viewWillAppear(false)
        
        setupBackground()
        
        view.addSubview(activityIndicatorView)
        activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicatorView.startAnimating()

        collectionView?.backgroundColor = UIColor.clear
        collectionView?.contentInset = UIEdgeInsetsMake(-20, 0, 8, 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(120, 0, 0, 0)
        collectionView?.register(ActivityCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(HeaderContainerView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        
        let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        
        collectionView?.alwaysBounceVertical = true
        
        fetchUsername()
    
        observeNotifications()
        
        fetchInitialButtonStatus()
        
        observeButtons()
        
        let gestureRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight))
        gestureRight.direction = UISwipeGestureRecognizerDirection.right
        view.addGestureRecognizer(gestureRight)
        
        let gestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft))
        gestureLeft.direction = UISwipeGestureRecognizerDirection.left
        view.addGestureRecognizer(gestureLeft)
    }
    
    func handleSwipeRight(sender: UISwipeGestureRecognizer)
    {
        mainTabBarController?.selectedIndex -= 1
    }
    
    func handleSwipeLeft(sender: UISwipeGestureRecognizer)
    {
        mainTabBarController?.selectedIndex += 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! HeaderContainerView
        
        header.statusController = self
        self.header = header
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        let width = view.frame.width
        
        return CGSize(width: width, height: 150)
    }
    
    func setupBackground()
    {
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "baggrund")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        view.backgroundColor = UIColor(patternImage: image)
    }
    
    func fetchUsername()
    {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot.value ?? "")
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            self.user = User(dictionary: dictionary)
            
        }) { (err) in
            print("Failed to fetch user:", err)
        }
    }
    
    func fetchInitialButtonStatus()
    {
        FIRDatabase.database().reference().child("button").child("shabazz").observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.handleButtonLogic(snapshot: snapshot)
            
        }, withCancel: nil)
        
        FIRDatabase.database().reference().child("button").child("nn").observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.handleButtonLogic(snapshot: snapshot)
            
        }, withCancel: nil)
    }
    
    func observeButtons()
    {
        FIRDatabase.database().reference().child("button").observe(.childChanged, with: { (snapshot) in
            
            self.handleButtonLogic(snapshot: snapshot)
            
        }, withCancel: nil)
    }
    
    func handleButtonLogic(snapshot: FIRDataSnapshot)
    {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        let button = snapshot.key
        let yayOrNay = snapshot.value as! Bool
        
        if button == "shabazz"
        {
            if yayOrNay == false
            {
                //close
                self.header?.openTimer.text = "Closed"
                self.header?.shabazzButton.setImage(#imageLiteral(resourceName: "kaffeUdenDamp").withRenderingMode(.alwaysOriginal), for: .normal)
                self.header?.shabazzButton.isEnabled = false
                
                FIRDatabase.database().reference().child("users").child(uid).child("jokke").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    let jokke = snapshot.value as! Bool
                    
                    if jokke == true
                    {
                        self.header?.shabazzButton.removeTarget(self, action: #selector(self.handleShabazzNotification), for: .touchUpInside)
                        self.header?.shabazzButton.isEnabled = true
                        self.header?.shabazzButton.addTarget(self, action: #selector(self.handleJokke), for: .touchUpInside)
                        return
                    }
                    else
                    {
                        return
                    }
                    
                }, withCancel: nil)
            }
            else if yayOrNay == true
            {
                //open
                self.header?.shabazzButton.setImage(#imageLiteral(resourceName: "kaffeMedDamp").withRenderingMode(.alwaysOriginal), for: .normal)
                self.header?.shabazzButton.isEnabled = true
                
                self.header?.shabazzButton.removeTarget(self, action: #selector(self.handleJokke), for: .touchUpInside)
                self.header?.shabazzButton.addTarget(self, action: #selector(self.handleShabazzNotification), for: .touchUpInside)
                
                FIRDatabase.database().reference().child("timer").child("closetime").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    self.closeTime = snapshot.value as? Int
                    if let seconds = snapshot.value
                    {
                        let timestampDate = Date(timeIntervalSince1970: seconds as! TimeInterval)
                        let dateFormatter = DateFormatter()
                    
                        dateFormatter.dateFormat = "hh:mm a"
                        self.header?.openTimer.text = "Open until: " + dateFormatter.string(from: timestampDate)
                
                        if Int(Date().timeIntervalSince1970) > self.closeTime!
                        {
                            self.checkTimer.invalidate()
                        FIRDatabase.database().reference().child("button").updateChildValues(["shabazz": false])
                            return
                        }
                        
                        self.startTimer()
                    }
                    
                }, withCancel: nil)
            }
        }
        else if button == "nn"
        {
            FIRDatabase.database().reference().child("users").child(uid).child("tokommanul").observeSingleEvent(of: .value, with: { (snapshot) in
            
                let tokommanul = snapshot.value as! Bool
        
                if yayOrNay == false
                {
                    self.header?.nnButton.setImage(#imageLiteral(resourceName: "nnCLOSED").withRenderingMode(.alwaysOriginal), for: .normal)
                    self.header?.nnButton.isEnabled = false
                
                        if tokommanul == true
                        {
                            self.header?.nnButton.removeTarget(self, action: #selector(self.handleNNNotification), for: .touchUpInside)
                            self.header?.nnButton.isEnabled = true
                            self.header?.nnButton.addTarget(self, action: #selector(self.handleToKommaNul), for: .touchUpInside)
                        }
                }
                else if yayOrNay == true
                {
                    self.header?.nnButton.setImage(#imageLiteral(resourceName: "nnOPEN").withRenderingMode(.alwaysOriginal), for: .normal)
                    self.header?.nnButton.isEnabled = true
                
                    if tokommanul == true
                    {
                        self.header?.nnButton.addTarget(self, action: #selector(self.handleToKommaNul), for: .touchUpInside)
                        return
                    }
                    
                    self.header?.nnButton.removeTarget(self, action: #selector(self.handleToKommaNul), for: .touchUpInside)
                    self.header?.nnButton.addTarget(self, action: #selector(self.handleNNNotification), for: .touchUpInside)
                }
                
            }, withCancel: nil)
        }
    }
    
    func startTimer()
    {
        self.checkTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(checkIfCloseTime), userInfo: nil, repeats: false)
    }
    
    func checkIfCloseTime()
    {
        if Int(Date().timeIntervalSince1970) > closeTime!
        {
            checkTimer.invalidate()
            FIRDatabase.database().reference().child("button").child("shabazz").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let shabazzStatus = snapshot.value as? Bool
                {
                    if shabazzStatus == false
                    {
                        return
                    }
                    else
                    {
                        FIRDatabase.database().reference().child("button").updateChildValues(["shabazz": false])
                    }
                }
            }, withCancel: nil)
        }
        else
        {
            checkTimer.invalidate()
            startTimer()
        }
    }
    
    func handleJokke()
    {
        let openShabazzPopover = OpenShabazzPopover()
        
        openShabazzPopover.statusController = self
        openShabazzPopover.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        openShabazzPopover.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        
        present(openShabazzPopover, animated: true, completion: nil)
    }
    
    func handleToKommaNul()
    {
        FIRDatabase.database().reference().child("button").child("nn").observeSingleEvent(of: .value, with: { (snapshot) in

            let status = snapshot.value as! Bool
            
            if status == false
            {
                let popUp = UIAlertController(title: nil, message: "Are you sure you want to open? \nIf so, just remember to close again when you are done!", preferredStyle: .alert)
                popUp.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
                    
                    FIRDatabase.database().reference().child("button").updateChildValues(["nn": true]) { (error, ref) in
                        
                        if error != nil
                        {
                            print("Failed to update nn status")
                            return
                        }
                        
                        self.sendPush(title: "2.0 is now open!", message: "Click the 2.0 button to show that you're coming.")
                        
                        self.handleNNNotification()
                        return
                    }
                }))
                popUp.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(popUp, animated: true, completion: nil)
            }
            else if status == true
            {
                let popUp = UIAlertController(title: nil, message: "Are you sure you want to close?", preferredStyle: .alert)
                popUp.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
                    
                FIRDatabase.database().reference().child("button").child("nn").observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if let nnStatus = snapshot.value as? Bool
                        {
                            if nnStatus == false
                            {
                                return
                            }
                            else
                            {
                                FIRDatabase.database().reference().child("button").updateChildValues(["nn": false])
                            }
                        }
                    }, withCancel: nil)
                }))
                popUp.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(popUp, animated: true, completion: nil)
            }
            
        }, withCancel: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return activities.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let width = UIScreen.main.bounds.width
        
        return CGSize(width: (width - 20), height: 45)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell 
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ActivityCell
        
        let activity = activities[indexPath.row]
        
        if activity.activity == "nn"
        {
            cell.activityImage.image = #imageLiteral(resourceName: "computer").withRenderingMode(.alwaysOriginal)
        }
        else if activity.activity == "shabazz"
        {
            cell.activityImage.image = #imageLiteral(resourceName: "kaffeMedDamp").withRenderingMode(.alwaysOriginal)
        }
        else
        {
            cell.activityImage.image = #imageLiteral(resourceName: "hammer").withRenderingMode(.alwaysOriginal)
        }
        
        fetchUserData(activity: activity, cell: cell)

        if let seconds = activity.timestamp?.doubleValue
        {
            let timestampDate = Date(timeIntervalSince1970: seconds)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            cell.timestampLabel.text = "at " + dateFormatter.string(from: timestampDate)
        }

       return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let activity = activities[indexPath.row]
        
        var height: CGFloat = 80
        var width: CGFloat = 200
        
        if let text = activity.note
        {
            height = estimateFrameForText(text: text).height + 15
            width = estimateFrameForText(text: text).width + 20
        }
        
        let cell: ActivityCell = collectionView.cellForItem(at: indexPath) as! ActivityCell
        let noteView = NoteView(frame: CGRect(origin: cell.center, size: CGSize(width: 0, height: 0)))
        
        if let viewWithTag = collectionView.viewWithTag(1)
        {
            closeAnimation(viewWithTag, cell, width, height)
            return
        }
        collectionView.addSubview(noteView)
        noteView.isHidden = false
        noteView.noteView.text = activity.note
        
        openAnimation(noteView, height, width, cell)
    }
    
    func openAnimation(_ noteView: NoteView, _ height: CGFloat, _ width: CGFloat, _ cell: ActivityCell)
    {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            
            noteView.alpha = 1
            noteView.frame = CGRect(x: (self.view.frame.size.width / 2) - (width / 2), y: cell.frame.origin.y - height, width: width, height: height)
            
        }, completion: nil)
    }
    
    func closeAnimation(_ viewWithTag: UIView,_ cell: UICollectionViewCell,_ width: CGFloat,_ height: CGFloat)
    {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            viewWithTag.alpha = 0
            viewWithTag.frame = CGRect(origin: cell.center, size: CGSize(width: 0, height: 0))
            
        }, completion: { (completed: Bool) in
            
            viewWithTag.removeFromSuperview()
        })
    }
    
    fileprivate func estimateFrameForText(text: String) -> CGRect
    {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)], context: nil)
    }
    
    fileprivate func fetchUserData(activity: Activity, cell: ActivityCell)
    {
        if let id = activity.id
        {
            let ref = FIRDatabase.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                if let dictionary = snapshot.value as? [String: AnyObject]
                {
                    cell.usernameLabel.text = dictionary["username"] as? String
                        
                    if let profileImageUrl = dictionary["profileImageUrl"] as? String
                    {
                        cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
                    }
                }
                    
            }, withCancel: nil)
        }
    }
    
    func handleNNNotification()
    {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        let ref = FIRDatabase.database().reference().child("activities").child(uid).child("activity")
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let activity = snapshot.value as? String
            
            if activity == "nn"
            {
                FIRDatabase.database().reference().child("activities").child(uid).removeValue()
                return
            }
            else
            {
                self.handleNote(value: "nn")
            }
            
        }, withCancel: nil)
        
    }
    
    func handleShabazzNotification()
    {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        let ref = FIRDatabase.database().reference().child("activities").child(uid).child("activity")
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let activity = snapshot.value as? String
            
            if activity == "shabazz"
            {
                FIRDatabase.database().reference().child("activities").child(uid).removeValue()
                return
            }
            else
            {
                self.handleNote(value: "shabazz")
            }
            
        }, withCancel: nil)
    
    }
    
    func handleHammerNotification()
    {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
    
        let ref = FIRDatabase.database().reference().child("activities").child(uid).child("activity")
    
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
    
            let activity = snapshot.value as? String
    
            if activity == "hammer"
            {
                FIRDatabase.database().reference().child("activities").child(uid).removeValue()
                self.header?.hammerButton.setImage(#imageLiteral(resourceName: "hammerGraa"), for: .normal)
                return
            }
            else
            {
                self.handleNote(value: "hammer")
            }
    
        }, withCancel: nil)
        
    }
    
    func newNotification(property: [String: AnyObject])
    {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        let ref = FIRDatabase.database().reference().child("activities").child(uid)
        
        let id = uid
        let timestamp = Int(Date().timeIntervalSince1970)
        
        let historyRef = FIRDatabase.database().reference().child("activityHistory").child(uid).child(String(timestamp))
    
        var values: [String: AnyObject] = ["id": id, "timestamp": timestamp] as [String: AnyObject]
        
        property.forEach({values[$0] = $1})
        
        ref.updateChildValues(values) { (error, ref) in
            
            if error != nil
            {
                print(error ?? "")
                return
            }
            
            historyRef.updateChildValues(values)
        }
    }
    
    func handleNote(value: String)
    {
        let alertController = UIAlertController(title: "Note", message: "Enter a short note (max 100 characters)", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { (textField : UITextField!) in
            textField.placeholder = "Note..."
            textField.addTarget(self, action: (#selector(self.handleAlertTextFieldEdit)), for: .editingChanged)
        })
        alertController.addAction(UIAlertAction(title: "Done", style: .default, handler: { (_) in
            
            var note: String = "Blank note..."
            
            if alertController.textFields?[0].text?.isEmpty == false
            {
                note = (alertController.textFields?[0].text)!
            }
            
            let property = ["activity": value, "note": note]
            self.newNotification(property: property as [String : AnyObject])
            
            if value == "hammer"
            {
                self.header?.hammerButton.setImage(#imageLiteral(resourceName: "hammer"), for: .normal)
                let pushTitle = self.user!.username! + " vil hamre!"
                self.sendPush(title: pushTitle, message: note)
            }
            else if value == "shabazz"
            {
                let pushTitle = self.user!.username! + " er på vej til Shabazz."
                self.sendPush(title: pushTitle, message: note)
            }
            else
            {
                let pushTitle = self.user!.username! + " er på vej til 2.0"
                self.sendPush(title: pushTitle, message: note)
            }
            
            
        }))
        alertController.actions[0].isEnabled = true
        present(alertController, animated: true, completion: nil)
        
    }
    
    func sendPush(title: String, message: String)
    {
        if let url = URL(string: "https://fcm.googleapis.com/fcm/send")
        {
            var urlRequest: URLRequest = URLRequest(url: url)
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.addValue("key = AIzaSyCbVQr0hNdhagGAYZ3JmTicNc9FZT8kr_A", forHTTPHeaderField: "Authorization")
            
            let dic: Dictionary<String, Any> =
            [
                "to" : "/topics/Kief",
                "priority" : "high",
                "notification" :
                [
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
    
    func handleAlertTextFieldEdit(sender: UITextField)
    {
        let alertController:UIAlertController = self.presentedViewController as! UIAlertController
        let textField: UITextField = alertController.textFields![0]
        let action: UIAlertAction = alertController.actions[0]
        
        if (textField.text?.characters.count)! > 100
        {
            action.isEnabled = false
        }
        else
        {
            action.isEnabled = true
        }
        
    }

}
