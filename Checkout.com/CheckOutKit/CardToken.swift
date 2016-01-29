//
//  CardToken.swift
//  CheckoutKit
//
//  Created by Manon Henrioux on 17/08/2015.
//  Copyright (c) 2015 Checkout.com. All rights reserved.
//

import Foundation

/** Class instantiated when the createCardToken method of CheckoutKit is called, it contains all the information returned by  Checkout */

public class CardToken: Serializable {
    
    public var expMonth: String!
    public var expYear: String!
    public var billDetails: CustomerDetails?
    public var last4: String!
    public var paymentMethod: String!
    public var fingerprint: String!
    public var name: String!
    public var id: String!
    
    public var logging: Bool = false
    
    /**
    
    Default constructor for a CardToken
    
    @param expMonth String containing the expiring month of the card
    
    @param expYear String containing the expiring year of the card
    
    @param billDetails Object containing the billing details of the customer
    
    @param last4 String containing the last 4 digits of the card's number
    
    @param paymentMethod String containing the payment method corresponding to the card
    
    @param fingerprint String containing the fingerprint corresponding to the card
    
    @param name String corresponding the the card's owner name
    
    @param cardToken String containing the card token
    
    */
    
    public init(expMonth: String, expYear: String, billDetails: CustomerDetails, last4: String, paymentMethod: String, fingerprint: String, name: String, cardToken: String) {
        self.expYear = expYear
        self.expMonth = expMonth
        self.billDetails = billDetails
        self.last4 = last4
        self.paymentMethod = paymentMethod
        self.fingerprint = fingerprint
        self.name = name
        self.id = cardToken
    }
    
    /**
    
    Convenience constructor
    
    @param data Dictionary [String: AnyObject] containing a JSON representation of a CardToken instance
    
    */
    
    public required init?(data: [String: AnyObject]) {
        //stand code
        /*
        if let year = data["expiryYear"] as? String,
            month = data["expiryMonth"] as? String,
            id = data["id"] as? String,
            last4 = data["last4"] as? String,
            paymentMethod = data["paymentMethod"] as? String,
            fingerprint = data["fingerprint"] as? String,
            name = data["name"] as? String {
              
                self.expMonth = month
                self.expYear = year
                
                self.id = id
                self.last4 = last4
                self.paymentMethod = paymentMethod
                self.fingerprint = fingerprint
                self.name = name
                if let billDetails = data["billingDetails"] as? [String: AnyObject] {
                    self.billDetails = CustomerDetails(data: billDetails)
                }
                
        } else {
            return nil
        }
        */
        print("data to create cardToken : \(data)")
        if let year = data["expiryYear"] as? String,
            month = data["expiryMonth"] as? String,
            id = data["id"] as? String,
            last4 = data["last4"] as? String,
            paymentMethod = data["paymentMethod"] as? String
        {
                
                self.expMonth = month
                self.expYear = year
                
                self.id = id
                self.last4 = last4
                self.paymentMethod = paymentMethod
                // hard code for pass, test
//                self.fingerprint = "E260752-ED1B-7217L-94A0-6D5C75274C84"
//                self.name = name
                if let billDetails = data["billingDetails"] as? [String: AnyObject] {
                    self.billDetails = CustomerDetails(data: billDetails)
                }
                
        } else {
            return nil
        }
    }
}