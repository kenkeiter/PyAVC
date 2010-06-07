/*
	File:		FireWireDV.h

    Synopsis: This is the top level header file for the FireWireDV framework. 
 
	Copyright: 	� Copyright 2001-2003 Apple Computer, Inc. All rights reserved.

	Written by: ayanowitz

 Disclaimer:	IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc.
 ("Apple") in consideration of your agreement to the following terms, and your
 use, installation, modification or redistribution of this Apple software
 constitutes acceptance of these terms.  If you do not agree with these terms,
 please do not use, install, modify or redistribute this Apple software.

 In consideration of your agreement to abide by the following terms, and subject
 to these terms, Apple grants you a personal, non-exclusive license, under Apple�s
 copyrights in this original Apple software (the "Apple Software"), to use,
 reproduce, modify and redistribute the Apple Software, with or without
 modifications, in source and/or binary forms; provided that if you redistribute
 the Apple Software in its entirety and without modifications, you must retain
 this notice and the following text and disclaimers in all such redistributions of
 the Apple Software.  Neither the name, trademarks, service marks or logos of
 Apple Computer, Inc. may be used to endorse or promote products derived from the
 Apple Software without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or implied,
 are granted by Apple herein, including but not limited to any patent rights that
 may be infringed by your derivative works or by other works in which the Apple
 Software may be incorporated.

 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
 WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
 WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
 COMBINATION WITH YOUR PRODUCTS.

 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION
 OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT
 (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*/

#ifndef __AVCVIDEOSERVICES_FIREWIREDV__
#define __AVCVIDEOSERVICES_FIREWIREDV__

namespace AVS
{

//////////////////////////////////////////////////////////////////////////////////
//
// Prototypes for FireWireDV object creation/destruction helper functions.
// These functions create/prepare or destroy both a FireWireDV class object,
// as well as a dedicated real-time thread for the object's callbacks and DCL
// processing.
//
//////////////////////////////////////////////////////////////////////////////////

// Create and setup a DVTransmitter object and it's dedicated thread
IOReturn CreateDVTransmitter(DVTransmitter **ppTransmitter,
							 DVFramePullProc framePullProcHandler,
							 void *pFramePullProcRefCon,
							 DVFrameReleaseProc frameReleaseProcHandler,
							 void *pFrameReleaseProcRefCon = nil,
							 DVTransmitterMessageProc messageProcHandler = nil,
							 void *pMessageProcRefCon = nil,
							 StringLogger *stringLogger = nil,
							 IOFireWireLibNubRef nubInterface = nil,
							 unsigned int cyclesPerSegment = kCyclesPerDVTransmitSegment,
							 unsigned int numSegments = kNumDVTransmitSegments,
							 UInt8 transmitterDVMode = 0x00,
							 UInt32 numFrameBuffers = 8,
							 bool doIRMAllocations = false);

// Destroy a DVTransmitter object created with CreateDVTransmitter(), and it's dedicated thread
IOReturn DestroyDVTransmitter(DVTransmitter *pTransmitter);

// Create and setup a DVReceiver object and it's dedicated thread
IOReturn CreateDVReceiver(DVReceiver **ppReceiver,
						  DVFrameReceivedProc frameReceivedProcHandler,
						  void *pFrameReceivedProcRefCon = nil,
						  DVReceiverMessageProc messageProcHandler = nil,
						  void *pMessageProcRefCon = nil,
						  StringLogger *stringLogger = nil,
						  IOFireWireLibNubRef nubInterface = nil,
						  unsigned int cyclesPerSegment = kCyclesPerDVReceiveSegment,
						  unsigned int numSegments = kNumDVReceiveSegments,
						  UInt8 receiverDVMode = 0x00,
						  UInt32 numFrameBuffers = kDVReceiveNumFrames,
						  bool doIRMAllocations = false);

// Destroy a DVReceiver object created with CreateDVReceiver(), and it's dedicated thread
IOReturn DestroyDVReceiver(DVReceiver *pReceiver);


extern DVFormats dvFormats[];

// Analyze a portion of raw DV frame data, and determine the DVMode
// Note: pDVFrameData must point to at least the first 480 bytes of a DV frame!
IOReturn GetDVModeFromFrameData(UInt8 *pDVFrameData, UInt8 *pDVMode, UInt32 *pFrameSize, UInt32 *pSourcePacketSize);

} // namespace AVS

#endif // __AVCVIDEOSERVICES_FIREWIREDV__
