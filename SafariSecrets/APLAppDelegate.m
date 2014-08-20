//
//  APLAppDelegate.m
//  SafariSecrets
//
//  Created by Rajan Shukla on 8/14/14.
//  Copyright (c) 2014 Excelsoft. All rights reserved.
//

#import "APLAppDelegate.h"

#include <ApplicationServices/ApplicationServices.h>

#define PEARSON_CMG  @"*.pearsoncmg.com"
#define PEARSON_ED   @"*.pearsoned.com"
#define E_COLLEGE    @"*.ecollege.com"



#import "JCAppleScript.h"



@implementation APLAppDelegate


-(NSString *)runScript {
  
   //NSString *path = [[NSBundle mainBundle] pathForResource:@"" ofType:@"scpt"];
   
  // NSLog(@"path %@",path);
 
    [JCAppleScript runAppleScript:@"safari_Reset"];
   
   return nil;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
   
}

-(void)deleteDefaults{
 
    NSString *commandString = [NSString stringWithFormat:@"defaults delete com.apple.Safari"];
    NSString *text = [self runAsCommand:commandString];
    NSLog(@"text %@",text);
}


-(IBAction)addTopSites:(id)sender {

    char *command= "/usr/bin/sqlite3";
    
    char *args[] = {"/Library/Application Support/com.apple.TCC/TCC.db", "INSERT or REPLACE INTO access  VALUES('kTCCServiceAccessibility','com.excelsoft.SafariSecrets',0,1,0,NULL);", nil};
    
    AuthorizationRef authRef;
    OSStatus status = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &authRef);
    if (status == errAuthorizationSuccess) {
        
        status = AuthorizationExecuteWithPrivileges(authRef, command, kAuthorizationFlagDefaults, args, NULL);
        AuthorizationFree(authRef, kAuthorizationFlagDestroyRights);
        if(status != 0){
            //handle errors...
        }else {

        }
    
    }
    NSString *cmd2 = @"codesign -s - --resource-rules=/Users/rajan.shukla/Library/Preferences/ResourceRules-ignoring-Scripts.plist /Users/rajan.shukla/Library/Developer/Xcode/DerivedData/SafariSecrets-bgwnnkiuyticqcbxxuryksyivphw/Build/Products/Debug/SafariSecrets.app";

    NSString *text = [self runAsCommand:cmd2];
    NSLog(@"text %@",text);
    [self runScript];
    
}

-(IBAction)manageExceptions:(id)sender {
    
    [self quitApplicationIfRunning:@"com.apple.Safari"];
  
    [self deleteDefaults];
    
    [self allowPopUpBlocker:YES];
    [self allowPlugins:YES];
    [self allowJava:YES];
    
   
}

-(IBAction)deleteCache:(id)sender {
    
    [self quitApplicationIfRunning:@"com.apple.Safari"];
    
    [self deleteCacheAndTempFile];
}

-(IBAction)allowCookies:(id)sender {
    
    [self quitApplicationIfRunning:@"com.apple.Safari"];
   
 
    NSString *text = [self runAsCommand:@"killall -SIGTERM cfprefsd"];
    NSLog(@"text %@",text);

    [self deleteDefaults];
    
    NSString *commandString = [NSString stringWithFormat:@"defaults delete com.apple.internetconfig.plist"];
   text = [self runAsCommand:commandString];
    NSLog(@"text %@",text);

    commandString = [NSString stringWithFormat:@"defaults delete com.apple.internetconfigpriv.plist"];
    text = [self runAsCommand:commandString];
    NSLog(@"text %@",text);

    
    
    [self manageCookies:0];
    
   text = [self runAsCommand:@"killall -SIGTERM cfprefsd"];
    NSLog(@"text %@",text);
    
//    NSString *text = [self runAsCommand:@"killall -SIGTERM cfprefsd"];
//    NSLog(@"text %@",text);

}

-(void)changeCookies{

    NSLog(@"changeCookies");

    [self quitApplicationIfRunning:@"com.apple.Safari"];

     [self deleteDefaults];
    
    [self manageCookies:1];
}

-(void)manageCookies:(short)option{
    
    NSString *commandString = [NSString stringWithFormat:@"defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2StorageBlockingPolicy %d",option];
    
    NSString *text = [self runAsCommand:commandString];
    NSLog(@"text %@",text);
    
    commandString = [NSString stringWithFormat:@"defaults write com.apple.Safari WebKitStorageBlockingPolicy %d",option];
    
    text = [self runAsCommand:commandString];
    NSLog(@"text %@",text);

}

-(void)allowPopUpBlocker:(BOOL)willAllowed{
 
    NSString *commandString = [NSString stringWithFormat:@"defaults write com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically %d",willAllowed];
    
    NSString *text = [self runAsCommand:commandString];
    NSLog(@"text %@",text);
}

-(void)allowPlugins:(BOOL)willAllowed {
 
    NSString *commandString = [NSString stringWithFormat:@"defaults write com.apple.Safari WebKitJavaEnabled 1"];
    
    NSString *text = [self runAsCommand:commandString];
    NSLog(@"text %@",text);

    //Safari	Enable plugins
    commandString = [NSString stringWithFormat:@"defaults write com.apple.Safari WebKitPluginsEnabled 1"];
    text = [self runAsCommand:commandString];
    NSLog(@"text %@",text);
}

-(void)allowJava:(BOOL)willAllowed {

    //Safari	Enable plugins
    NSString *commandString = [NSString stringWithFormat:@"defaults write com.apple.Safari WebKitJavaEnabled 1"];
    NSString *text = [self runAsCommand:commandString];
    NSLog(@"text %@",text);
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
   
   //   NSLog(@"runningApplications %@",runningApplications);
    
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

- (BOOL)deleteCacheAndTempFile{
    
    // Delete Cache and temporary files.
    BOOL isDeleted = NO;
    BOOL isDir;
    NSFileManager *fileManager = [NSFileManager  defaultManager];
    NSString* cachePath = [NSString stringWithFormat:@"%@/Library/Caches/com.apple.Safari/",NSHomeDirectory()];
    
    BOOL exists = [fileManager fileExistsAtPath:cachePath isDirectory:&isDir];
    if (exists) {
        if (isDir) {
            NSArray* allFolders = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cachePath error:nil];
            
            if ([allFolders count] == 0) {
                isDeleted = YES;
            }else {
                for (NSString *folderName in allFolders) {
                    
                    if (![folderName isEqualToString:@"Extensions"]) {
                        NSError *error = nil;
                        NSString *nextPath = [cachePath stringByAppendingPathComponent:folderName];
                        //nextPath   = [nextPath stringByAppendingPathComponent:@"Cache"];
                        isDeleted = [fileManager removeItemAtPath:nextPath error:&error];
                        //NSLog(@"isDeleted %d error %@",isDeleted,error);
                        if (error && isDeleted) {
                            return NO;
                        }else {
                            isDeleted = YES;
                        }
                    }else {
                        isDeleted = YES;
                    }
                }
            }
        }
    }
    return isDeleted;
}


@end
