//
//  Error.swift
//  CheckoutKit
//
//  Created by Manon Henrioux on 20/08/2015.
//
//

import Foundation

/** Custom errors used for validation errors */

public enum CardError: ErrorType {
    case InvalidNumber
    case InvalidCVV
    case InvalidExpiryDate

    var desc: String
        {
            switch self
            {
            case .InvalidNumber: return "Invalid card number"
            case .InvalidCVV: return "Invalid CVV"
            case .InvalidExpiryDate: return "Invalid expiry date"
            }
    }
}

public enum CheckoutError: ErrorType {
    case InvalidPK
    case NoPK
    
    var desc: String
        {
            switch self
            {
            case .InvalidPK: return "Invalid public key"
            case .NoPK: return "No public key has been set"
            }
    }
}