/*
 *  CaptureController.mm
 *  AVCCapture.framework
 *
 *  Created by Kenneth Keiter on 02/02/09.
 *
 *  Provides video capture services for AVC devices connected
 *  via Firewire under OS X.
 */

#include <AVCVideoServices/AVCVideoServices.h>
using namespace AVS;

#import "AVCDeviceContainer.h"
#import "CaptureController.h"

static CaptureController *sharedCaptureController = nil;

@implementation CaptureController

+ (id) sharedCaptureController{
	@synchronized(self){
		if(sharedCaptureController == nil){
			sharedCaptureController = [[CaptureController alloc] init];
		}
	}
	return sharedCaptureController;
}

-(id) init{
	if(sharedCaptureController == nil){
		IOReturn err;
		self = [super init];
		controller = nil;
		deviceSet = [[NSMutableArray alloc] init];
		err = CreateAVCDeviceController(&controller, MyAVCDeviceControllerNotification, self);
		if(!controller || err == kIOReturnError){
			[NSException raise:@"CaptureController Exception"
						 format:@"Could not create deviceController instance. Failing."];
			return nil;
		}
		sharedCaptureController = self;
		// setup device list
		unsigned short i;
		for(i = 0; i < CFArrayGetCount(controller->avcDeviceArray); i++){
			AVCDeviceContainer *current_dev = [[AVCDeviceContainer alloc] initWithAVCDevice: (AVCDevice *) CFArrayGetValueAtIndex(controller->avcDeviceArray, i)];
			[deviceSet addObject:current_dev];
		}
	}
	return sharedCaptureController;
}

-(NSMutableArray *) devices{
	return deviceSet;
}

-(void) dealloc{
	unsigned short i;
	for(i = 0; i < [deviceSet count]; i++){
		[[deviceSet objectAtIndex:i] close];
		[[deviceSet objectAtIndex:i] release];
	}
	[deviceSet release];
	controller = nil;
	[super dealloc];
}

@end

IOReturn MyAVCDeviceControllerNotification(AVCDeviceController *pAVCDeviceController, void *pRefCon, AVCDevice* pDevice){
	return kIOReturnSuccess; // TODO: Is this OK?
}
