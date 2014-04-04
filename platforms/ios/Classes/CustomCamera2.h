//
//  CustomCamera.h
//  CustomCamera
//
//  Created by Jose Luis Maroto on 2014-03-03.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>
#import <Cordova/CDVPlugin.h>

#import "DBCameraViewController.h"
#import "DBCameraContainer.h"

@interface CustomCamera2 : CDVPlugin <DBCameraViewControllerDelegate>


@property (strong) NSMutableDictionary *metadata;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong) NSData* data;



// Cordova command method
-(void) openCamera:(CDVInvokedUrlCommand*)command;

// Create and override some properties and methods (these will be explained later)
-(void) capturedImageWithPath:(CDVPluginResult*)result;
//@property (strong, nonatomic) CustomCameraViewController* overlay;
@property (strong, nonatomic) CDVInvokedUrlCommand* latestCommand;
@property (readwrite, assign) BOOL hasPendingOperation;
@end
