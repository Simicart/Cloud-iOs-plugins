//
//  Log.swift
//  CheckoutKit
//
//  Created by Manon Henrioux on 24/08/2015.
//
//

import Foundation

/** Class used to log activity in the console */

public class Log {
    private static let PATTERN_COMPACT_PRINT: String = "[\\n\\s]+"
    private static var log: Log? = nil
    
    /**
    Default constructor
    */
    private init() {}
    
    /**
    
    Function used for the Singleton Pattern, returns a unique Log instance

    */
    public class func getLog() -> Log {
        if (log == nil) {
            log = Log()
        }
        return log!
    }
    
    /**
    
    Prints an information message in the console and when it occurred
    
    @param message String containing the message to log
    
    */
    
    public func info(message: String) -> Void {
        printDate()
        let msg = Regex(pattern: Log.PATTERN_COMPACT_PRINT).replace(message, template: " ")
        print("INFO: \(msg)")
    }
    
    /**
    
    Prints a warning message in the console and when it occurred
    
    @param message String containing the message to log
    
    */
    
    public func warn(message: String) -> Void {
        printDate()
        let msg = Regex(pattern: Log.PATTERN_COMPACT_PRINT).replace(message, template: " ")
        print("WARNING: \(msg)")
    }
    
    /**
    
    Prints an error message in the console and when it occurred
    
    @param message String containing the message to log
    
    */
    
    public func error(message: String) -> Void {
        printDate()
        let msg = Regex(pattern: Log.PATTERN_COMPACT_PRINT).replace(message, template: " ")
        print("ERROR: \(msg)")
        
    }
    
    /*
    
    Private method used to print the current date in the console
    
    */
    
    private func printDate() -> Void {
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        print(formatter.stringFromDate(date))
    }
}
