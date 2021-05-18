//
//  JoyConR.swift
//  joy4macos
//
//  Created by Marco Dijkslag on 16/05/2021.
//

import Foundation
import JoyConSwift

class JoyConR: DSUController {
    
    let availableButtons: [JoyCon.Button] = [.A, .B, .X, .Y, .RightSL, .RightSR, .R, .ZR, .Plus, .Home, .RStick]
    
    override func updateControllerVariables() {
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
        buttons2 |= (btnState[.RightSL] ?? false)   ?   0x01      : 0x00 // L2
        buttons2 |= (btnState[.ZR] ?? false)        ?   0x01 << 1 : 0x00 // R2
        buttons2 |= (btnState[.RightSR] ?? false)   ?   0x01 << 2 : 0x00 // L1
        buttons2 |= (btnState[.R] ?? false)         ?   0x01 << 3 : 0x00 // R1
        buttons2 |= (btnState[.X] ?? false)         ?   0x01 << 4 : 0x00 // Square
        buttons2 |= (btnState[.A] ?? false)         ?   0x01 << 5 : 0x00 // Cross
        buttons2 |= (btnState[.B] ?? false)         ?   0x01 << 6 : 0x00 // Circle
        buttons2 |= (btnState[.Y] ?? false)         ?   0x01 << 7 : 0x00 // Triangle
        
        psButton = (btnState[.Home] ?? false) ?         0xFF      : 0x00 // PS
        
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
        buttonL1 = UInt8(((btnState[.RightSR] ?? false) ? 1 : 0) * 255)
        
        buttonR2 = UInt8(((btnState[.ZR] ?? false) ? 1 : 0) * 255)
        buttonL2 = UInt8(((btnState[.RightSL] ?? false) ? 1 : 0) * 255)
        
        // skipping touchpad for now
        
        timeStamp = UInt64(Date.init().timeIntervalSince1970 * 1000000)
    }
    
    override func updateMotionVariables() {
        timeStamp = UInt64(Date.init().timeIntervalSince1970 * 1000000)
        
        // acceleration
        accX = DSUUtils.getUInt8arrayFromCGFloat(num: self.gameController.acceleration.y)
        accY = DSUUtils.getUInt8arrayFromCGFloat(num: -self.gameController.acceleration.x)
        accZ = DSUUtils.getUInt8arrayFromCGFloat(num: -self.gameController.acceleration.z)
        
        // gyroscope
        gyroX = DSUUtils.getUInt8arrayFromCGFloat(num: self.gameController.gyro.y / 5)
        gyroY = DSUUtils.getUInt8arrayFromCGFloat(num: self.gameController.gyro.x / 5)
        gyroZ = DSUUtils.getUInt8arrayFromCGFloat(num: self.gameController.gyro.z / 5)
    }
    
}
