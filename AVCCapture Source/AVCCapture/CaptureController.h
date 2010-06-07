//
//  CaptureController.h
//  AVCCapture
//
//  Created by Kenneth Keiter on 2/2/09.
//

#import <Cocoa/Cocoa.h>
#include <AVCVideoServices/AVCVideoServices.h>



@interface CaptureController : NSObject {
	AVCDeviceController *controller;
	NSMutableArray *deviceSet;
}

-(NSMutableArray *) devices;

@end

IOReturn MyAVCDeviceControllerNotification(AVCDeviceController *pAVCDeviceController, void *pRefCon, AVCDevice* pDevice);