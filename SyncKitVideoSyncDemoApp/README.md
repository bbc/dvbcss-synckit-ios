# A Video Stream Synchronisation Demo App using SyncKit's Synchroniser object

This example app demonstrates the use of the SyncKit library's Synchroniser. This example shows how to use the
Synchroniser object to synchronise an HLS stream to a TV. The example app assumes that the TV is playing the `channel_B_video.mp4` MP4 video file.

The HLS stream and other test assets can be downloaded from: https://hbbtv-2-0-testing-1.virt.ch.bbc.co.uk/downloads/simple-free-sync-seq-1.zip


In the demo app project, you will need to specify the following constants:

```objective-c
// the URL of the companion asset to play (can be an HLS stream or a video file)
NSString* const kCompanionVideoURL = @"http://192.168.1.106/~rajivr/video/channelB/index.m3u8";
// the contentId reported by the TV
NSString* const kContentId_ChannelB = @"http://127.0.0.1:8123/channel_B_video.mp4";


```
If you would like to synchronise a local video file, then add the file to the project and update ```NSString* const kCompanionVideoURL``` with the file path.
Note: An implementation of the TV is not included.

##ContentId and Available Timelines for Sync
Assuming you have an HbbTV2.0 compliant TV/device on the network, or a DVB-CSS TV emulator, it is possible to discover its current content identifier and the timelines the device exposes for synchronisation.

To do this , you may use a CII client to connect to your TV. One is available within the [pydvbcss](https://github.com/bbc/pydvbcss) distribution. 

Run a CII protocol python client as follows:

```bash
$ python examples/CIIClient.py ws:/<TV_IP_ADDRESS>:7681/cii

```

What the received CII info may look like:
```bash

RD000400:pydvbcss rajivr$ python examples/CIIClient.py ws://10.5.11.163:7681/cii
INFO:CIIClient:connected
INFO:CIIClient:change to presentationStatus property. Value is now: [u'okay']
INFO:CIIClient:change to protocolVersion property. Value is now: 1.1
INFO:CIIClient:change to mrsUrl property. Value is now: None
INFO:CIIClient:change to timelines property. Value is now: [TimelineOption(timelineSelector="tag:rd.bbc.co.uk,2015-12-08:dvb:css:timeline:simple-elapsed-time:5000", unitsPertick=1, unitsPerSecond=5000, accuracy=OMIT private=OMIT), TimelineOption(timelineSelector="tag:rd.bbc.co.uk,2015-12-08:dvb:css:timeline:simple-elapsed-time:1000", unitsPertick=1, unitsPerSecond=1000, accuracy=OMIT private=OMIT)]
INFO:CIIClient:change to tsUrl property. Value is now: ws://10.5.11.163:7681/ts
INFO:CIIClient:change to wcUrl property. Value is now: udp://10.5.11.163:6677
INFO:CIIClient:change to contentIdStatus property. Value is now: final
INFO:CIIClient:change to contentId property. Value is now: http://127.0.0.1:8123/channel_B_video.mp4
INFO:CIIClient:CII is now: CII(presentationStatus=[u'okay'], protocolVersion=u'1.1', mrsUrl=None, timelines=[TimelineOption(timelineSelector="tag:rd.bbc.co.uk,2015-12-08:dvb:css:timeline:simple-elapsed-time:5000", unitsPertick=1, unitsPerSecond=5000, accuracy=OMIT private=OMIT), TimelineOption(timelineSelector="tag:rd.bbc.co.uk,2015-12-08:dvb:css:timeline:simple-elapsed-time:1000", unitsPertick=1, unitsPerSecond=1000, accuracy=OMIT private=OMIT)], tsUrl=u'ws://10.5.11.163:7681/ts', wcUrl=u'udp://10.5.11.163:6677', contentIdStatus=u'final', contentId=u'http://127.0.0.1:8123/channel_B_video.mp4')

```
* The contentId in this example is **"http://127.0.0.1:8123/channel_B_video.mp4"**
* Available timelines are given by the **timelines** field.

## Using a timeline for sync
You can use one of the listed timelines for synchronisation. For example, in [SyncKitVideoSyncDemoApp/ViewController.m](SyncKitVideoSyncDemoApp/ViewController.m) create a timeline selector object of type TimelineOption

```objective-c

NSString* const SET_TimelineSelector = @"tag:rd.bbc.co.uk,2015-12-08:dvb:css:timeline:simple-elapsed-time:1000";
int const SET_UnitsPerTick = 1;
int const SET_UnitsPerSecond = 1000;

timelineOpt = [TimelineOption TimelineOptionWithSelector:SET_TimelineSelector
                                               UnitsPerTick:SET_UnitsPerTick
                                             UnitsPerSecond:SET_UnitsPerSecond
                                                   Accuracy:0];
```

In ```- (void) viewDidLoad``` method,  a Synchroniser object is created using the ```HbbTV_InterDevSyncURL``` and ```HbbTV_App2AppURL``` values reported from the DIAL client.

The DIALDeviceDiscovery component provides a list of ```DIALDevice``` objects, each representing an HbbTV device discovered on the network.
A DIALDevice object will contain information such as ```HbbTV_InterDevSyncURL``` and ```HbbTV_App2AppURL```.

The Synchroniser using the `enableSynchronisation` method 

```objective-c
        // get the environment's Synchroniser and intialise it
        Synchroniser mediaSynchroniser = [Synchroniser getInstance];
        [mediaSynchroniser initWithInterDeviceSyncURL:device.HbbTV_InterDevSyncURL
                                                                            App2AppURL:device.HbbTV_App2AppURL
                                                                          MediaObjects:nil
                                                                      TimelineSelector:timelineOpt
                                                                              Delegate:self];
        /// Start the Synchroniser                                                  
        [mediaSynchroniser enableSynchronisation:kSyncAccuracyThreshold
                                                   Error:nil];
```

## Contact

The original author is Rajiv Ramdhany 'at' bbc.co.uk.


## Licence

The CSASynchroniser iOS Framework is developed by BBC R&D and distributed under the Apache License, [Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).

© Copyright 2016 BBC R&D. All Rights Reserved
