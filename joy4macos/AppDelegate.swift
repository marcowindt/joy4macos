//
//  AppDelegate.swift
//  joy4macos
//
//  Created by Marco Dijkslag on 15/05/2021.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var dsuServer: DSUServer?
    var controllerService: ControllerService?
    
    var controllersTabViewController: ControllersTabViewController!
    var serverTabViewController: ServerTabViewController!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.dsuServer = DSUServer()
        self.controllerService = ControllerService(server: self.dsuServer!, onControllerCountChange: self.controllersTabViewController.onControllerCountChanged)
        self.dsuServer!.setControllerService(controllerService: self.controllerService!)
        self.dsuServer!.startServer(completion: self.serverTabViewController.onServerStateChange)
        
        self.controllersTabViewController.onControllerCountChanged()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        self.controllerService?.disconnectAll()
        self.dsuServer?.stopServer(completion: self.serverTabViewController.onServerStateChange)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}

