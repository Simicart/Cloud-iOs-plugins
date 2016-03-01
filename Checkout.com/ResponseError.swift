//
//  ResponseError.swift
//  CheckoutKit
//
//  Created by Manon Henrioux on 13/08/2015.
//  Copyright (c) 2015 Checkout.com. All rights reserved.
//

import Foundation

/** Class used to represent a error returned by the server after a request has failed. It contains all the information relative to this error/failure. */

public class ResponseError<T: Serializable> {
    public var errorCode: String
    public var message: String
    public var errors: [String]
    
    
    /**
    
    Default constructor used by Gson to build the response automatically based on JSON data
    
    @param errorCode String containing the error code if an error occurred
    
    @param message String containing the message describing the error
    
    @param errors Array of String containing more information on the errors that occurred
    
    */
    
    public init(errorCode: String, message: String, errors: [String]) {
        self.errorCode = errorCode;
        self.message = message;
        self.errors = errors;
    }
    
    /**
    
    Convenience constructor
    
    @param data: Dictionary [String: AnyObject] containing a JSON representation of a ResponseError instance
    
    */
    
    public required init?(data: [String: AnyObject]) {
        
        if let code = data["errorCode"] as? String, msg = data["message"] as? String {
            self.errorCode = code
            self.message = msg
            if let errorsData = data["errors"] as? [String] {
            self.errors = errorsData
            } else {
                self.errors = []
            }
        } else {
            self.errorCode = ""
            self.message = ""
            self.errors = []
            return nil
        }
    }

}