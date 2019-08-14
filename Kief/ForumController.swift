//
//  ForumController.swift
//  KiefApp
//
//  Created by Simon Elhoej Steinmejer on 7/17/17.
//  Copyright © 2017 Simon Elhoej Steinmejer. All rights reserved.
//

import UIKit

class ForumController: UIViewController, UIWebViewDelegate
{
    var mainTabBarController: MainTabBarController?
    
    let forumView: UIWebView =
    {
        let webview = UIWebView()
        
        return webview
    }()
    
    let errorLabel: UILabel =
    {
        let label = UILabel()
        label.text = "Lost connection to Kief\n Please check your internet connection"
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.numberOfLines = 2
        label.isHidden = true
        
        return label
    }()
    
    let refreshButton: UIButton =
    {
        let button = UIButton(type: .system)
        button.setTitle("Try again", for: .normal)
        button.setTitleColor(UIColor.rgb(red: 235, green: 216, blue: 164), for: .normal)
        button.backgroundColor = UIColor.rgb(red: 48, green: 42, blue: 35)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.isHidden = true
        button.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        
        return button
    }()
    
    let activityIndicatorView: UIActivityIndicatorView =
    {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.color = UIColor.rgb(red: 48, green: 42, blue: 35)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        
        return aiv
    }()
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        forumView.delegate = self
        if let url = URL(string: "http://kief.dk/harboe/")
        {
            let request = URLRequest(url: url)
            forumView.loadRequest(request)
        }
        
        setupInterfaceElements()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error)
    {
        forumView.isHidden = true
        errorLabel.isHidden = false
        refreshButton.isHidden = false
    }
    
    func webViewDidStartLoad(_ webView: UIWebView)
    {
        activityIndicatorView.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        activityIndicatorView.stopAnimating()
    }
    
//    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool
//    {
//        return true
//    }
    
    func handleRefresh()
    {
        if let url = URL(string: "http://kief.dk/harboe/")
        {
            let request = URLRequest(url: url)
            forumView.loadRequest(request)
        }
        
        errorLabel.isHidden = true
        refreshButton.isHidden = true
        forumView.isHidden = false
    }
    
    func setupInterfaceElements()
    {
        view.addSubview(forumView)
        
        forumView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 0)
        
        forumView.addSubview(activityIndicatorView)
        view.addSubview(errorLabel)
        view.addSubview(refreshButton)
        
        activityIndicatorView.centerXAnchor.constraint(equalTo: forumView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: forumView.centerYAnchor).isActive = true
        
        errorLabel.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 400, height: 80)
        errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80).isActive = true
        
        refreshButton.anchor(top: errorLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 120, height: 40)
        refreshButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
}







