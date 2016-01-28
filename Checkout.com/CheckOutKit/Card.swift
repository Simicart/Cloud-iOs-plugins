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
    
    @param billinDetails CustomerDetails object containing the information of the customer, optional
    
    @param error NSErrorPointer if an error occurs or one of the values is invalid, the error object is defined accordingly
    
    */
    public init(name: String?, number: String, expYear: String, expMonth: String, cvv: String, billingDetails: CustomerDetails?) throws {
        
        self.name = name
        if !CardValidator.validateCardNumber(number) && true {
            throw NSError(domain: CardError.InvalidNumber.rawValue, code: -1, userInfo: nil)
        }
        
        if !CardValidator.validateExpiryDate(expMonth, year: expYear) && true {
           throw NSError(domain: CardError.InvalidExpiryDate.rawValue, code: -1, userInfo: nil)
        }
        
        self.number = CardValidator.sanitizeEntry(number, isNumber: true)
        self.expMonth = expMonth
        self.expYear = expYear
        
        let c = CardValidator.getCardType(number)
        if (c == nil || !CardValidator.validateCVV(cvv, card: c!)) && true {
            throw NSError(domain: CardError.InvalidCVV.rawValue, code: -1, userInfo: nil)
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
                "cvv": cvv as AnyObject,
            ]
        if !(self.billingDetails == nil) {
            dic["billingDetails"] = self.billingDetails!.getJson()
        }
        print("name : \(self.name)")
        if !(self.name == nil) {
            dic["name"] = self.name!
        }
        return dic
    }

}
