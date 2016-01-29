//
//  CardProvider.swift
//  CheckoutKit
//
//  Created by Manon Henrioux on 13/08/2015.
//  Copyright (c) 2015 Checkout.com. All rights reserved.
//

import Foundation

/** Class used to represent a card provider */

public class CardProvider: Serializable, Equatable {
    public var id: String!
    public var name: String!
    public var cvvRequired: Bool!
    
    /**
    
    Convenience constructor
    
    @param data Dictionary [String: AnyObject] containing a JSON representation of a CardProvider instance
    
    */
    
    public required init?(data: [String: AnyObject]) {
        if let id = data["id"] as? String, name = data["name"] as? String, cvvReq = data["cvvRequired"] as? Bool {
            self.id = id
            self.cvvRequired = cvvReq
            self.name = name
        } else {
            return nil
        }
    }
    
    /**
    
    Default constructor
    
    @param id String containing the id of the card provider
    
    @param name String containing the name of the card provider
    
    @param cvvRequired boolean, if the cvv is required for this card provider
    
    */
    public init(id: String, name: String, cvvRequired: Bool) {
        self.id = id
        self.name = name
        self.cvvRequired = cvvRequired
    }
    
}

/*
Function used for testing purposes, returns true if the fields of both instances are identical
*/
public func ==(lhs: CardProvider, rhs: CardProvider) -> Bool {
    return lhs.id == rhs.id && lhs.name == rhs.name && lhs.cvvRequired == rhs.cvvRequired
}