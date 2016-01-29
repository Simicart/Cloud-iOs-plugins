//
//  CardInfo.swift
//  CheckoutKit
//
//  Created by Manon Henrioux on 20/08/2015.
//
//

import Foundation

/** Class containing the card information used for the validity checks in CardValidator */

public struct CardInfo: Equatable {
    
    
    private static let DEFAULT_CARD_FORMAT: String = "(\\d{1,4})"
    
    public static let MAESTRO = CardInfo(name: "maestro", pattern: "^(5018|5020|5038|6304|6759|6761|6763)[0-9]{8,15}$", format: DEFAULT_CARD_FORMAT, cardLength: [12, 13, 14, 15, 16, 17, 18, 19], cvvLength: [3], luhn: true, supported: true)
    public static let MASTERCARD = CardInfo(name: "mastercard", pattern: "^5[1-5][0-9]{14}$", format: DEFAULT_CARD_FORMAT, cardLength: [16,17], cvvLength: [3], luhn: true, supported: true)
    public static let DINERSCLUB = CardInfo(name: "dinersclub", pattern: "^3(?:0[0-5]|[68][0-9])?[0-9]{11}$", format: "(\\d{1,4})(\\d{1,6})?(\\d{1,4})?", cardLength: [14], cvvLength: [3], luhn: true, supported: true)
    public static let LASER = CardInfo(name: "laser", pattern: "^(6304|6706|6709|6771)[0-9]{12,15}$", format: DEFAULT_CARD_FORMAT, cardLength: [16,17, 18, 19], cvvLength: [3], luhn: true, supported: false)
    public static let JCB = CardInfo(name: "jcb", pattern: "^(?:2131|1800|35[0-9]{3})[0-9]{11}$", format: DEFAULT_CARD_FORMAT, cardLength: [16], cvvLength: [3], luhn: true, supported: true)
    public static let UNIONPAY = CardInfo(name: "unionpay", pattern: "^(62[0-9]{14,17})$", format: DEFAULT_CARD_FORMAT, cardLength: [16,17, 18, 19], cvvLength: [3], luhn: false, supported: false)
    public static let DISCOVER = CardInfo(name: "discover", pattern: "^6(?:011|5[0-9]{2})[0-9]{12}$", format: DEFAULT_CARD_FORMAT, cardLength: [16], cvvLength: [3], luhn: true, supported: true)
    public static let AMEX = CardInfo(name: "amex", pattern: "^3[47][0-9]{13}$", format: "^(\\d{1,4})(\\d{1,6})?(\\d{1,5})?$", cardLength: [15], cvvLength: [4], luhn: true, supported: true)
    public static let VISA = CardInfo(name: "visa", pattern: "^4[0-9]{12}(?:[0-9]{3})?$", format: DEFAULT_CARD_FORMAT, cardLength: [13, 16], cvvLength: [3], luhn: true, supported: true)
    
    public static let cards: [CardInfo] = [.MAESTRO, .MASTERCARD, .DINERSCLUB, .LASER, .JCB, .UNIONPAY, .DISCOVER, .AMEX, .VISA]
    
    public let name: String
    public let pattern: String
    public let format: String
    public let cardLength: [Int]
    public let cvvLength: [Int]
    public let luhn: Bool
    public let supported: Bool
    
    /**
    Default constructor
    
    @param name name of the card
    
    @param pattern regular expression matching the card's code
    
    @param format default card display format
    
    @param cardLength array containing all the possible lengths of the card's code
    
    @param cvvLength array containing all the possible lengths of the card's CVV
    
    @param luhn does the card's number respects the luhn validation or not
    
    @param supported is this card usable with Checkout services
    
    */
    private init(name: String, pattern: String, format: String, cardLength: [Int], cvvLength: [Int], luhn: Bool, supported: Bool) {
        self.name = name
        self.pattern = pattern
        self.format = format
        self.cardLength = cardLength
        self.cvvLength = cvvLength
        self.luhn = luhn
        self.supported = supported
    }
    
}

/*
Function used for testing purposes, returns true if the fields of both instances are identical
*/
public func ==(lhs: CardInfo, rhs: CardInfo) -> Bool {
    return lhs.format == rhs.format && lhs.pattern == rhs.pattern && lhs.luhn == rhs.luhn && lhs.supported == rhs.supported && lhs.name == rhs.name
}