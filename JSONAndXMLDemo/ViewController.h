//
//  ViewController.h
//  JSONAndXMLDemo
//
//  Created by Gabriel Theodoropoulos on 24/7/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface ViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate,NSXMLParserDelegate>


@property (nonatomic, strong) NSXMLParser *xmlParser;
@property (nonatomic, strong) NSMutableArray *arrNeighboursData;
@property (nonatomic, strong) NSMutableDictionary *dictTempDataStorage;
@property (nonatomic, strong) NSMutableString *foundValue;
@property (nonatomic, strong) NSString *currentElement;




@property (weak, nonatomic) IBOutlet UITextField *txtCountry;

@property (weak, nonatomic) IBOutlet UITableView *tblCountryDetails;

@property (weak, nonatomic) IBOutlet UILabel *lblCountry;


- (IBAction)sendJSON:(id)sender;
-(void)getCountryInfo;





@end
