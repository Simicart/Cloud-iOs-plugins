//
//  Error.swift
//  CheckoutKit
//
//  Created by Manon Henrioux on 20/08/2015.
//
//

import Foundation

/** Custom errors used for validation errors */

public enum CardError: String {
    case InvalidNumber = "Invalid card number"
    case InvalidCVV = "Invalid CVV"
    case InvalidExpiryDate = "Invalid expiry date"
}

public enum CheckoutError: String {
    case InvalidPK = "Invalid public key"
    case NoPK = "No public key has been set"
}