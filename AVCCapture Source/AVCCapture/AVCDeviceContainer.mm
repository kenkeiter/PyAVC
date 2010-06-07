//
//  AVCDeviceContainer.m
//  AVCCapture
//
//  Created by Kenneth Keiter on 2/2/09.
//

#include <AVCVideoServices/AVCVideoServices.h>
using namespace AVS;

#import "AVCDeviceContainer.h"

@implementation AVCDeviceContainer

@synthesize dev, panelSubunit, deviceState, deviceStream;

- (id) init{
	self = [super init];
	[self setDeviceState: kDeviceDisconnected];
	[self setDeviceStream: nil];
	[self setPanelSubunit: nil];
	[self setDev: nil];
	return self;
}

- (id) initWithAVCDevice:(AVCDevice *)device{
	self = [self init];
	[self setDev: device];
	[self setPanelSubunit: new PanelSubunitController([self dev])];
	[self setDeviceState: kDeviceReady];
	return self;
}

- (id) initWithAVCDevice:(AVCDevice *)device andPanelSubunit:(PanelSubunitController *)panel{
	self = [self init];
	[self setDev: device];
	[self setPanelSubunit: panel];
	[self setDeviceState: kDeviceReady];
	return self;
}

- (void) tuneChannel:(UInt16)channel{
	IOReturn res;
	if([self deviceState] == kDeviceReady){
		[self open];
	}
	if([self deviceState] > kDeviceReady){ // make sure device is open
		res = [self panelSubunit]->Tune(channel);
		if(res != kIOReturnSuccess){
			[NSException raise:@"AVCDevice Exception"
						 format:@"Failed to tuneChannel to %d. Unknown error occurred.", channel];
		}
	}else{
		// attempted to change channel with no device attached
		[NSException raise:@"AVCDevice Exception"
					 format:@"Failed to tuneChannel. AVCDevice not open."];
	}
}

- (void) tuneTwoPartChannelMajor:(UInt16)major withMinor:(UInt16)minor{
	IOReturn res;
	if([self deviceState] == kDeviceReady){
		[self open];
	}
	if([self deviceState] > kDeviceReady){ // make sure device is open
		res = [self panelSubunit]->TuneTwoPartChannel(major, minor);
		if(res != kIOReturnSuccess){
			[NSException raise:@"AVCDevice Exception"
						 format:@"Failed to tuneTwoPartChannelToMajor:%d withMinor:%d. Device may not support this.", major, minor];
		}
	}else{
		[NSException raise:@"AVCDevice Exception"
					 format:@"Failed to [tuneTwoPartChannelToMajor:withMinor:]. AVCDevice not open."];
	}
}

- (void) open{
	IOReturn res;
	if([self deviceState] == kDeviceReady){
		res = [self dev]->openDevice(MyAVCDeviceMessageNotification, self);
		if(res != kIOReturnSuccess){
			[NSException raise:@"AVCDevice Exception"
						 format:@"Failed to open device."];
		}else{
			[self setDeviceState: kDeviceConnected];
		}
	}
	if([self deviceState] == kDeviceDisconnected){
		[NSException raise:@"AVCDevice Exception"
					 format:@"Could not open AVCDevice. No instance provided to container."];
	}
}

- (void) openDeviceStream{
	if([self deviceState] == kDeviceConnected){
		AVCDeviceStream *theStream = [self dev]->CreateMPEGReceiverForDevicePlug(
			0, nil, self, MPEGReceiverMessageReceivedProc, self, 
			nil, kCyclesPerReceiveSegment, kNumReceiveSegments * 2
		);
		if(theStream == nil){
			[NSException raise:@"AVCDevice Exception"
						 format:@"Unable to create AVC device stream."];
		}else{
			[self setDeviceStream: theStream];
		}
	}else{
		[NSException raise:@"AVCDevice Exception"
					 format:@"Could not open AVC device stream before device is open."];
	}
}

- (void) beginRecordingWithFileHandle:(FILE *)theFH{
	if([self deviceState] >= kDeviceReady){
		[self open];
		[self openDeviceStream];
	}
	if([self deviceStream] != nil && theFH){
		fh = theFH;
		[self deviceStream]->pMPEGReceiver->registerExtendedDataPushCallback(MPEGPacketDataStoreHandler, self);
		[self dev]->StartAVCDeviceStream([self deviceStream]);
		[self setDeviceState: kDeviceRecording];
	}else{
		[NSException raise:@"AVCDevice Exception"
					 format:@"File handle was invalid, or device stream failed to open."];
	}
}

- (void) finishRecording{
	if([self deviceState] == kDeviceRecording){
		if([self deviceStream] != nil){
			[self dev]->StopAVCDeviceStream([self deviceStream]);
			[self dev]->DestroyAVCDeviceStream([self deviceStream]);
			[self setDeviceStream: nil];
			fh = nil;
		}
		[self setDeviceState: kDeviceConnected];
	}else{
		[NSException raise:@"AVCDevice Exception"
					 format:@"Attempted to finish recording on an idle device. No recording to finish!"];
	}
}

- (void) finishRecordingAndClose{
	[self finishRecording];
	[self close];
}

- (void) close{
	[self dev]->closeDevice();
	[self setDeviceState: kDeviceReady]; // but not disconnected.
}

- (NSString *) deviceName{
	return [NSString stringWithCString:[self dev]->deviceName];
}

- (NSString *) vendorName{
	return [NSString stringWithCString:[self dev]->vendorName];
}

- (UInt64) guid{
	return [self dev]->guid;
}

- (bool) isOpen{
	return [self dev]->isOpened();
}

- (FILE *) recordFileHandle{
	return fh;
}

- (void) dealloc{
	[self setPanelSubunit: nil];
	[self setDeviceStream: nil];
	[self setDev: nil];
	[super dealloc];
}

@end

/*****************************************************************
 * MPEG Data Store Functionality
 * Objective-C++ that handles AVC device notifications and
 * low-level creation of packets. Avoids message-passing for 
 * speed. Comprised of: MPEGReceiverMessageReceivedProc, 
 * MPEGPacketDataStoreHandler, and MyAVCDeviceMessageNotification
 *****************************************************************/

IOReturn MyAVCDeviceMessageNotification (class AVCDevice *pAVCDevice,
										 natural_t messageType,
										 void * messageArgument,
										 void *pRefCon){
	AVCDeviceContainer *deviceContainer = (AVCDeviceContainer*) pRefCon;
	if((messageType == kIOMessageServiceIsRequestingClose) && ([deviceContainer deviceState] == kDeviceRecording)){
		[deviceContainer finishRecordingAndClose];
	}
	return kIOReturnSuccess;
}

IOReturn MPEGPacketDataStoreHandler(UInt32 tsPacketCount, 
									UInt32 **ppBuf, 
									void *pRefCon, 
									UInt32 isochHeader,
									UInt32 cipHeader0,
									UInt32 cipHeader1,
									UInt32 fireWireTimeStamp){
	unsigned int i;
	unsigned int cnt;
	AVCDeviceContainer *deviceContainer = (AVCDeviceContainer*) pRefCon;
	
	for (i = 0; i < tsPacketCount; i++){
		cnt = fwrite(ppBuf[i], 1, kMPEG2TSPacketSize, [deviceContainer recordFileHandle]);
		if (cnt != kMPEG2TSPacketSize){
			[deviceContainer finishRecording];
			[NSException raise:@"AVCDevice Exception"
					 format:@"Error while attempting to write packet to file: packet size verification failed."];
			return kIOReturnError;
		}
	}
	
	return kIOReturnSuccess;
}	

void MPEGReceiverMessageReceivedProc(UInt32 msg, UInt32 param1, UInt32 param2, void *pRefCon){
	// ... hello?
}
