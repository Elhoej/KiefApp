//
//  HeaderView.swift
//  KiefApp
//
//  Created by Simon Elhoej Steinmejer on 6/10/17.
//  Copyright © 2017 Simon Elhoej Steinmejer. All rights reserved.
//

import UIKit

class HeaderContainerView: UICollectionViewCell
{
    weak var statusController: StatusController?
    {
        didSet
        {
            hammerButton.addTarget(statusController, action: #selector(StatusController.handleHammerNotification), for: .touchUpInside)
        }
    }
    
    let containerView: UIView =
    {
        let view = UIView()
        view.backgroundColor = UIColor.init(red: 48/255, green: 42/255, blue: 35/255, alpha: 0.3)
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        
        return view
    }()
    
    let amabLabel: UILabel =
    {
        let label = UILabel()
        label.text = "AMAB"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.black
        label.textAlignment = .center
        
        return label
    }()
    
    let nnButton: UIButton =
    {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "nnCLOSED"), for: .normal)
        button.layer.masksToBounds = true
        
        return button
    }()
    
    let shabazzButton: UIButton =
    {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "kaffeUdenDamp").withRenderingMode(.alwaysOriginal), for: .normal)
        button.layer.masksToBounds = true
        
        return button
    }()
    
    let hammerButton: UIButton =
    {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "hammerGraa").withRenderingMode(.alwaysOriginal), for: .normal)
        button.layer.masksToBounds = true
        
        return button
    }()
    
    let openTimer: UILabel =
    {
        let label = UILabel()
        label.text = "Closed"
        label.backgroundColor = UIColor.rgb(red: 48, green: 42, blue: 35)
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        
        return label
    }()
    
    let frostEffect: UIVisualEffectView =
    {
        let frost = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        frost.autoresizingMask = .flexibleWidth
        
        return frost
    }()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
        
        addSubview(containerView)
        addSubview(amabLabel)
        containerView.addSubview(frostEffect)
        containerView.addSubview(nnButton)
        containerView.addSubview(shabazzButton)
        containerView.addSubview(hammerButton)
        containerView.addSubview(openTimer)
        
        
        amabLabel.anchor(top: nil, left: leftAnchor, bottom: containerView.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingRight: 20, paddingBottom: -300, width: 100, height: 30)
        
        containerView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 30, paddingLeft: 10, paddingRight: 10, paddingBottom: -10, width: 0, height: 0)
        
        frostEffect.anchor(top: topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 0)
        
        nnButton.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 10, paddingRight: 0, paddingBottom: 0, width: 76.5, height: 76.5)
        
        hammerButton.anchor(top: containerView.topAnchor, left: nil, bottom: nil, right: containerView.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingRight: 10, paddingBottom: 0, width: 76.5, height: 76.5)
        
        shabazzButton.anchor(top: containerView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 66.5, height: 76.5)
        shabazzButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        openTimer.anchor(top: shabazzButton.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 4, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 130, height: 15)
        openTimer.centerXAnchor.constraint(equalTo: shabazzButton.centerXAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
