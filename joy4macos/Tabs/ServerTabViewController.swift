//
//  ServerTabViewController.swift
//  joy4macos
//
//  Created by Marco Dijkslag on 16/05/2021.
//

import Foundation
import Cocoa

class ServerTabViewController: NSViewController {
    
    @IBOutlet weak var ipAddress: NSTextField!
    @IBOutlet weak var portNumber: NSTextField!
    @IBOutlet weak var toggleServerBtn: NSButton!
    
    @IBAction func onPortNumberAction(_ sender: Any) {
        appDelegate?.dsuServer?.setPort(number: portNumber.stringValue)
    }
    
    var appDelegate: AppDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = NSApplication.shared.delegate as? AppDelegate
        appDelegate!.serverTabViewController = self
    }

    @IBAction func onToggleServerBtnPressed(_ sender: Any) {
        if appDelegate!.dsuServer != nil, appDelegate!.dsuServer!.isRunning {
            appDelegate!.dsuServer?.stopServer(completion: onServerStateChange)
        } else {
            appDelegate!.dsuServer?.startServer(completion: onServerStateChange)
        }
    }
    
    func onServerStateChange(isRunning: Bool) {
        toggleServerBtn.title = "\(isRunning ? "Stop server" : "Start server")"
        portNumber.isEnabled = !isRunning
    }
}
