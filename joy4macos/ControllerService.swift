//
//  ControllerService.swift
//  joy4macos
//
//  Created by Marco Dijkslag on 15/05/2021.
//

import Foundation
import JoyConSwift

class ControllerService {
    
    let maximumControllerCount: Int
    
    var numberOfControllersConnected = 0
    var manager: JoyConManager = JoyConManager()
    var connectedControllers: [Int: DSUController] = [:]
    
    var onControllerCountChange: () -> ()
    
    var server: DSUServer?
    
    init(server: DSUServer, maximumControllerCount: Int = 4, onControllerCountChange: @escaping () -> ()) {
        self.maximumControllerCount = maximumControllerCount
        self.server = server
        self.onControllerCountChange = onControllerCountChange
        self.observeControllers()
    }
    
    func observeControllers() {
        self.manager.connectHandler = { [weak self] controller in
            self?.addController(controller)
            self?.onControllerCountChange()
        }
        self.manager.disconnectHandler = { [weak self] controller in
            self?.removeController(controller)
            self?.onControllerCountChange()
        }
        
        _ = self.manager.runAsync()
    }
    
    func reportControllers() {
        for dsuController in self.connectedControllers {
            self.server!.report(controller: dsuController.value)
        }
    }
    
    func reportController(dsuController: DSUController) {
        self.server!.report(controller: dsuController)
    }
    
    func firstFreeSlot() -> Int {
        for i in 0..<self.maximumControllerCount {
            if !self.connectedControllers.keys.contains(i) {
                return i
            }
        }
        return -1
    }
    
    func addController(_ controller: JoyConSwift.Controller) {
        controller.setPlayerLights(l1: .on, l2: .off, l3: .off, l4: .off)
        controller.enableIMU(enable: true)
        controller.setInputMode(mode: .standardFull)
        
        let freeSlot = self.firstFreeSlot()
        if freeSlot != -1 {
            self.addControllerToSlots(controller: controller, slot: freeSlot)
        }
    }
    
    func removeController(_ controller: JoyConSwift.Controller) {
        self.removeControllerFromSlots(controller: controller)
    }
    
    func addControllerToSlots(controller: JoyConSwift.Controller, slot: Int) {
        switch (controller.type) {
        case .JoyConL:
            self.connectedControllers[slot] = JoyConL(controllerService: self, gameController: controller, slot: UInt8(slot))
            break
        case .JoyConR:
            self.connectedControllers[slot] = JoyConR(controllerService: self, gameController: controller, slot: UInt8(slot))
            break
        case .ProController:
            self.connectedControllers[slot] = ProController(controllerService: self, gameController: controller, slot: UInt8(slot))
            break
        default:
            self.connectedControllers[slot] = DSUController(controllerService: self, gameController: controller, slot: UInt8(slot))
            break
        }
        self.numberOfControllersConnected += 1
    }
    
    func removeControllerFromSlots(controller: JoyConSwift.Controller) {
        var removeSlot: Int = -1
        self.connectedControllers.forEach { slot, dsuController in
            if dsuController.gameController.serialID == controller.serialID {
                removeSlot = Int(slot)
            }
        }
        if removeSlot != -1 {
            self.connectedControllers.removeValue(forKey: removeSlot)
        }
        self.numberOfControllersConnected -= 1
    }
    
    func disconnectAll() {
        self.connectedControllers.forEach { slot, controller in
            controller.gameController.setHCIState(state: .disconnect)
        }
    }
    
    
}
