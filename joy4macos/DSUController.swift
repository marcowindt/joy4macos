//
//  DSUController.swift
//  joy4macos
//
//  Created by Marco Dijkslag on 15/05/2021.
//

import Foundation
import JoyConSwift

class DSUController {
    
    static let GRAVITY: Double = 1.0
    
    let controllerButtons: [JoyCon.ControllerType: [JoyCon.Button]] = [
        .JoyConL: [.Up, .Right, .Down, .Left, .LeftSL, .LeftSR, .L, .ZL, .Minus, .Capture, .LStick],
        .JoyConR: [.A, .B, .X, .Y, .RightSL, .RightSR, .R, .ZR, .Plus, .Home, .RStick],
        .ProController: [.A, .B, .X, .Y, .L, .ZL, .R, .ZR, .Up, .Right, .Down, .Left, .Minus, .Plus, .Capture, .Home, .LStick, .RStick]
    ]
    
    var slot: UInt8 = 0x00
    var model: UInt8 = 0x02 // (with gyro, according to specs)
    var connectionType: UInt8 = 0x02 // 0x01: USB, 0x02: Bluetooth
    var battery: UInt8 = 0x05
    var macAddress: [UInt8] = [0xFA, 0xCE, 0xB0, 0x0C, 0x00, 0x00]
    
    var buttons1: UInt8 = 0x00
    var buttons2: UInt8 = 0x00
    var psButton: UInt8 = 0x00
    var touchBtn: UInt8 = 0x00
    
    var leftStickXplusRightward: UInt8 = 0x00
    var leftStickYplusUpward: UInt8 = 0x00
    
    var rightStickXplusRightward: UInt8 = 0x00
    var rightStickYplusUpward: UInt8 = 0x00
    
    var dpadLeft: UInt8 = 0x00
    var dpadDown: UInt8 = 0x00
    var dpadRight: UInt8 = 0x00
    var dpadUp: UInt8 = 0x00
    
    var buttonSquare: UInt8 = 0x00
    var buttonCross: UInt8 = 0x00
    var buttonCircle: UInt8 = 0x00
    var buttonTriangle: UInt8 = 0x00
    
    var buttonR1: UInt8 = 0x00
    var buttonL1: UInt8 = 0x00
    var buttonR2: UInt8 = 0x00
    var buttonL2: UInt8 = 0x00
    
    var touchPad: [UInt8] = [
        0x00,   // trackpad 1 active
        0x00,   // trackpad 1 id
        0x00, 0x00, // x
        0x00, 0x00, // y
        0x00,   // trackpad 2 active
        0x00,   // trackpad 2 id
        0x00, 0x00, // x
        0x00, 0x00  // y
    ]
    var timeStamp: UInt64 = 0x0000000000000000
    
    let empty: [UInt8] = [0x00, 0x00, 0x00, 0x00]
    
    var accX: [UInt8] = [0x00, 0x00, 0x00, 0x00]
    var accY: [UInt8] = [0x00, 0x00, 0x00, 0x00]
    var accZ: [UInt8] = [0x00, 0x00, 0x00, 0x00]
    
    var gyroX: [UInt8] = [0x00, 0x00, 0x00, 0x00]
    var gyroY: [UInt8] = [0x00, 0x00, 0x00, 0x00]
    var gyroZ: [UInt8] = [0x00, 0x00, 0x00, 0x00]
    
    var controllerService: ControllerService?
    var gameController: JoyConSwift.Controller
    
    init(controllerService: ControllerService, gameController: JoyConSwift.Controller, slot: UInt8) {
        self.controllerService = controllerService
        self.gameController = gameController
        
        print("Connect controller!")
        
        self.slot = slot
        self.macAddress[5] = self.slot
        
        
        self.gameController.buttonPressHandler = { [weak self] _ in
            self?.inputValueChange()
        }
        self.gameController.buttonReleaseHandler = { [weak self] _ in
            self?.inputValueChange()
        }
        self.gameController.leftStickPosHandler = { pos in
            self.inputValueChange()
        }
        self.gameController.rightStickPosHandler = { pos in
            self.inputValueChange()
        }
        self.gameController.sensorHandler = {
            self.motionValueChange()
        }
        
        self.updateControllerVariables()
    }
    
    func inputValueChange() {
        self.updateControllerVariables()
        self.controllerService?.reportController(dsuController: self)
    }
    
    func motionValueChange() {
        self.updateMotionVariables()
        self.controllerService?.reportController(dsuController: self)
    }
    
    func updateControllerVariables() {
        // BUTTONS
        let btnState = self.gameController.buttonState
        
        buttons1 = 0x00
        buttons1 |= (btnState[.Minus] ?? false)     ?   0x01      : 0x00 // SHARE BUTTON
        buttons1 |= (btnState[.LStick] ?? false)    ?   0x01 << 1 : 0x00 // L3
        buttons1 |= (btnState[.RStick] ?? false)    ?   0x01 << 2 : 0x00 // R3
        buttons1 |= (btnState[.Plus] ?? false)      ?   0x01 << 3 : 0x00 // OPTIONS BUTTON
        buttons1 |= (btnState[.Up] ?? false)        ?   0x01 << 4 : 0x00
        buttons1 |= (btnState[.Right] ?? false)     ?   0x01 << 5 : 0x00
        buttons1 |= (btnState[.Down] ?? false)      ?   0x01 << 6 : 0x00
        buttons1 |= (btnState[.Left] ?? false)      ?   0x01 << 7 : 0x00
        
        buttons2 = 0x00
        buttons2 |= (btnState[.ZL] ?? false)        ?   0x01      : 0x00 // L2
        buttons2 |= (btnState[.ZR] ?? false)        ?   0x01 << 1 : 0x00 // R2
        buttons2 |= (btnState[.L] ?? false)         ?   0x01 << 2 : 0x00 // L1
        buttons2 |= (btnState[.R] ?? false)         ?   0x01 << 3 : 0x00 // R1
        buttons2 |= (btnState[.X] ?? false)         ?   0x01 << 4 : 0x00 // Square
        buttons2 |= (btnState[.A] ?? false)         ?   0x01 << 5 : 0x00 // Cross
        buttons2 |= (btnState[.B] ?? false)         ?   0x01 << 6 : 0x00 // Circle
        buttons2 |= (btnState[.Y] ?? false)         ?   0x01 << 7 : 0x00 // Triangle
        
        psButton = (btnState[.Home] ?? false) ?             0xFF      : 0x00 // PS
        
        leftStickXplusRightward = DSUUtils.getUInt8fromCGFloat(num: self.gameController.lStickPos.x)
        leftStickYplusUpward = DSUUtils.getUInt8fromCGFloat(num: self.gameController.lStickPos.y)

        rightStickXplusRightward = DSUUtils.getUInt8fromCGFloat(num: self.gameController.rStickPos.x)
        rightStickYplusUpward = DSUUtils.getUInt8fromCGFloat(num: self.gameController.rStickPos.y)

        dpadLeft = UInt8(((btnState[.Left] ?? false) ? 1 : 0) * 255)
        dpadDown = UInt8(((btnState[.Down] ?? false) ? 1 : 0) * 255)
        dpadRight = UInt8(((btnState[.Right] ?? false) ? 1 : 0) * 255)
        dpadUp = UInt8(((btnState[.Up] ?? false) ? 1 : 0) * 255)

        buttonSquare = UInt8(((btnState[.X] ?? false) ? 1 : 0) * 255)
        buttonCross = UInt8(((btnState[.A] ?? false) ? 1 : 0) * 255)
        buttonCircle = UInt8(((btnState[.B] ?? false) ? 1 : 0) * 255)
        buttonTriangle = UInt8(((btnState[.Y] ?? false) ? 1 : 0) * 255)
        
        buttonR1 = UInt8(((btnState[.R] ?? false) ? 1 : 0) * 255)
        buttonL1 = UInt8(((btnState[.L] ?? false) ? 1 : 0) * 255)
        
        buttonR2 = UInt8(((btnState[.ZR] ?? false) ? 1 : 0) * 255)
        buttonL2 = UInt8(((btnState[.ZL] ?? false) ? 1 : 0) * 255)
        
        // skipping touchpad for now
        
        timeStamp = UInt64(Date.init().timeIntervalSince1970 * 1000000)
    }
    
    func updateMotionVariables() {
        timeStamp = UInt64(Date.init().timeIntervalSince1970 * 1000000)
        
        // acceleration
        accX = DSUUtils.getUInt8arrayFromCGFloat(num: -self.gameController.acceleration.y)
        accY = DSUUtils.getUInt8arrayFromCGFloat(num: -self.gameController.acceleration.x)
        accZ = DSUUtils.getUInt8arrayFromCGFloat(num: self.gameController.acceleration.z)
        
        // gyroscope
        gyroX = DSUUtils.getUInt8arrayFromCGFloat(num: self.gameController.gyro.y / 100)
        gyroY = DSUUtils.getUInt8arrayFromCGFloat(num: self.gameController.gyro.z / 100)
        gyroZ = DSUUtils.getUInt8arrayFromCGFloat(num: self.gameController.gyro.x / 100)
    }
    
    func getDataPacket(counter: UInt32) -> [UInt8] {
        var packet: [UInt8] = [
            slot,
            0x02,
            model,
            0x02,
            macAddress[0], macAddress[1], macAddress[2], // Mac part 1
            macAddress[3], macAddress[4], macAddress[5], // Mac part 2
            battery,
            0x01,   // Controller ACTIVE state
            UInt8(truncatingIfNeeded: counter) & 0xFF,
            UInt8(truncatingIfNeeded: counter >> 8) & 0xFF,
            UInt8(truncatingIfNeeded: counter >> 16) & 0xFF,
            UInt8(truncatingIfNeeded: counter >> 24) & 0xFF,
            
            buttons1,
            buttons2,
            
            psButton,
            touchBtn,
            
            leftStickXplusRightward,
            leftStickYplusUpward,
            rightStickXplusRightward,
            rightStickYplusUpward,
            
            dpadLeft,
            dpadDown,
            dpadRight,
            dpadUp,
            
            buttonSquare,
            buttonCross,
            buttonCircle,
            buttonTriangle,
            
            buttonR1,
            buttonL1,
            
            buttonR2,
            buttonL2,
        ]
        
        packet.append(contentsOf: touchPad)
        packet.append(contentsOf: DSUUtils.getTimestampUInt8array(timeStamp: timeStamp))
        packet.append(contentsOf: accX)
        packet.append(contentsOf: accY)
        packet.append(contentsOf: accZ)
        packet.append(contentsOf: gyroX)
        packet.append(contentsOf: gyroY)
        packet.append(contentsOf: gyroZ)
        
        return DSUMessage.make(type: DSUMessage.TYPE_DATA, data: packet)
    }
    
    func getInfoPacket() -> [UInt8] {
        let packet: [UInt8] = [
            slot,
            0x02,
            model,
            connectionType,
            macAddress[0], macAddress[1], macAddress[2], // Mac part 1
            macAddress[3], macAddress[4], macAddress[5], // Mac part 2
            battery,
            0x01,   // Controller ACTIVE state
        ]
        
        return packet
    }
    
    static func defaultInfoPacket(index: UInt8) -> [UInt8] {
        let packet: [UInt8] = [
            index, // pad id
            0x00, // state (disconnected)
            0x01, // model (generic)
            0x01, // Connection type USB
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // Mac
            0x00, // Battery
            0x00, // ? (Needs to be a zero byte according to specs)
        ]
        
        return packet
    }
    
}
