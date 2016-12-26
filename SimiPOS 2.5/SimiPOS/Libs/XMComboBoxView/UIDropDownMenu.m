//
//  UIDropDownMenu.m
//  DropDownMenu
//
//  Created on 30/03/2012.
//  Updated by Add Image on 17/01/2013.
//  Copyright (c) 2013 Add Image
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//

#import "UIDropDownMenu.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIDropDownMenu
@synthesize dropdownTable, parentView, singleTapGestureRecogniser, targetObject, selectedTextField, selectedButton, titleArray, valueArray, ScaleToFitParent, selectedValue, menuWidth, delegate, textColor, backgroundColor, borderColor, identifiername, rowHeight;


UIInterfaceOrientation orientation;



- (id) initWithIdentifier:(NSString *)identifier
{
    if (self = [super init])
    {
        self.identifiername = identifier;
        
        // set initial size and styles
        self.ScaleToFitParent = FALSE;
        self.menuWidth = 100;
        self.rowHeight = 40;
        
        self.textColor = [UIColor blackColor];
        self.backgroundColor = [UIColor whiteColor];
        self.borderColor = [UIColor grayColor];

        // initialize the table and arrays
        self.titleArray = [[NSMutableArray alloc] init];
        self.valueArray = [[NSMutableArray alloc] init];
        
        CGRect frame = CGRectMake(0, 0, 100, 100);
        self.dropdownTable = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        self.dropdownTable.hidden = true;
        self.dropdownTable.delegate = self;
        self.dropdownTable.dataSource = self;
        self.dropdownTable.layer.cornerRadius = 10;    
        self.dropdownTable.layer.borderWidth = 1;   
        self.dropdownTable.layer.borderColor = [borderColor CGColor];
        self.dropdownTable.backgroundColor = backgroundColor;    
        
        //both textfield and button
        components = COMPONENT_TEXTFIELD_BUTTON;
        
        self.selectedTextField.delegate=self;
    }
    return self;
}

#pragma mark - Khong cho phep bam hien thi menu dropdownlist
-(void)disableDropDownMenu{
    
    [self.selectedTextField removeTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchDown];
    [self.selectedButton removeTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchDown];
}

-(void)makeMenu:(NSObject *)targetObj targetView:(UIView *)tview;
{
//    if (titleArray != nil && valueArray != nil){
    
        
        self.targetObject = targetObj;
    
        // create a UITextField instance and assign it to the source text field
        /*
        if ([targetObject isKindOfClass:[UITextField class]]){
            //TODO uncomment it
//            self.selectedTextField = [[UITextField alloc] init];
            self.selectedTextField = (UITextField *)targetObject;
            //TODO uncoment it
//            self.selectedTextField.delegate = self;
            [self.selectedTextField addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchDown];
        }
         */
        if( selectedTextField){
            [self.selectedTextField addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchDown];

        }
        /*
        // if the targetObject is a button then create a UIButton instance and assign it to the source button
        if ([targetObject isKindOfClass:[UIButton class]]){
//            self.selectedButton = [[UIButton alloc] init];
            self.selectedButton = (UIButton *)targetObject;
            [self.selectedButton addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchDown];
        }
        */
        if( selectedButton ){
            [self.selectedButton addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchDown];
        }
        // set the colors for the tableview
        self.dropdownTable.layer.borderColor = [borderColor CGColor];
        self.dropdownTable.backgroundColor = backgroundColor;
       
      
        // create a UIView instance and assign it to the target view
//        self.parentView = [[UIView alloc] initWithFrame:tview.frame];
        self.parentView = tview;
        
        // Get the current device orientation
        orientation = [[UIApplication sharedApplication] statusBarOrientation];
        [self.dropdownTable reloadData];
        [self.parentView addSubview:self.dropdownTable];
        
//    }
    
}


-(void)showMenu:(id)sender{
    [dropdownTable reloadData]; // reload cho chac cu. fix loi chi select duoc 1 lan
        //try to display on top
        [parentView bringSubviewToFront: dropdownTable];
        // Add an observer to remove the menu if the device orientation changes
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(didChangeOrientation:) name: UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
        
        // add touch detection on parent view, this will allow the menu to dissapear when the user touches outside of the menu.
        singleTapGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
        singleTapGestureRecogniser.numberOfTapsRequired = 1;
        singleTapGestureRecogniser.delegate = self;
        [self.parentView addGestureRecognizer:singleTapGestureRecogniser];
     
        // set the size and position of the menu
        // if the device is an iPad the menu will be sized to the same width and position as the target text field, 
        // if the device is an iPhone or iPod touch the menu is set to fill the screen.
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            // Device is an iPad
            
            int screenheight =  screenheight = parentView.frame.size.height;
                 
            int tableheight = 0;
            int objectheight = 0;
            int tablewidth = 0;
            int tableOriginX = 0;
            int tableOriginY = 0;
            
            if ([targetObject isKindOfClass:[UITextField class]]
//                || //hungdm support uiview
//                [targetObject isKindOfClass:[UIView class]]
//                || //hungdm support UISearchBar 11/06
//                [targetObject isKindOfClass:[UISearchBar class]]
                ){
                // set the frame width to match the target object width if ScaleToFitParent is true, otherwise set to Width variable
                if (ScaleToFitParent){
                    tablewidth = self.selectedTextField.frame.size.width;
                }
                else{
                    tablewidth = menuWidth;
                }
                
                // set the frame origin (if the x origin puts the menu off the side of the screen then right align instead) 
                tableOriginY = self.selectedTextField.frame.origin.y;
                objectheight = self.selectedTextField.frame.size.height;
                
                if ((tablewidth + self.selectedTextField.frame.origin.x) < parentView.frame.size.width){
                    tableOriginX = self.selectedTextField.frame.origin.x;
                }
                else{
                    tableOriginX = (self.selectedTextField.frame.origin.x - tablewidth) + self.selectedTextField.frame.size.width;
                }
                
                
            }
            
            if ([targetObject isKindOfClass:[UIButton class]]){
                
                
                // set the frame origin (if the x origin puts the menu off the side of the screen then right align instead)+
                tablewidth = menuWidth;
                tableOriginY = self.selectedButton.frame.origin.y;
                objectheight = self.selectedButton.frame.size.height;

                if ((tablewidth + self.selectedButton.frame.origin.x) < parentView.frame.size.width){
                    //TODO add more condition here before -menuWidth
                    tableOriginX = self.selectedButton.frame.origin.x - menuWidth + self.selectedButton.frame.size.width;
                }
                else{
                    tableOriginX = (self.selectedButton.frame.origin.x - tablewidth) + self.selectedButton.frame.size.width;
                }
            
            }
            
//            if (((tableOriginX + objectheight) + ([titleArray count] * rowHeight)) >= parentView.frame.size.height - rowHeight){
            if (((tableOriginY + objectheight) + ([titleArray count] * rowHeight)) >= parentView.frame.size.height - rowHeight){
                tableheight = screenheight - rowHeight - (tableOriginX + objectheight);
                
                // enable scrolling and bounce
                self.dropdownTable.scrollEnabled = YES;
            }
            else{
                tableheight = (int)([titleArray count] * rowHeight);
                //hungdm modified on 00:50 12/06
                if( tableheight < rowHeight){
                    tableheight = rowHeight;
                }
                //hungdm end.
                // disable scrolling and bounce
                self.dropdownTable.scrollEnabled = NO;
            }
            
            //set background for table
            // TODO
//            [dropdownTable setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bkg_black_leather_324x484"]] ];
            //Drop down the table
            dropdownTable.frame = CGRectMake(tableOriginX, tableOriginY, tablewidth, objectheight);
            
            tableheight = (int)([titleArray count] * rowHeight);
            
            [UIView beginAnimations:@"slide down" context:NULL];
            [UIView setAnimationDuration:0.3];
            self.dropdownTable.hidden = false;
            self.dropdownTable.frame = CGRectMake(tableOriginX, tableOriginY + objectheight, tablewidth, tableheight);
//            NSLog(@"dropdown- x:%d y:%d w:%d h:%d",tableOriginX, tableOriginY + objectheight, tablewidth, tableheight);

            [UIView commitAnimations];
        
//            [UIView beginAnimations:@"slide up" context:NULL];
//            [UIView setAnimationDuration:0.2];
//            self.dropdownTable.hidden = false;
//            self.dropdownTable.frame = CGRectMake(tableOriginX, tableOriginY + objectheight, tablewidth, tableheight);
//            NSLog(@"dropdown- x:%d y:%d w:%d h:%d",tableOriginX, tableOriginY + objectheight, tablewidth, tableheight);
//            
//            [UIView commitAnimations];
        }
        else{
            // Device is an iPhone or iPod Touch
           
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            self.dropdownTable.frame = screenRect;
            
            // ensure autosizing enabled
            self.dropdownTable.autoresizesSubviews = YES;
            [self.dropdownTable setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];

            
            self.dropdownTable.alpha = 0.0;
            
            [UIView beginAnimations:@"Zoom" context:NULL];
            [UIView setAnimationDuration:0.3];        
            self.dropdownTable.hidden = false;
            self.dropdownTable.alpha = 1.0;
            [UIView commitAnimations];
            self.dropdownTable.scrollEnabled = YES;
            self.dropdownTable.bounces = YES;
        }
        
        

}





-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    // Hide both keyboard and blinking cursor.    
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    
    if ([touch.view isDescendantOfView:self.dropdownTable]) {        
        // Don't let gesture recognizer fire if the table was touched
        return NO;
    }
    else{
        [self dismissMenu];
        return YES;
    }    
}

- (void) didChangeOrientation:(NSNotification *)notification
{
    // remove the menu on rotation
    if (orientation != [[UIApplication sharedApplication] statusBarOrientation]){
        orientation = [[UIApplication sharedApplication] statusBarOrientation];
        [self dismissMenu];
    }
}


-(void)dismissMenu{
    // remove the tap guesture recognizer and hide the menu

    [self.parentView removeGestureRecognizer:singleTapGestureRecogniser];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    self.dropdownTable.hidden = true;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (titleArray.count > 0){
        return titleArray.count;
    }
    else{
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];  
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    cell.textLabel.text = [titleArray objectAtIndex:row];
    cell.textLabel.font =  FONT_DEFAULT;//[UIFont systemFontOfSize:17.0];
    cell.textLabel.textColor = FONT_COLOR_DEFAULT; //textColor;
    return cell;
}

#pragma mark - Table view delegate
//HungDM add on 11/06 to support searcBar
//- (NSIndexPath *)tableView :(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    if( allowSelectRow){
//        return indexPath;
//    }
//    
//    //not allowed to select
//    return nil;
//}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    selectedValue = [valueArray objectAtIndex:row];
    //call the virtual function to ask what to do on this event
   // NSLog(@"Clicked::%@", selectedValue);
    [self onDropListSelected:identifiername selectedValue:selectedValue];

    
    // fade out menu
    self.dropdownTable.alpha = 1.0;
    [UIView beginAnimations:@"Ending" context:NULL];
    [UIView setAnimationDuration:0.3];  
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(FadeOutComplete)];
    self.dropdownTable.hidden = false;
    self.dropdownTable.alpha = 0.0;    
    [UIView commitAnimations];
}

- (void)FadeOutComplete{
    self.dropdownTable.alpha = 1.0;
    [self dismissMenu];
}



-(void) setFrame:(CGRect)frame{
    [super setFrame: frame];
    [self setBackgroundColor:[UIColor clearColor]];
    if( frame.size.width > CMB_BUTTON_WIDTH){
        if(  components == COMPONENT_BUTTON){
            selectedButton.frame = frame;
            selectedButton.hidden = NO;
            
            selectedTextField.hidden = YES;
        }
        
        //if only text field is selected
        if( components == COMPONENT_TEXTFIELD){
            CGRect textFieldFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
            [selectedTextField setFrame: textFieldFrame];
            selectedTextField.hidden = NO;
            
                //hide it
                selectedButton.hidden = YES;

        }
        
        //if both
        if( components == COMPONENT_TEXTFIELD_BUTTON){
            selectedTextField.hidden = NO;
            selectedButton.hidden = NO;
            
            if(selectedButton){
                CGRect textFieldFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width - CMB_BUTTON_WIDTH, frame.size.height);
                [selectedTextField setFrame: textFieldFrame];
                //Resize the button
                CGRect cmbBtnFrame = CGRectMake(frame.origin.x + frame.size.width - CMB_BUTTON_WIDTH -5 , frame.origin.y ,
                                                CMB_BUTTON_WIDTH, selectedTextField.frame.size.height -1);
                [selectedButton setFrame: cmbBtnFrame];
                
            }else{
                CGRect textFieldFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
                [selectedTextField setFrame: textFieldFrame];
            }
        }
    }
    
}


-(void) layoutCombobox:(NSInteger) componentNew{
    if( componentNew == COMPONENT_TEXTFIELD || componentNew == COMPONENT_BUTTON || componentNew == COMPONENT_TEXTFIELD_BUTTON){
        CGRect frame = self.frame;
        
        components = componentNew;
        [self setFrame:frame];
    }else{
       // NSLog(@"Invalid components:%d", componentNew);
    }
}

-(void) setText:(NSString*) text{
    selectedValue = text;
    selectedTextField.text = text;
}

-(NSString*) getText{
    return selectedTextField.text;
}
-(void) setButtoneTittle:(NSString*) text{
    [selectedButton setTitle:text forState:UIControlStateNormal];
}

//Chiennd
#pragma  mark - Thuộc tính có cho phép sửa textbox không
-(void)setEnable:(BOOL) isEnable{
 
    [selectedTextField setEnabled:isEnable];
    
//    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showComboBoxDateOfFlight)];
//    [self addGestureRecognizer:tap];

}

#pragma mark -Hiển thị Menu ComboBox khi User Tap
-(void)showComboBoxDateOfFlight{
    [self showMenu:nil];
}

-(void)hideDropDownMenu{
    
    [self dismissMenu];
    
    [self setEnable:NO];
    
    selectedTextField.hidden=YES;
    selectedButton.hidden =YES;
}

-(void)showDropDownMenu{
    
    [self setEnable:YES];
    
    selectedTextField.hidden=NO;
    selectedButton.hidden =NO;
}

-(void) onDropListSelected:(NSString*)identifier selectedValue:(NSString*) string{
    
}
@end
