//
//  DSUServer.swift
//  joy4macos
//
//  Created by Marco Dijkslag on 15/05/2021.
//

import Foundation
import Network


class DSUServer {
    
    var server: NWListener?
    var portUDP: NWEndpoint.Port = 26760
    var ipAddress: String = "127.0.0.1"
    
    var isRunning: Bool = false
    
    var backgroundQueueUdpListener = DispatchQueue(label: "udp-lis.bg.queue", attributes: [])
    var backgroundQueueUdpConnection = DispatchQueue(label: "udp-con.bg.queue", attributes: [])
    
    var clients: [String: Client] = [:]
    
    var counter: UInt32 = 0
    
    var controllerService: ControllerService?
    
    init() {
        
    }
    
    func setControllerService(controllerService: ControllerService) {
        self.controllerService = controllerService
    }
    
    func startServer(completion: (Bool)->()) {
        do {
            self.server = try NWListener(using: .udp, on: portUDP)
            
            self.server!.stateUpdateHandler = self.serverStateUpdateHandler
            self.server!.newConnectionHandler = self.serverNewConnectionHandler
            
            self.server!.start(queue: backgroundQueueUdpListener)
            self.isRunning = true
        } catch {
            self.isRunning = false
            print("Could not isten for incoming udp")
        }
        completion(self.isRunning)
    }
    
    func stopServer(completion: (Bool)->()) {
        self.server?.cancel()
        self.server = nil
        for (_, client) in self.clients {
            client.close()
        }
        self.isRunning = false
        completion(self.isRunning)
    }
    
    func setPort(number: String) {
        if self.isRunning == false {
            self.portUDP = NWEndpoint.Port(number)!
            print(self.portUDP)
        }
    }
    
    func serverStateUpdateHandler(listenerState: NWListener.State) {
        print("👂🏼👂🏼👂🏼 NWListener Handler called")
        switch listenerState {
            case .setup:
                print("Listener: Setup")
            case .waiting(let error):
                print("Listener: Waiting \(error)")
            case .ready:
                print("Listener: ✅ Ready and listens on port: \(self.server?.port?.debugDescription ?? "-")")
            case .failed(let error):
                print("Listener: Failed \(error)")
            case .cancelled:
                print("Listener: 🛑 Cancelled by myOffButton")
            default:
                break;
        }
    }
    
    func serverNewConnectionHandler(newConnection: NWConnection) {
        print("📞📞📞 NWConnection Handler called ")
        newConnection.stateUpdateHandler = { (udpConnectionState) in

            switch udpConnectionState {
            case .setup:
                print("Connection: 👨🏼‍💻 setup")
            case .waiting(let error):
                print("Connection: ⏰ waiting: \(error)")
            case .ready:
                print("Connection: ✅ ready")
                self.handleIncoming(newConnection)
            case .failed(let error):
                print("Connection: 🔥 failed: \(error)")
            case .cancelled:
                print("Connection: 🛑 cancelled")
            default:
                break
            }
            
        }

        newConnection.start(queue: self.backgroundQueueUdpConnection)
    }
    
    func handleIncoming(_ incomingConnection: NWConnection) {
        incomingConnection.receiveMessage(completion: {(data, context, isComplete, error) in
            
            if let data = data, !data.isEmpty {
                let data = [UInt8](data)
                let type = [UInt8](data[16...19])
                
                switch type {
                case DSUMessage.TYPE_PORTS:
                    print("Received: Message Type: PORTS")
                    self.handleIncomingPortsRequest(connection: incomingConnection, data: data)
                    break
                case DSUMessage.TYPE_DATA:
                    print("Received: Message Type: DATA")
                    self.handleIncomingDataRequest(connection: incomingConnection, data: data)
                    break
                case DSUMessage.TYPE_VERSION:
                    print("Message Type: VERSION")
                    break
                default:
                    print("Uknown message type")
                }
            }
        })
        
    }
    
    func handleIncomingPortsRequest(connection: NWConnection, data: [UInt8]) {
        let requestsCount = data[20] // aka, the number of slots the client asked for
        
        for i in 0..<requestsCount {
            let dataMessage = self.getPortsPacket(index: i)
            connection.send(content: Data(dataMessage), completion: NWConnection.SendCompletion.contentProcessed({ (error: NWError?) in
                if error != nil {
                    // Client disconnect?
                    connection.cancel()
                    print("Got an error sending ports data: \(error!)")
                }
            }))
        }
    }
    
    func handleIncomingDataRequest(connection: NWConnection, data: [UInt8]) {
        print("Incoming data request packet: \(Data(data).hexEncodedString())")
        let slotBased = data[20]
        let reqSlot = Int(data[21])
        let flags = data[24]
        let regId = data[25]
        
        if flags == 0 && regId == 0 {
            switch connection.endpoint {
            case .hostPort(let host, let port):
                let clientAddress = "\(host):\(port)"
                if self.clients[clientAddress] == nil {
                    print("New client connection: \(clientAddress)")
                    self.clients[clientAddress] = Client(server: self, connection: connection, address: clientAddress)
                    self.clients[clientAddress]!.setSlot(slot: reqSlot)
                    self.updateClientsViewModel()
                } else {
                    print("Refresh existing connection: \(clientAddress)")
                    self.clients[clientAddress]!.setSlot(slot: reqSlot)
                    self.clients[clientAddress]!.setTimeStampOnDataRequest()
                }
                break
            default:
                return
            }
        
            if self.controllerService != nil {
                if slotBased == 0x01 {
                    if self.controllerService!.connectedControllers[reqSlot] != nil {
                        report(controller: self.controllerService!.connectedControllers[reqSlot]!)
                    }
                } else {
                    for dsuController in self.controllerService!.connectedControllers {
                        report(controller: dsuController.value)
                    }
                }
            }
        }
    }
    
    func getPortsPacket(index: UInt8) -> [UInt8] {
        if self.controllerService != nil && index <= self.controllerService!.numberOfControllersConnected && self.controllerService!.connectedControllers[Int(index)] != nil {
            return DSUMessage.make(type: DSUMessage.TYPE_PORTS, data: self.controllerService!.connectedControllers[Int(index)]!.getInfoPacket())
        }
        return DSUMessage.make(type: DSUMessage.TYPE_PORTS, data: DSUController.defaultInfoPacket(index: index))
    }
    
    func report(controller: DSUController) {
        for (_, client) in self.clients {
            if client.slots[Int(controller.slot)] {
                client.send(dataMessage: Data(controller.getDataPacket(counter: self.counter)))
            }
        }
        self.counter += 1
    }
    
    func updateClientsViewModel() {
        DispatchQueue.main.async {
//            self.clientsViewModel.clients = self.clients
        }
    }
    
}

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
}
