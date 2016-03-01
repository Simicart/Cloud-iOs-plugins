//
//  Card.swift
//  CheckoutKit
//
//  Created by Manon Henrioux on 13/08/2015.
//  Copyright (c) 2015 Checkout.com. All rights reserved.
//

import Foundation

/** Class containing the card's details before sending them to createCardToken */

public class Card {
    var name: String?
    var number: String!
    var expYear: String!
    var expMonth: String!
    var cvv: String!
    var billingDetails: CustomerDetails?
    
    /**
    
    Default constructor
    
    @param number String containing the card's number
    
    @param name String containing the card's owner name
    
    @param expMonth String containing the expiry month
    
    @param expYear String containing the expiry year
    
    @param cvv String containing the CVV
    
    @param billingDetails CustomerDetails object containing the information of the customer, optional
    
    @throws CardError if an error occurs or one of the values is invalid
    
    */
    public init(name: String?, number: String, expYear: String, expMonth: String, cvv: String, billingDetails: CustomerDetails?) throws {
        
        self.name = name
        if !CardValidator.validateCardNumber(number) {
            throw CardError.InvalidNumber
        }
        
        if !CardValidator.validateExpiryDate(expMonth, year: expYear) {
           throw CardError.InvalidExpiryDate
        }
        
        self.number = CardValidator.sanitizeEntry(number, isNumber: true)
        self.expMonth = expMonth
        self.expYear = expYear
        
        let c = CardValidator.getCardType(number)
        if (c == nil || !CardValidator.validateCVV(cvv, card: c!)) {
            throw CardError.InvalidCVV
        }
        self.cvv = cvv
        self.billingDetails = billingDetails

    }
    
    /**
    
    Function returning the JSON representation of this Card instance
    
    @return Dictionary [String: AnyObject] containing the JSON components of the instance
    
    */
    func getJson() -> [String: AnyObject] {
        var dic: [String: AnyObject] = [
                "number": number as AnyObject,
                "expiryYear": expYear as AnyObject,
                "expiryMonth": expMonth as AnyObject,
                "cvv": cvv as AnyObject
            ]
        if !(self.billingDetails == nil) {
            dic["billingDetails"] = self.billingDetails!.getJson()
        }
        if !(self.name == nil) {
            dic["name"] = self.name!
        }
        return dic
    }

}
