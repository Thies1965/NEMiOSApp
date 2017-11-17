//
//  SettingsManager.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import Foundation
import CoreStore
import KeychainSwift

/// The manager responsible for all tasks regarding application settings.
open class SettingsManager {
    
    // MARK: - Manager Properties
    
    /// The singleton for the settings manager.
    open static let sharedInstance = SettingsManager()
    
    /// The keychain object to access the keychain.
    fileprivate let keychain = KeychainSwift()
    
    // MARK: - Public Manager Methods
    
    /**
        Sets the setup status for the application.
     
        - Parameter setupDone: Bool whether the setup was completed successfully or not.
     */
    open func setSetupStatus(setupDone: Bool) {
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(setupDone, forKey: "setupStatus")
    }
    
    /**
        Gets and returns the setup status.
     
        - Returns: Bool indicating whether the setup was already completed or not.
     */
    open func setupStatus() -> Bool {
        
        let userDefaults = UserDefaults.standard
        let setupStatus = userDefaults.bool(forKey: "setupStatus") 
        
        return setupStatus
    }
    
    /**
        Sets the setup default servers status for the application.
     
        - Parameter createdDefaultServers: Bool whether the default server were created successfully or not.
     */
    open func setDefaultServerStatus(createdDefaultServers: Bool) {
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(createdDefaultServers, forKey: "defaultServerStatus")
    }
    
    /**
        Gets and returns the default server status.
     
        - Returns: Bool indicating whether the default server were already successfully created or not.
     */
    open func defaultServerStatus() -> Bool {
        
        let userDefaults = UserDefaults.standard
        let defaultServerStatus = userDefaults.bool(forKey: "defaultServerStatus")
        
        return defaultServerStatus
    }
    
    /**
        Sets the authentication password for the application.
     
        - Parameter applicationPassword: The authentication password that should get set for the application.
     */
    open func setApplicationPassword(applicationPassword: String) {
        
        let salt = authenticationSalt()
        let saltData = salt != nil ? NSData(bytes: try! salt!.asByteArray(), length: try! salt!.asByteArray().count) : NSData().generateRandomIV(32) as NSData
        let passwordHash = try! HashManager.generateAesKeyForString(applicationPassword, salt: saltData, roundCount: 2000)!
        
        setAuthenticationSalt(authenticationSalt: saltData.hexadecimalString())
        setSetupStatus(setupDone: true)
        
        keychain.set(passwordHash.hexadecimalString(), forKey: "applicationPassword")
    }
    
    /**
        Gets and returns the currently set authentication password.
     
        - Returns: The current authentication password of the application.
     */
    open func applicationPassword() -> String {
        
        let applicationPassword = keychain.get("applicationPassword") ?? String()
        
        return applicationPassword
    }
    
    /**
        Sets the authentication salt for the application.
     
        - Parameter authenticationSalt: The authentication salt that should get set for the application.
     */
    open func setAuthenticationSalt(authenticationSalt: String) {
        
        keychain.set(authenticationSalt, forKey: "authenticationSalt")
    }
    
    /**
        Gets and returns the currently set authentication salt.
     
        - Returns: The current authentication salt of the application.
     */
    open func authenticationSalt() -> String? {
        
        let authenticationSalt = keychain.get("authenticationSalt")
        
        return authenticationSalt
    }
    
    /**
        Sets the invoice message prefix for the application.
     
        - Parameter invoiceMessagePrefix: The invoice message prefix which should get set for the application.
     */
    open func setInvoiceMessagePrefix(invoiceMessagePrefix: String) {
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(invoiceMessagePrefix, forKey: "invoiceMessagePrefix")
    }

    /**
        Gets and returns the invoice message prefix.
     
        - Returns: The invoice message prefix as a string.
     */
    open func invoiceMessagePrefix() -> String {
        
        let userDefaults = UserDefaults.standard
        let invoiceMessagePrefix = userDefaults.object(forKey: "invoiceMessagePrefix") as? String ?? String()

        return invoiceMessagePrefix
    }
    
    /**
        Sets the invoice message postfix for the application.
     
        - Parameter invoiceMessagePostfix: The invoice message postfix which should get set for the application.
     */
    open func setInvoiceMessagePostfix(invoiceMessagePostfix: String) {
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(invoiceMessagePostfix, forKey: "invoiceMessagePostfix")
    }
    
    /**
        Gets and returns the invoice message postfix.
     
        - Returns: The invoice message postfix as a string.
     */
    open func invoiceMessagePostfix() -> String {
        
        let userDefaults = UserDefaults.standard
        let invoiceMessagePostfix = userDefaults.object(forKey: "invoiceMessagePostfix") as? String ?? String()
        
        return invoiceMessagePostfix
    }
    
    /**
        Sets the invoice default message for the application.
     
        - Parameter invoiceDefaultMessage: The invoice default message which should get set for the application.
     */
    open func setInvoiceDefaultMessage(invoiceDefaultMessage: String) {
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(invoiceDefaultMessage, forKey: "invoiceDefaultMessage")
    }
    
    /**
        Gets and returns the invoice default message.
     
        - Returns: The invoice default message as a string.
     */
    open func invoiceDefaultMessage() -> String {
        
        let userDefaults = UserDefaults.standard
        let invoiceDefaultMessage = userDefaults.object(forKey: "invoiceDefaultMessage") as? String ?? String()
        
        return invoiceDefaultMessage
    }
    
    /**
        Sets the authentication touch id status.
     
        - Parameter authenticationTouchIDStatus: The status of the authentication touch id setting that should get set.
     */
    open func setAuthenticationTouchIDStatus(authenticationTouchIDStatus: Bool) {
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(authenticationTouchIDStatus, forKey: "authenticationTouchIDStatus")
    }
    
    /**
        Gets and returns the authentication touch id status.
     
        - Returns: The status of the authentication touch id setting as a boolean.
     */
    open func authenticationTouchIDStatus() -> Bool {
        
        let userDefaults = UserDefaults.standard
        let authenticationTouchIDStatus = userDefaults.bool(forKey: "authenticationTouchIDStatus")
        
        return authenticationTouchIDStatus
    }
    
    /**
        Fetches all stored servers from the database.
     
        - Returns: An array of servers.
     */
    open func servers() -> [Server] {
        
        let servers = DatabaseManager.sharedInstance.dataStack.fetchAll(From(Server.self)) ?? []
        
        return servers
    }
    
    /**
        Creates a new server object and stores that object in the database.
     
        - Parameter protocolType: The protocol type of the new server (http/https).
        - Parameter address: The address of the new server.
        - Parameter port: The port of the new server.
     
        - Returns: The result of the operation - success or failure.
     */
    open func create(server address: String, withProtocolType protocolType: String, andPort port: String, completion: @escaping (_ result: Result) -> Void) {
        
        DatabaseManager.sharedInstance.dataStack.beginAsynchronous { (transaction) -> Void in
            
            let server = transaction.create(Into(Server.self))
            server.address = address
            server.protocolType = protocolType
            server.port = port
            server.isDefault = false
            
            transaction.commit { (result) -> Void in
                switch result {
                case .success( _):
                    return completion(.success)
                    
                case .failure( _):
                    return completion(.failure)
                }
            }
        }
    }
    
    /**
        Creates all default server objects and stores those objects in the database.
     
        - Returns: The result of the operation - success or failure.
     */
    open func createDefaultServers(completion: @escaping (_ result: Result) -> Void) {
        
        DatabaseManager.sharedInstance.dataStack.beginAsynchronous { [unowned self] (transaction) -> Void in
            
            let mainBundle = Bundle.main
            let resourcePath = network == testNetwork ? mainBundle.path(forResource: "TestnetDefaultServers", ofType: "plist")! : mainBundle.path(forResource: "DefaultServers", ofType: "plist")!
            
            let defaultServers = NSDictionary(contentsOfFile: resourcePath)! as! [String: [String]]
            
            for (_, defaultServer) in defaultServers {
                let server = transaction.create(Into(Server.self))
                server.protocolType = defaultServer[0]
                server.address = defaultServer[1]
                server.port = defaultServer[2]
                server.isDefault = true
            }
            
            transaction.commit { [unowned self] (result) -> Void in
                switch result {
                case .success( _):
                    
                    self.setActiveServer(server: self.servers().first!)
                    self.setDefaultServerStatus(createdDefaultServers: true)
                    
                    return completion(.success)
                    
                case .failure( _):
                    return completion(.failure)
                }
            }
        }
    }
    
    /**
        Deletes the provided server object from the database.
     
        - Parameter server: The server object that should get deleted.
     */
    open func delete(server: Server) {
        
        if server == activeServer() {
            var servers = self.servers()
            
            for (index, serverObj) in servers.enumerated() where server.address == serverObj.address {
                servers.remove(at: index)
            }
            
            self.setActiveServer(server: servers.first!)
        }
        
        DatabaseManager.sharedInstance.dataStack.beginAsynchronous { (transaction) -> Void in
            
            transaction.delete(server)
            
            transaction.commit()
        }
    }
    
    /**
        Updates the properties for a server in the database.
     
        - Parameter server: The existing server that should get updated.
        - Parameter protocolType: The new protocol type for the server that should get updated.
        - Parameter address: The new address for the server that should get updated.
        - Parameter port: The new port for the server that should get updated.
     */
    open func updateProperties(forServer server: Server, withNewProtocolType protocolType: String, andNewAddress address: String, andNewPort port: String, completion: @escaping (_ result: Result) -> Void) {
        
        DatabaseManager.sharedInstance.dataStack.beginAsynchronous { [unowned self] (transaction) -> Void in
            
            let editableServer = transaction.edit(server)!
            editableServer.protocolType = protocolType
            editableServer.address = address
            editableServer.port = port
            
            if server.address != address && server == self.activeServer() {
                self.setActiveServer(serverAddress: address)
            }
            
            transaction.commit { (result) -> Void in
                switch result {
                case .success( _):
                    return completion(.success)
                    
                case .failure( _):
                    return completion(.failure)
                }
            }
        }
    }
    
    /**
        Validates if a server with the provided server address already
        got added to the application or not.
     
        - Parameter serverAddress: The address of the server that should get checked for existence.
     
        - Throws:
        - ServerAdditionValidation.ServerAlreadyPresent if a server with the provided address already got added to the application.
     
        - Returns: A bool indicating that no server with the provided address was added to the application.
     */
    open func validateServerExistence(forServerWithAddress serverAddress: String) throws -> Bool {
        
        let servers = self.servers()
        
        for server in servers where server.address == serverAddress {
            throw ServerAdditionValidation.serverAlreadyPresent(serverAddress: server.address)
        }
        
        return true
    }
    
    /**
        Sets the currently active server.
     
        - Parameter server: The server which should get set as the currently active server.
     */
    open func setActiveServer(server: Server) {
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(server.address, forKey: "activeServer")
    }
    
    /**
        Sets the currently active server.
     
        - Parameter serverAddress: The address of the server which should get set as the currently active server.
     */
    open func setActiveServer(serverAddress: String) {
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(serverAddress, forKey: "activeServer")
    }
    
    /**
        Fetches and returns the currently active server.
     
        - Returns: The currently active server.
     */
    open func activeServer() -> Server {
        
        var activeServer: Server?
        let userDefaults = UserDefaults.standard
        let activeServerIdentifier = userDefaults.string(forKey: "activeServer")!
        
        for server in servers() where server.address == activeServerIdentifier {
            activeServer = server
        }
        
        return activeServer!
    }
    
    /**
        Sets the notification update interval.
     
        - Parameter notificationUpdateInterval: The update interval that should get set as active.
     */
    open func setNotificationUpdateInterval(notificationUpdateInterval: Int) {
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(notificationUpdateInterval, forKey: "notificationUpdateInterval")
    }
    
    /**
        Fetches and returns the notification update interval.
     
        - Returns: The currently set notification update interval.
     */
    open func notificationUpdateInterval() -> Int {
        
        let userDefaults = UserDefaults.standard
        let notificationUpdateInterval = userDefaults.integer(forKey: "notificationUpdateInterval")
        
        return notificationUpdateInterval
    }
}
