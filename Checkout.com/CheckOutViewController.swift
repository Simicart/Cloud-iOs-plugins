//
//  CheckOutViewController.swift
//  SimiCartPluginFW
//
//  Created by Vu Thanh Do on 1/27/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

import UIKit

class CheckOutViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate {

    var simiCheckOutModel : SimiCheckOutModel!
    var pickerContent: [[String]] = []
    let months = [1,2,3,4,5,6,7,8,9,10,11,12]
    let years = [2015,2016,2017,2018,2019,2020,2021,2022,2023,2024,2025]
    var month = "1"
    var year = "2015"
    let errorColor = UIColor(red: 204.0/255.0, green: 112.0/255.0, blue: 115.0/255.0, alpha: 0.3)
    var publishKey : NSString!
    var orderData : SimiOrderModel!
    // UIField
    var doneButton = UIButton()
    var nameField = UITextField()
    var numberField = UITextField()
    var cvvField = UITextField()
    var datePicker = UIPickerView()
    var dateField = UITextField()
    var cardTokenButton = UIButton()
    
    var datePickerButton = UIButton()
    var nameLb = UILabel()
    var creditCardNumberLb = UILabel()
    var expiryDateLb = UILabel()
    var cvvLb = UILabel()
    
    var edittingTf = UITextField()
    var loadingView = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameField.delegate = self
        self.numberField.delegate = self
        self.dateField.delegate = self
        self.cvvField.delegate = self
        
        self.view.addSubview(nameField)
        self.view.addSubview(numberField)
        self.view.addSubview(datePicker)
        self.view.addSubview(dateField)
        self.view.addSubview(cardTokenButton)
        self.view.addSubview(doneButton)
        self.view.addSubview(nameLb)
        self.view.addSubview(creditCardNumberLb)
        self.view.addSubview(expiryDateLb)
        self.view.addSubview(cvvLb)
        self.view.addSubview(cvvField)
        self.view.addSubview(datePickerButton)
        
        
        pickerContent.append([])
        for (var m = 0 ; m < months.count ; m++) {
            pickerContent[0].append(months[m].description)
        }
        pickerContent.append([])
        for (var y = 0 ; y < years.count ; y++) {
            pickerContent[1].append(years[y].description)
        }
        self.datePicker.delegate = self
        self.datePicker.hidden = true
        self.doneButton.hidden = true
        self.cardTokenButton.hidden = false
        self.nameField.text = "VU THANH DO"
        self.numberField.text = "4221498672015477"
        self.dateField.text = "10 / 2019"
        self.cvvField.text = "285"
        self.month = "10"
        self.year = "2019"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.dateField.enabled = false
        self.datePickerButton.addTarget(self, action: "dateFieldTouch", forControlEvents: UIControlEvents.TouchUpInside)
        self.title = "Check Out"
        self.view.backgroundColor = UIColor.groupTableViewBackgroundColor()
        // set view for subviews
        self.nameLb.frame = CGRectMake(10, 50, self.view.frame.width - 20, 30)
        self.nameLb.textColor = UIColor.darkGrayColor()
        self.nameLb.text = "Name"
        self.nameField.frame = CGRect(x: 10, y: nameLb.frame.origin.y + nameLb.frame.height + 10, width: self.view.frame.width - 20, height: 30)
        self.nameField.borderStyle = UITextBorderStyle.RoundedRect
        
        self.creditCardNumberLb.frame = CGRect(x: 10, y: nameField.frame.origin.y + nameField.frame.height + 10, width: self.view.frame.width - 20, height: 30)
        self.creditCardNumberLb.text = "Credit Card Number"
        self.creditCardNumberLb.textColor = UIColor.darkGrayColor()
        self.numberField.frame = CGRect(x: 10, y: creditCardNumberLb.frame.origin.y + creditCardNumberLb.frame.height + 10, width: self.view.frame.width - 20, height: 30)
        self.numberField.borderStyle = UITextBorderStyle.RoundedRect
        self.expiryDateLb.frame = CGRect(x: 10, y: numberField.frame.origin.y + numberField.frame.height + 10, width: (self.view.frame.width - 40) / 2, height: 30)
        self.expiryDateLb.text = "Expiry Date"
        self.expiryDateLb.textColor = UIColor.darkGrayColor()
        self.cvvLb.frame = CGRect(x: (self.view.frame.width - 40) / 2 + 30, y: numberField.frame.origin.y + numberField.frame.height + 10, width: (self.view.frame.width - 40) / 2, height: 30)
        self.cvvLb.text = "CVV"
        self.cvvLb.textColor = UIColor.darkGrayColor()
        
        self.dateField.frame = CGRect(x: 10, y: expiryDateLb.frame.origin.y + expiryDateLb.frame.height + 10, width: (self.view.frame.width - 40) / 2, height: 30)
        self.dateField.borderStyle = UITextBorderStyle.RoundedRect
        self.datePickerButton.frame = self.dateField.frame
        self.cvvField.frame = CGRect(x: (self.view.frame.width - 40) / 2 + 30, y: cvvLb.frame.origin.y + cvvLb.frame.height + 10, width: (self.view.frame.width - 40) / 2, height: 30)
        self.cvvField.borderStyle = UITextBorderStyle.RoundedRect
        self.cardTokenButton.frame = CGRect(x: 10, y: cvvField.frame.origin.y + cvvField.frame.height + 20, width: self.view.frame.width - 20, height: 50)
        self.cardTokenButton.layer.cornerRadius = 5
        self.cardTokenButton.enabled = true
        self.cardTokenButton.addTarget(self, action: "getCardToken", forControlEvents: UIControlEvents.TouchUpInside)
        self.cardTokenButton.setTitle("Pay", forState: UIControlState.Normal)
        self.cardTokenButton.backgroundColor = UIColor.greenColor()
        self.cardTokenButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.doneButton.frame = CGRect(x: 10, y: self.view.frame.height - 120, width: self.view.frame.width - 20, height: 50)
        self.doneButton.layer.cornerRadius = 5
        self.doneButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.doneButton.setTitle("Done", forState: UIControlState.Normal)
        self.doneButton.backgroundColor = UIColor.blueColor()
        self.doneButton.addTarget(self, action: "doneButtonHandle", forControlEvents: UIControlEvents.TouchUpInside)
        self.datePicker.frame = CGRect(x: 0, y: self.view.frame.width - 100, width: self.view.frame.width, height: 150)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapRecognizer)
        
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
        datePicker.hidden = true
        doneButton.hidden = true
        cardTokenButton.hidden = false
        
    }
    
    func finishEdit(sender: AnyObject) {
        datePicker.hidden = true
        doneButton.hidden = true
        cardTokenButton.hidden = false
    }
    
    
    
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(pickerView: UIPickerView!) -> Int{
        return pickerContent.count
    }
    
    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int{
        return pickerContent[component].count
    }
    
    func pickerView(bigPicker: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        
        return pickerContent[component][row]
        
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if component == 0 { month = pickerContent[0][row] }
        else { year = pickerContent[1][row] }
        updateDate()
    }
    
    private func updateDate() {
        dateField.text = "\(month) / \(year)"
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.edittingTf = textField
        datePicker.hidden = true
        doneButton.hidden = true
        cardTokenButton.hidden = false
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        // Disable copy, select all, paste
        if action == Selector("copy:") || action == Selector("selectAll:") || action == Selector("paste:") {
            return false
        }
        // Default
        return super.canPerformAction(action, withSender: sender)
    }
    
    
    private func validateCardInfo(number: String, expYear: String, expMonth: String, cvv: String) -> Bool {
        var err: Bool = false
        resetFieldsColor()
        if (!CardValidator.validateCardNumber(number)) {
            err = true
            numberField.backgroundColor = errorColor
        }
        if (!CardValidator.validateExpiryDate(month, year: year)) {
            err = true
            dateField.backgroundColor = errorColor
        }
        if (cvv == "") {
            err = true
            cvvField.backgroundColor = errorColor
        }
        return !err
    }
    
    private func resetFieldsColor() {
        numberField.backgroundColor = UIColor.whiteColor()
        dateField.backgroundColor = UIColor.whiteColor()
        cvvField.backgroundColor = UIColor.whiteColor()
    }
    
    func doneButtonHandle() {
        self.edittingTf.resignFirstResponder()
        self.updateDate()
        datePicker.hidden = true
        doneButton.hidden = true
        cardTokenButton.hidden = false
    }
    
    func dateFieldTouch() {
        self.edittingTf.resignFirstResponder()
        datePicker.hidden = false
        doneButton.hidden = false
        cardTokenButton.hidden = true
    }
    
    /*
    - (void)startLoadingData{
    if (!simiLoading.isAnimating) {
    CGRect frame = self.view.frame;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && self.navigationController) {
    if (frame.size.width > self.navigationController.view.frame.size.width) {
    frame = self.navigationController.view.frame;
    }
    }
    
    simiLoading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    simiLoading.hidesWhenStopped = YES;
    simiLoading.center = CGPointMake(frame.size.width/2, frame.size.height/2);
    [self.view addSubview:simiLoading];
    self.view.userInteractionEnabled = NO;
    [simiLoading startAnimating];
    if (_didAppear) {
    self.view.alpha = 0.5;
    }
    }
    }
    
    - (void)stopLoadingData{
    self.view.userInteractionEnabled = YES;
    self.view.alpha = 1;
    [simiLoading stopAnimating];
    [simiLoading removeFromSuperview];
    }
    */
    
    func startLoading() {
        if loadingView.isAnimating() == false {
            let frame : CGRect = self.view.frame
            loadingView = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
            loadingView.hidesWhenStopped = true
            loadingView.center = CGPointMake(frame.size.width/2, frame.size.height/2)
            self.view.addSubview(loadingView)
            loadingView.startAnimating()
            self.view.alpha = 0.5
        }
    }
    
    func stopLoading() {
        self.view.userInteractionEnabled = true
        self.view.alpha = 1
        loadingView.stopAnimating()
        loadingView.removeFromSuperview()
    }
    
    func getCardToken() {
        // check empty
        if self.nameField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "" {
            self.nameField.backgroundColor = errorColor
            self.nameField.becomeFirstResponder()
            let alertView = UIAlertView(title: "Invalid Input", message: "Please input name.", delegate: nil, cancelButtonTitle: "OK")
            alertView.show()
            return
        }
        if self.numberField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "" {
            self.numberField.backgroundColor = errorColor
            self.numberField.becomeFirstResponder()
            let alertView = UIAlertView(title: "Invalid Input", message: "Please input card number.", delegate: nil, cancelButtonTitle: "OK")
            alertView.show()
            return
        }
        if self.dateField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "" {
            self.dateField.backgroundColor = errorColor
            self.dateField.becomeFirstResponder()
            let alertView = UIAlertView(title: "Invalid Input", message: "Please input expiry date.", delegate: nil, cancelButtonTitle: "OK")
            alertView.show()
            return
        }
        if self.cvvField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "" {
            self.cvvField.backgroundColor = errorColor
            self.cvvField.becomeFirstResponder()
            let alertView = UIAlertView(title: "Invalid Input", message: "Please input cvv number.", delegate: nil, cancelButtonTitle: "OK")
            alertView.show()
            return
        }
        self.cardTokenButton.enabled = false
        self.edittingTf.resignFirstResponder()
        self.startLoading()
        let ck = try? CheckoutKit.getInstance(publishKey as String)
        if ck == nil {
            self.cardTokenButton.enabled = true
            // alert error
        } else {
            if (validateCardInfo(numberField.text!, expYear: year, expMonth: month, cvv: cvvField.text!)) {
                resetFieldsColor()
                let card = try? Card(name: nameField.text, number: numberField.text!, expYear: year, expMonth: month, cvv: cvvField.text!, billingDetails: nil);
                if card == nil {
                    self.cardTokenButton.enabled = true
                    self.stopLoading()
                    print("card nil")
                    let alertView = UIAlertView(title: "Error", message: "Card not exist, Please input another card", delegate: nil, cancelButtonTitle: "OK")
                    alertView.show()
                    // alert card not exist
                } else {
                    ck!.createCardToken(card!, completion:{ (resp: Response<CardTokenResponse>) -> Void in
                        if (resp.hasError) {
                            // alert error
                            let alertView = UIAlertView(title: "Error", message: "Create Card Token Fail, please try again.", delegate: nil, cancelButtonTitle: "OK")
                            alertView.show()
                        } else {
                            // do when success
                            let param  = ["order_id" : self.orderData.objectForKey("_id") as! String, "cart_token" : resp.model!.cardToken]
                            self.simiCheckOutModel.createCheckOutPaymentWithParam(param)
                        }
                        self.cardTokenButton.enabled = true
                    })
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
}
