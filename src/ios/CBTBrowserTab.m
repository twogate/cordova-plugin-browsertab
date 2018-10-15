/*! @file CBTBrowserTab.m
 @brief Browser tab plugin for Cordova
 @copyright
 Copyright 2016 Google Inc. All Rights Reserved.
 @copydetails
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 http://www.apache.org/licenses/LICENSE-2.0
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "CBTBrowserTab.h"

@implementation CBTBrowserTab {
    SFSafariViewController *_safariViewController;
    UIColor *backgroundColor;
    UIColor *controlTintColor;
    UIColor *barTintColor;
}

- (void)pluginInitialize {
    NSString *tabColor = [self.commandDelegate.settings objectForKey:[@"CustomTabColorRGB" lowercaseString]];
    NSString *tabPctColor = [self.commandDelegate.settings objectForKey:[@"CustomTabPctColorRGB" lowercaseString]];
    NSString *tabPbtColor = [self.commandDelegate.settings objectForKey:[@"CustomTabPbtColorRGB" lowercaseString]];

    backgroundColor = [self getUIColorObjectFromHexString:tabColor alpha:1.0];
    controlTintColor = [self getUIColorObjectFromHexString:tabPctColor alpha:1.0];
    barTintColor = [self getUIColorObjectFromHexString:tabPbtColor alpha:1.0];
}

- (UIColor *)getUIColorObjectFromHexString:(NSString *)hexStr alpha:(CGFloat)alpha
{
    // Convert hex string to an integer
    unsigned int hexint = [self intFromHexString:hexStr];
    
    // Create color object, specifying alpha as well
    UIColor *color =
    [UIColor colorWithRed:((CGFloat) ((hexint & 0xFF0000) >> 16))/255
                    green:((CGFloat) ((hexint & 0xFF00) >> 8))/255
                     blue:((CGFloat) (hexint & 0xFF))/255
                    alpha:alpha];
    
    return color;
}

- (unsigned int)intFromHexString:(NSString *)hexStr
{
    unsigned int hexInt = 0;
    
    // Create scanner
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    
    // Tell scanner to skip the # character
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    
    // Scan hex value
    [scanner scanHexInt:&hexInt];
    
    return hexInt;
}

- (void)isAvailable:(CDVInvokedUrlCommand *)command {
    BOOL available = ([SFSafariViewController class] != nil);
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                  messageAsBool:available];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)openUrl:(CDVInvokedUrlCommand *)command {
    NSString *urlString = command.arguments[0];
    if (urlString == nil) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                    messageAsString:@"url can't be empty"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    if ([SFSafariViewController class] != nil) {
        NSString *errorMessage = @"in app browser tab not available";
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                    messageAsString:errorMessage];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
    
    _safariViewController = [[SFSafariViewController alloc] initWithURL:url];
    _safariViewController.view.backgroundColor = backgroundColor;
    _safariViewController.preferredControlTintColor = controlTintColor;
    _safariViewController.preferredBarTintColor = backgroundColor;
    
    [self.viewController presentViewController:_safariViewController animated:YES completion:nil];
    
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)close:(CDVInvokedUrlCommand *)command {
    if (!_safariViewController) {
        return;
    }
    [_safariViewController dismissViewControllerAnimated:YES completion:nil];
    _safariViewController = nil;
}

@end
