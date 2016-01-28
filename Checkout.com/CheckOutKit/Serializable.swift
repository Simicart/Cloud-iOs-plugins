//
//  Serializable.swift
//  CheckoutKit
//
//  Created by Manon Henrioux on 14/08/2015.
//  Copyright (c) 2015 Checkout.com. All rights reserved.
//

import Foundation

/** Protocol implemented by all the classes that can be represented as JSON objects or strings */

public protocol Serializable {
    
    init?(data: [String : AnyObject])
}
