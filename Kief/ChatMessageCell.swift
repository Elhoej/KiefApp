//
//  ChatMessageCell.swift
//  KiefApp
//
//  Created by Simon Elhoej Steinmejer on 5/28/17.
//  Copyright © 2017 Simon Elhoej Steinmejer. All rights reserved.
//

import UIKit
import AVFoundation

class ChatMessageCell: UICollectionViewCell
{
    var message: Message?
    var chatLogConroller: ChatLogController?
    
    let activityIndicatorView: UIActivityIndicatorView =
    {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        
        return aiv
    }()
    
    lazy var playButton: UIButton =
    {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        button.tintColor = UIColor.white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        
        return button
    }()
    
    let textView: UITextView =
    {
        let tv = UITextView()
        tv.text = "SOME LEIFEHFIJFW FOR NOW"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.textColor = UIColor.white
        tv.backgroundColor = UIColor.clear
        tv.isEditable = false
        
        return tv
    }()
    
    let timeStampView: UITextView =
    {
        let tv = UITextView()
        tv.text = "hh:mm"
        tv.textAlignment = .right
        tv.font = UIFont.systemFont(ofSize: 9)
        tv.textColor = UIColor.lightGray
        tv.backgroundColor = UIColor.clear
        tv.isEditable = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        
        return tv
    }()
    
    let bubbleView: UIView =
    {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(red: 0, green: 137, blue: 249)
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        
        return view
    }()
    
    let profileImageView: UIImageView =
    {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "statusPage")
        imageView.layer.cornerRadius = 13
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    lazy var messageImageView: UIImageView =
    {
        let imageView = UIImageView()

        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        
        return imageView
    }()
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    func handlePlay()
    {
        if let videoUrlString = message?.videoUrl, let url = NSURL(string: videoUrlString)
        {
            player = AVPlayer(url: url as URL)
            
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = bubbleView.bounds
            bubbleView.layer.addSublayer(playerLayer!)
            
            player?.seek(to: kCMTimeZero)
            player?.play()
            
            activityIndicatorView.startAnimating()
            playButton.isHidden = true
            
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
            
        }
    }
    
    func playerDidFinishPlaying()
    {
        playerLayer?.removeFromSuperlayer()
        activityIndicatorView.stopAnimating()
        playButton.isHidden = false
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        activityIndicatorView.stopAnimating()
        playButton.isHidden = false
    }
    
    func handleZoomTap(tapGesture: UITapGestureRecognizer)
    {
        if message?.videoUrl != nil
        {
            return
        }
        else
        {
            if let imageView = tapGesture.view as? UIImageView
            {
                self.chatLogConroller?.performZoomInForStartingImageView(startingImageView: imageView)
            }
        }
    }
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    var profileImageViewLeftAnchor: NSLayoutConstraint?
    var profileImageViewRightAnchor: NSLayoutConstraint?
    var timestampLeftAnchor: NSLayoutConstraint?
    var timestampRightAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        addSubview(timeStampView)
        
        bubbleView.addSubview(messageImageView)
        bubbleView.addSubview(playButton)
        bubbleView.addSubview(activityIndicatorView)
        
        playButton.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 50, height: 50)
        playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        
        activityIndicatorView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 50, height: 50)
        activityIndicatorView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        
        
        messageImageView.anchor(top: bubbleView.topAnchor, left: bubbleView.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 0)
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        
        bubbleView.anchor(top: self.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 0)
        
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: profileImageView.leftAnchor, constant: -4)
        bubbleViewRightAnchor?.isActive = true
        
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 4)
//        bubbleViewLeftAnchor?.isActive = true
        
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -13).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        
        
        textView.anchor(top: self.topAnchor, left: bubbleView.leftAnchor, bottom: nil, right: bubbleView.rightAnchor, paddingTop: 2, paddingLeft: 8, paddingRight: 0, paddingBottom: 0, width: 0, height: 0)
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true

        profileImageView.anchor(top: nil, left: nil, bottom: self.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 8, paddingRight: 0, paddingBottom: -4, width: 26, height: 26)
        profileImageViewLeftAnchor = profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8)
        profileImageViewRightAnchor = profileImageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        profileImageViewRightAnchor?.isActive = true
        
        timeStampView.topAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -7).isActive = true
        timeStampView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        timeStampView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        timestampLeftAnchor = timeStampView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        
        timestampRightAnchor = timeStampView.rightAnchor.constraint(equalTo: profileImageView.leftAnchor, constant: -8)
        timestampRightAnchor?.isActive = true
    
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
}
