//
//  XMComboBoxView.m
//  eReport
//
//  Created by Hung Do Manh on 5/21/13.
//  Copyright (c) 2013 Hung Do Manh. All rights reserved.
//

#import "XMComboBoxView.h"

//declare private methods here
@interface XMComboBoxView()
    - (void) filterData:(NSMutableArray*) captions data:(NSMutableArray*) data section:
    (NSMutableArray*) sections;


@end
@implementation XMComboBoxView
//@synthesize  textField, button, dropdownDelegate;

static UIImage* buttonImage;
+ (void) setButtonImage:(NSString*) imageName{
    if( imageName){
        buttonImage = [UIImage imageNamed:imageName];
    }else{
        NSLog(@"Combobox button image is nil");
    }
}

-(id) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        copyListOfItems = [[NSMutableArray alloc] init];
    }
    return self;
    
}

- (void) filterData:(NSMutableArray*) captions data:(NSMutableArray*) data section:
(NSMutableArray*) sections{
    self.titleArray = captions;
    if( data)
        self.valueArray = data;
    else
        self.valueArray = captions;
    
   // NSLog(@"sections not used for combobox");

    [self.dropdownTable reloadData];//TEST
}

- (void) loadData:(NSMutableArray*) captions data:(NSMutableArray*) data section:
(NSMutableArray*) sections{
    
    ///used for search later
    arrData = captions; //cache here to rollback after search
    [self filterData:captions data:data section:sections];
    if(titleArray && [titleArray count] > 0){
        [self setSelectedRow:0];//TODO test current to row 0
    }

}



-(void)makeMenu:(UIView *)targetView andIdentifier:(NSString*) identifier
        caption:(NSMutableArray *)captions data:(NSMutableArray*)data section:(NSMutableArray*) sections{

//    [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"pill_combo_txt_bkg_533x59"]]];
    CGRect frame = self.frame;
    
  //  NSLog(@"original size- x:%f y:%f w:%f h:%f",frame.origin.x, frame.origin.y ,frame.size.width, frame.size.height);
    if( frame.size.width > CMB_BUTTON_WIDTH){
        [self setFrame: frame];
        
        CGRect textFieldFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width - CMB_BUTTON_WIDTH, frame.size.height);
        //Create the text view

        selectedTextField = [[UITextField alloc] initWithFrame: textFieldFrame];
        selectedTextField.borderStyle = UITextBorderStyleRoundedRect;
        selectedTextField.font = FONT_DEFAULT;
        selectedTextField.textColor =FONT_COLOR_DEFAULT;
//        textField.placeholder = @"enter text";
        selectedTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        selectedTextField.keyboardType = UIKeyboardTypeDefault;
        selectedTextField.returnKeyType = UIReturnKeyDone;
        selectedTextField.clearButtonMode = UITextFieldViewModeNever;
        selectedTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
//        [[NSNotificationCenter defaultCenter]
//         addObserver:self
//         selector:@selector(textFieldDidChanged)
//         name:UITextFieldTextDidChangeNotification
//         object:selectedTextField];

        [selectedTextField addTarget:self action:@selector(textFieldDidChanged) forControlEvents:UIControlEventEditingChanged];
        
        //dont process uitextfield here.
//        selectedTextField.delegate = self;
        //Resize the button
        CGRect cmbBtnFrame = CGRectMake(frame.origin.x + frame.size.width - CMB_BUTTON_WIDTH -5, frame.origin.y ,
                                        CMB_BUTTON_WIDTH, selectedTextField.frame.size.height -1);
        
        
        
        selectedButton = [[UIButton alloc]initWithFrame: cmbBtnFrame];
        //and clear the title
        [selectedButton.titleLabel setText:@""];
        
        if(!buttonImage){
             buttonImage = [UIImage imageNamed:CMB_BUTTON_IMAGE];
        }
        
        [selectedButton setBackgroundImage: buttonImage forState:UIControlStateNormal];
        
        [selectedButton removeFromSuperview];
        
        [targetView addSubview: self]; // i am a view
        [targetView addSubview:selectedTextField];//add to the left
        [targetView addSubview:selectedButton];
    }
            
//    super = [[UIDropDownMenu alloc]initWithIdentifier: identifier];
    [self initWithIdentifier:identifier];
    
    self.ScaleToFitParent = NO;
    [self loadData:captions  data:data section:sections];
    [self makeMenu:selectedTextField targetView:targetView];
    self.menuWidth = frame.size.width;
    self.delegate = self;// handle select event
    
    
}



-(void) onDropListSelected:(NSString*)identifier selectedValue:(NSString*) string{
   // NSLog(@"ComboBoxButton-menu:%@ selected:%@", identifier, string);
    if( targetObject == selectedButton)
        [selectedButton setTitle:string forState:UIControlStateNormal];
    if( targetObject == selectedTextField){
        selectedTextField.text = string;
        selectedValue = string;
    }
    //callback
    if(delegate){
        if([delegate respondsToSelector:@selector(DropDownMenuDidChange:selectedString:)]){
            [delegate DropDownMenuDidChange:identifier selectedString:string];
        }else{
           // NSLog(@"ComboBoxButton's delegate does not respond to ComboBoxMenuDidChange:identifier");
        }
    }else{
        NSLog(@"ComboBox doesnot have delegate");
    }
}
//- (BOOL) textField: (UITextField *) textField shouldChangeCharactersInRange: (NSRange) range replacementString: (NSString *) string{
//    NSMutableString *searchText = [NSMutableString stringWithString:textField.text];
//    
//    if (range.length > 0)
//    {
//        // We're deleting
//        //searchText is the text after delete
//        searchText = [searchText stringByReplacingCharactersInRange:range withString:string];
//    }
//    else
//    {
//        // We're adding
//        [searchText appendString:string];
//    }
//
//    
//    NSLog(@"text:%@", searchText);
//    if( [searchText length] > 3) return NO;
//    //Remove all objects first.
//    [copyListOfItems removeAllObjects];
//    
//    if([searchText length] > 0) {
//        //filter the data
//        [self searchTableView: searchText];
//    }
//    else {
//        //search nothing, set all data
//        [self loadData:arrData data:arrData section:nil];
//    }
//    
//    [self.dropdownTable reloadData];
//    [self  showMenu: nil];
//
//    
//    return YES;
//}
/*
- (void) searchTableView:(NSString*)textToSearch {
    
    NSString *searchText = textToSearch;
    NSMutableArray *searchArray = [[NSMutableArray alloc] init];
    
    if( [searchText length] > 0){
        for (NSString *sTemp in arrData)
        {
            NSRange titleResultsRange = [sTemp rangeOfString:searchText options:NSCaseInsensitiveSearch];
            
            if (titleResultsRange.length > 0)
                [copyListOfItems addObject:sTemp];
        }
        //hungdm set new data
        [self filterData:copyListOfItems data:copyListOfItems section:nil];
    }else{
        //never reachs here
        
        [self filterData:arrData data:arrData section:nil];
    }
    
}
*/
-(void) textFieldDidChanged{
    NSMutableString *searchText = [NSMutableString stringWithString:selectedTextField.text];
    //Remove all objects first.
    [copyListOfItems removeAllObjects];
    
    if([searchText length] > 0) {
        //filter the data
        
        if( [searchText length] > 0){
            for (NSString *sTemp in arrData)
            {
                NSRange titleResultsRange = [sTemp rangeOfString:searchText options:NSCaseInsensitiveSearch];
                
                if (titleResultsRange.length > 0)
                    [copyListOfItems addObject:sTemp];
            }
            //hungdm set new data
            [self filterData:copyListOfItems data:copyListOfItems section:nil];
        }else{
            //never reachs here
            
            [self filterData:arrData data:arrData section:nil];
        }

    }
    else {
        //search nothing, set all data
        [self filterData:arrData data:arrData section:nil];
    }
    
    [self.dropdownTable reloadData];
    [self dismissMenu];
    [self  showMenu: nil];
    
}

/*
 * set current text for text box by a row
 */
-(void) setSelectedRow:(NSInteger)row{
    if(titleArray && [titleArray count] > row){
        self.selectedValue = titleArray[row];
        self.selectedTextField.text = selectedValue;
     
        //callback, trigger
        if(delegate){
            if([delegate respondsToSelector:@selector(DropDownMenuDidChange:selectedString:)]){
                [delegate DropDownMenuDidChange:self.identifiername selectedString:selectedValue];
            }else{
               // NSLog(@"ComboBoxButton's delegate does not respond to ComboBoxMenuDidChange:identifier");
            }
        }else{
           // NSLog(@"ComboBox doesnot have delegate");
        }

    }
}


-(NSString*) getSelectedText{
    return selectedValue;
}


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return NO;  // Hide both keyboard and blinking cursor.
}
@end
