#!/usr/bin/python

import sys
import os
import time
import optparse
import avc

def parse_duration_to_seconds(d):
    """
    Parse a human-readable duration in the format hh:mm:ss 
    to seconds. Accepts: hh:mm:ss, mm:ss, ss
    """
    particles = [int(p) for p in d.split(':')]
    particles.reverse()
    if len(particles) > 3:
        raise ValueError('Too many colons in duration.')
    return sum([p * pow(60, i) for i, p in enumerate(particles)])

def main():
    # parse command line options
    parser = optparse.OptionParser()
    parser.add_option('-o', '--output', dest="output_path", default="~/Desktop/video.m2t")
    parser.add_option('-c', '--channel', dest="channel", default=0, type="int")
    parser.add_option('-d', '--duration', dest="duration", default="00:01:00")
    options, remainder = parser.parse_args() # parse command line arguments
    
    try:
        # initialize the capture interface and select the first device
        interface = avc.AVCCaptureInterface()
        my_device = interface.devices[0]
        
        # if we defined a channel to record to (other than 0), tune to it
        if options.channel != 0:
            my_device.tune_channel(options.channel)
            
        # open an output file for recording and begin doing so
        fh = open(os.path.expanduser(options.output_path), 'wb')
        my_device.begin_recording(fh) # begin recording
        
        # loop while updating a status until we've recorded for the desired duration
        total_time = parse_duration_to_seconds(options.duration)
        elapsed_time = 0
        while 1:
            # we'll make ourselves a status line!
            sys.stdout.write('\rRecording Ch. %d - Elapsed: %ds, Remaining: %ds%s' % \
                (options.channel, elapsed_time, total_time - elapsed_time, ' ' * 8))
            sys.stdout.flush()
            time.sleep(1)
            elapsed_time += 1
            if(elapsed_time >= total_time):
                break
        
        # clean up
        fh.close()
        sys.stdout.write('\rRecording complete -> %s\n\n' % options.output_path)
    
    except avc.AVCCaptureException, e:
        print 'An error occurred:', e.message

if __name__ == '__main__':
    main() # if we're calling from the command line, then run it.
