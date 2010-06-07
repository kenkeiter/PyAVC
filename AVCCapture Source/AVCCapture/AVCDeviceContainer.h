//
//  AVCDeviceContainer.h
//  AVCCapture
//
//  Created by Kenneth Keiter on 2/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <AVCVideoServices/AVCVideoServices.h>

@interface AVCDeviceContainer : NSObject {
	AVCDevice *dev;
	PanelSubunitController *panelSubunit;
	FILE *fh;
	UInt8 deviceState;
	AVCDeviceStream *deviceStream;
}

@property (nonatomic) AVCDevice *dev;
@property (nonatomic) PanelSubunitController *panelSubunit;
@property (nonatomic) UInt8 deviceState;
@property (nonatomic) AVCDeviceStream *deviceStream;

- (id) initWithAVCDevice:(AVCDevice *)device;
- (id) initWithAVCDevice:(AVCDevice *)device andPanelSubunit:(PanelSubunitController *)panel;

- (void) tuneChannel:(UInt16)channel;
- (void) tuneTwoPartChannelMajor:(UInt16)major withMinor:(UInt16)minor;

- (void) open;
- (void) openDeviceStream;
- (void) beginRecordingWithFileHandle:(FILE *)theFH;
- (void) finishRecording;
- (void) finishRecordingAndClose;
- (void) close;

- (NSString *) deviceName;
- (NSString *) vendorName;
- (UInt64) guid;
- (bool) isOpen;
- (FILE *) recordFileHandle;

@end

enum{
	kDeviceDisconnected,
	kDeviceReady,
	kDeviceConnected,
	kDeviceRecording,
};

/* MPEG Packet-Handling Functionality */
void MPEGReceiverMessageReceivedProc(UInt32 msg, UInt32 param1, UInt32 param2, void *pRefCon);
IOReturn MPEGPacketDataStoreHandler(UInt32 tsPacketCount, 
									UInt32 **ppBuf, 
									void *pRefCon, 
									UInt32 isochHeader,
									UInt32 cipHeader0,
									UInt32 cipHeader1,
									UInt32 fireWireTimeStamp);
IOReturn MyAVCDeviceMessageNotification (class AVCDevice *pAVCDevice,
										 natural_t messageType,
										 void * messageArgument,
										 void *pRefCon);
