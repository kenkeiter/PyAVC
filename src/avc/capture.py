import objc
import os

objc.loadBundle("AVCCapture", globals(), bundle_path=objc.pathForFramework(u'/Library/Frameworks/AVCCapture.framework'))


class AVCCaptureException(Exception):
    
    def __init__(self, text, subexception = None):
        if subexception is not None:
            message = text + ': ' + subexception.message
        else:
            message = text
        super(Exception, self).__init__(message)


class AVCCaptureDevice(object):
    """
    Acts as an interface to a Firewire-connected (IEEE1394) AV/C device.
    """
    
    def __init__(self, obj):
        self.__obj = obj
    
    def tune_channel(self, channel, channel_minor = None):
        """
        Send an AV/C command to the selected device to tune the device 
        to a different channel. The first argument, channel, accepts 
        an int type. If desired, you may tune to a two-part channel 
        (such as 8.2) by providing both a channel and channel_minor 
        argument -- in the case of two-part channel 8.2, one would call 
        tune_channel(8, 2).
        
        Raises an AVCCaptureException in the event of a failure.
        """
        if type(channel) is int and channel_minor is None:
            try:
                self.__obj.tuneChannel_(channel)
            except Exception, e:
                raise AVCCaptureException(u'Failed to tune device.', e)
        elif type(channel) is int and type(chnanel_minor) is int:
            try:
                self.__obj.tuneTwoPartChannelMajor_withMinor_(channel, channel_minor)
            except Exception, e:
                raise AVCCaptureException(u'Failed to tune device to two-part channel', e)
        else:
            raise TypeError('Only positive integers are accepted as channel numbers.')
    
    def begin_recording(self, file_handle):
        """
        Provided a file object, begins recording the MPEG2-TS stream 
        coming from the device. The file_handle argument may only be a 
        <file> object. Any other type may cause a segmentation fault or 
        bus error. begin_recording() is a non-blocking, thread-safe 
        method.
        """
        if type(file_handle) is file:
            try:
                self.__obj.beginRecordingWithFileHandle_(file_handle)
            except Exception, e:
                raise AVCCaptureException(u'Failed to start recording', e)
        else:
            raise TypeError('File handle supplied must be of type <file> only.')
    
    def finish_recording(self):
        """
        Completes recording of the device stream. Will not close the <file> 
        object that you provided to begin_recording().
        """
        try:
            self.__obj.finishRecording()
        except Exception, e:
            raise AVCCaptureException('Failed to finish recording', e)
    
    @property
    def name(self):
        """
        The name of the device as provided by querying it. Support for this 
        property is manufacturer-dependent.
        """
        return self.__obj.deviceName()
    
    @property
    def vendor(self):
        """
        The name of the device's manufacturer as provided by querying it. 
        Supoort for this property is manufacturer-dependent.
        """
        return self.__obj.vendorName()
    
    @property
    def guid(self):
        """
        The device's GUID, returned as a long (or int)
        """
        return self.__obj.guid()
    
    @property
    def deviceState(self):
        """
        The device's state. Returns one of the following values as a string:
        kDeviceDisconnected, kDeviceReady, kDeviceConnected, kDeviceRecording
        """
        return ['kDeviceDisconnected', 'kDeviceReady', 'kDeviceConnected', 'kDeviceRecording'][self.__obj.deviceState()]
    
    def __repr__(self):
        return '<AVCCaptureDevice 0x%x (%s:%s) - %s>' % (self.guid, self.vendor, self.name, self.deviceState)


class AVCCaptureInterface(object):
    """
    Provides an interface to a set of AV/C capture devices.
    """
    
    def __init__(self):
        self.__devices = None
        try:
            self.__controller = CaptureController.new()
        except Exception, e:
            raise AVCCaptureException(u'An error occurred while attempting to create new AVCCaptureInterface instance.', e)
    
    @property
    def devices(self):
        """
        A list of connected Firewire (IEEE1394) devices represented as 
        instances of AVCCaptureDevice.
        """
        if self.__devices is None:
            self.__devices = [AVCCaptureDevice(d) for d in self.__controller.devices()]
        return self.__devices