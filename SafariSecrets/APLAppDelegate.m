//
//  APLAppDelegate.m
//  SafariSecrets
//
//  Created by Rajan Shukla on 8/14/14.
//  Copyright (c) 2014 Excelsoft. All rights reserved.
//

#import "APLAppDelegate.h"

#define PEARSON_CMG  @"*.pearsoncmg.com"
#define PEARSON_ED   @"*.pearsoned.com"
#define E_COLLEGE    @"*.ecollege.com"




@implementation APLAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application

}


-(void)deleteDefaults{
    
    [self quitApplicationIfRunning:@"com.apple.Safari"];
    
    NSString *commandString = [NSString stringWithFormat:@"defaults delete com.apple.Safari"];
    NSString *text = [self runAsCommand:commandString];
    NSLog(@"text %@",text);
}

-(IBAction)addTopSites:(id)sender {
    
    [self quitApplicationIfRunning:@"com.apple.Safari"];
    [self addTopSites];
}

-(IBAction)disablePopUpBlocker:(id)sender {
    
    [self deleteDefaults];
    
   NSString *commandString = [NSString stringWithFormat:@"defaults write com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically 1"];
    
   NSString *text = [self runAsCommand:commandString];
    NSLog(@"text %@",text);

}


-(IBAction)AllowPlugins:(id)sender {
 
    
}


-(NSArray *)listOfSites{

    return [NSArray arrayWithObjects:@"http://www.pearsoncmg.com",@"http://www.pearsoned.com",@"http://www.ecollege.com", nil];
}


-(NSArray *)nameOfSites{
    
    return [NSArray arrayWithObjects:@"Pearson cmg",@"Pearson ed ",@"Ecollege", nil];
}

-(NSMutableDictionary *)removeBanndURLS:(NSMutableDictionary *)bannedURLMap{
    
   NSArray *arr = [bannedURLMap objectForKey:@"BannedURLStrings"];

   NSMutableArray *listOFSites = [[NSMutableArray alloc] initWithArray:arr];

   for (NSString *site in [self listOfSites]) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@",site];
        NSArray *filteredArray = [listOFSites filteredArrayUsingPredicate:predicate];
        if ([filteredArray count] > 0) {
            NSLog(@"removeBandURLS : filteredArray %@",filteredArray);
            [listOFSites removeObject:[filteredArray objectAtIndex:0]];
        }
    }

   if([listOFSites count] < [arr count]){
      [bannedURLMap setObject:listOFSites forKey:@"BannedURLStrings"];
   }
   
   return bannedURLMap;
}


-(void)addTopSites{

    NSString *path = [NSString stringWithFormat:@"%@/Library/Safari/TopSites.plist",NSHomeDirectory()];

    NSMutableDictionary *topSiteMap = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    topSiteMap =  [self removeBanndURLS:topSiteMap];
 
   NSArray *arr = [topSiteMap objectForKey:@"TopSites"];
   NSMutableArray *listOFSites = [[NSMutableArray alloc] initWithArray:arr];

    short i = 0;
    
    for (NSString *site in [self listOfSites]) {
   
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.TopSiteURLString contains[cd] %@",site];
        NSArray *filteredArray = [listOFSites filteredArrayUsingPredicate:predicate];
        
        if ([filteredArray count] == 0) {
            NSString *name = [[self nameOfSites] objectAtIndex:i];
            NSDictionary *siteMap =  [NSDictionary dictionaryWithObjectsAndKeys:site,@"TopSiteURLString",name,@"TopSiteTitle",nil];
            [listOFSites insertObject:siteMap atIndex:0];
        }
        i++;
    }
 
   if ([listOFSites count] > [arr count]) {
      [topSiteMap setObject:listOFSites forKey:@"TopSites"];
   }
   
   
   [topSiteMap writeToFile:path atomically:YES];

   NSLog(@"path %@",[NSDictionary dictionaryWithContentsOfFile:path]);
    
}

-(void)quitApplicationIfRunning:(NSString *)bundleID {
    
    NSArray *runningApplications = [[NSWorkspace sharedWorkspace] runningApplications];
   
    for ( NSRunningApplication *app  in runningApplications ) {
        if ( [[app bundleIdentifier] isEqualToString:bundleID]) {
            
            if ([app processIdentifier]) {
                kill([app processIdentifier], SIGKILL );
            }
        }
    }
}


- (NSString*)runAsCommand:(NSString *)string {
    
    NSPipe* pipe = [NSPipe pipe];
    
    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    [task setArguments:@[@"-c", [NSString stringWithFormat:@"%@", string]]];
    [task setStandardOutput:pipe];
    
    NSFileHandle* file = [pipe fileHandleForReading];
    [task launch];
    
    return [[NSString alloc] initWithData:[file readDataToEndOfFile] encoding:NSUTF8StringEncoding];
}



@end
