//
//  ViewController.m
//  JSONAndXMLDemo
//
//  Created by Gabriel Theodoropoulos on 24/7/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "NeighboursViewController.h"


@interface ViewController ()

@property (nonatomic, strong) NSArray *arrCountries;

@property (nonatomic, strong) NSArray *arrCountryCodes;

@property (nonatomic, strong) NSString *countryCode;

@property (nonatomic, strong) NSDictionary *countryDetailsDictionary;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Make self the delegate of the textfield.
    self.txtCountry.delegate = self;
    
    // Make self the delegate and datasource of the table view.
    self.tblCountryDetails.delegate = self;
    self.tblCountryDetails.dataSource = self;
    
    // Initially hide the table view.
    self.tblCountryDetails.hidden = YES;
    
    
    // Load the contents of the two .txt files to the arrays.
    NSString *pathOfCountriesFile = [[NSBundle mainBundle] pathForResource:@"countries" ofType:@"txt"];
    NSString *pathOfCountryCodesFile = [[NSBundle mainBundle] pathForResource:@"countries_short" ofType:@"txt"];
    
    NSString *allCountries = [NSString stringWithContentsOfFile:pathOfCountriesFile encoding:NSUTF8StringEncoding error:nil];
    self.arrCountries = [[NSArray alloc] initWithArray:[allCountries componentsSeparatedByString:@"\n"]];
    
    NSString *allCountryCodes = [NSString stringWithContentsOfFile:pathOfCountryCodesFile encoding:NSUTF8StringEncoding error:nil];
    self.arrCountryCodes = [[NSArray alloc] initWithArray:[allCountryCodes componentsSeparatedByString:@"\n"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
}


#pragma mark - UITextFieldDelegate method implementation

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    // Find the index of the typed country in the arrCountries array.
    NSInteger index = -1;
    for (NSUInteger i=0; i<self.arrCountries.count; i++) {
        NSString *currentCountry = [self.arrCountries objectAtIndex:i];
        if ([currentCountry rangeOfString:self.txtCountry.text.uppercaseString].location != NSNotFound) {
            index = i;
            break;
        }
    }
    
    // Check if the given country was found.
    if (index != -1) {
        // Get the two-letter country code from the arrCountryCodes array.
        self.countryCode = [self.arrCountryCodes objectAtIndex:index];
//        [self getDictionaryFromJSON];
        [self getDictionaryFromXML];
    }
    else{
        // If the country was not found then show an alert view displaying a relevant message.
        [[[UIAlertView alloc] initWithTitle:@"Country Not Found" message:@"The country you typed in was not found." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Done", nil] show];
    }
    
    // Hide the keyboard.
    [self.txtCountry resignFirstResponder];
    
    return YES;
}


#pragma mark - UITableView method implementation

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 6) {
        [self performSegueWithIdentifier:@"idSegueNeighbours" sender:self];
    }
}


#pragma mark - IBAction method implementation

- (IBAction)sendJSON:(id)sender {
    
}



-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    if (error != nil) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - JSON Parsing
-(void)getDictionaryFromJSON{
    // Prepare the URL that we'll get the country info data from.
    NSString *URLString = [NSString stringWithFormat:@"http://api.geonames.org/countryInfoJSON?username=%@&country=%@", kUsername, self.countryCode];
    NSURL *url = [NSURL URLWithString:URLString];
    
    [AppDelegate downloadDataFromURL:url withCompletionHandler:^(NSData *data) {
        // Check if any data returned.
        if (data != nil) {
            NSError *error;
            NSMutableDictionary *returnedDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            if (error != nil) {
                NSLog(@"%@", [error localizedDescription]);
            }
            else{
                NSLog(@"%@", returnedDict);
            
            }
        }
    }];
    
    
}

#pragma mark - XML Parsing
-(void)getDictionaryFromXML{
    // Prepare the URL that we'll get the neighbour countries from.
    NSString *URLString = [NSString stringWithFormat:@"http://api.geonames.org/neighbours?geonameId=1282588&username=%@",  kUsername];
    
    NSURL *url = [NSURL URLWithString:URLString];
    
    // Download the data.
    [AppDelegate downloadDataFromURL:url withCompletionHandler:^(NSData *data) {
        // Make sure that there is data.
        if (data != nil) {
            self.xmlParser = [[NSXMLParser alloc] initWithData:data];
            self.xmlParser.delegate = self;
            
            // Initialize the mutable string that we'll use during parsing.
            self.foundValue = [[NSMutableString alloc] init];
            
            // Start parsing.
            [self.xmlParser parse];
        }
    }];
}


#pragma mark - XML delegate


-(void)parserDidStartDocument:(NSXMLParser *)parser{
    // Initialize the neighbours data array.
    self.arrNeighboursData = [[NSMutableArray alloc] init];
}

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    // When the parsing has been finished then simply reload the table view.
    //UI changes
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    NSLog(@"%@", [parseError localizedDescription]);
}
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    
    // If the current element name is equal to "geoname" then initialize the temporary dictionary.
    if
        ([elementName isEqualToString:@"geoname"]) {
        self.dictTempDataStorage = [[NSMutableDictionary alloc] init];
    }
    
    // Keep the current element.
    self.currentElement = elementName;
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
    if ([elementName isEqualToString:@"geoname"]) {
        // If the closing element equals to "geoname" then the all the data of a neighbour country has been parsed and the dictionary should be added to the neighbours data array.
        [self.arrNeighboursData addObject:[[NSDictionary alloc] initWithDictionary:self.dictTempDataStorage]];
    }
    else if ([elementName isEqualToString:@"name"]){
        // If the country name element was found then store it.
        [self.dictTempDataStorage setObject:[NSString stringWithString:self.foundValue] forKey:@"name"];
    }
    else if ([elementName isEqualToString:@"toponymName"]){
        // If the toponym name element was found then store it.
        [self.dictTempDataStorage setObject:[NSString stringWithString:self.foundValue] forKey:@"toponymName"];
    }
    
    NSLog(@"Dict %@",self.dictTempDataStorage);
    // Clear the mutable string.
    [self.foundValue setString:@""];
}
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    // Store the found characters if only we're interested in the current element.
    if ([self.currentElement isEqualToString:@"name"] ||
        [self.currentElement isEqualToString:@"toponymName"]) {
        
        if (![string isEqualToString:@"\n"]) {
            [self.foundValue appendString:string];
        }
    }
}
@end
