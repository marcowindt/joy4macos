//
//  ControllersTabViewController.swift
//  joy4macos
//
//  Created by Marco Dijkslag on 16/05/2021.
//

import Foundation
import Cocoa

class ControllersTabViewController: NSViewController {
    
    @IBOutlet weak var numberOfConnectedControllers: NSTextField!
    @IBOutlet weak var controllersTableView: NSTableView!
    
    var appDelegate: AppDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = NSApplication.shared.delegate as? AppDelegate
        appDelegate!.controllersTabViewController = self
        
        controllersTableView.delegate = self
        controllersTableView.dataSource = self
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        controllersTableView.reloadData()
    }
    
    func onControllerCountChanged() {
        DispatchQueue.main.async {
            self.numberOfConnectedControllers.stringValue = "\(self.appDelegate!.controllerService!.numberOfControllersConnected) of \(self.appDelegate!.controllerService!.maximumControllerCount) controllers connected"
            self.controllersTableView.reloadData()
        }
    }
    
}

extension ControllersTabViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return appDelegate?.controllerService?.numberOfControllersConnected ?? 0
    }
}

extension ControllersTabViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 32.0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let rowController = appDelegate!.controllerService!.connectedControllers[row]
        
        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "controllerColumn") {
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "controllerName")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.stringValue = "\(rowController!.gameController.type) (\(rowController!.gameController.serialID))"
            
            return cellView
        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "slotColumn") {
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "controllerSlot")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.stringValue = "\(rowController!.slot)"

            return cellView
        }
        
        return nil
    }
}
