//
//  CustomCamera2.m
//  CustomCamera2
//
//
//

#import "CustomCamera2.h"
#import <AssetsLibrary/ALAssetRepresentation.h>


#define CDV_PHOTO_PREFIX @"cdv_photo_"


@implementation CustomCamera2

// Cordova command method
-(void) openCamera:(CDVInvokedUrlCommand *)command {
    NSString* callbackId = command.callbackId;
    NSArray* arguments = command.arguments;
    
	// Set the hasPendingOperation field to prevent the webview from crashing
	self.hasPendingOperation = YES;
    
	// Save the CDVInvokedUrlCommand as a property.  We will need it later.
	self.latestCommand = command;
    
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[DBCameraContainer alloc] initWithDelegate:self]];
    [nav setNavigationBarHidden:YES];
    [self.viewController presentViewController:nav animated:YES completion:nil];
    
	/*// Make the overlay view controller.
	self.overlay = [[CustomCameraViewController alloc] initWithNibName:@"CustomCameraViewController" bundle:nil];
	self.overlay.plugin = self;
    
	// Display the view.  This will "slide up" a modal view from the bottom of the screen.
	[self.viewController presentViewController:self.overlay.cameraPicker animated:NO completion:nil];*/
}

#pragma mark - DBCameraViewControllerDelegate

- (void) captureImageDidFinish:(UIImage *)image withMetadata:(NSDictionary *)metadata
{
    ALAssetsLibrary *library = [ALAssetsLibrary new];
    [library writeImageToSavedPhotosAlbum:image.CGImage metadata:metadata completionBlock:nil];
    
    
    NSData* data = nil;
    data = UIImageJPEGRepresentation(image, 0.7);
    
    [self.viewController.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    
    NSString* docsPath = [NSTemporaryDirectory()stringByStandardizingPath];
    NSError* err = nil;
    NSFileManager* fileMgr = [[NSFileManager alloc] init]; // recommended by apple (vs [NSFileManager defaultManager]) to be threadsafe
    // generate unique file name
    NSString* filePath;
    
    int i = 1;
    do {
        filePath = [NSString stringWithFormat:@"%@/%@%03d.%@", docsPath, CDV_PHOTO_PREFIX, i++, @"jpg"];
    } while ([fileMgr fileExistsAtPath:filePath]);

    CDVPluginResult* result = nil;
    // save file
    NSLog(@"%@",filePath);
    if (![data writeToFile:filePath options:NSAtomicWrite error:&err]) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION messageAsString:[err localizedDescription]];
    } else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[[NSURL fileURLWithPath:filePath] absoluteString]];
    }
    
    [self.commandDelegate sendPluginResult:result callbackId:self.latestCommand.callbackId];
    
	// Unset the self.hasPendingOperation property
	self.hasPendingOperation = NO;
    
    // Hide the picker view
    [self.viewController dismissModalViewControllerAnimated:YES];
}
#pragma mark - DBCameraViewControllerDelegate
- (void) closeCamera
{
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"close"];   // error callback expects string ATM
    
    [self.commandDelegate sendPluginResult:result callbackId:self.latestCommand.callbackId];
    
	// Unset the self.hasPendingOperation property
	self.hasPendingOperation = NO;
    
    // Hide the picker view
    [self.viewController dismissModalViewControllerAnimated:YES];
}
#pragma mark - DBCameraViewControllerDelegate
- (void) skipCamera
{
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"skip"];   // error callback expects string ATM
    [self.commandDelegate sendPluginResult:result callbackId:self.latestCommand.callbackId];
    
	// Unset the self.hasPendingOperation property
	self.hasPendingOperation = NO;
    
    // Hide the picker view
    [self.viewController dismissModalViewControllerAnimated:YES];
}

// Method called by the overlay when the image is ready to be sent back to the web view
-(void) capturedImageWithPath:(CDVPluginResult*)result {
	[self.commandDelegate sendPluginResult:result callbackId:self.latestCommand.callbackId];
    
	// Unset the self.hasPendingOperation property
	self.hasPendingOperation = NO;
    
    // Hide the picker view
    [self.viewController dismissModalViewControllerAnimated:YES];
//    self.overlay=nil;
}

@end
