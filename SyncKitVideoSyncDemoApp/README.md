# A Video Stream Synchronisation Demo App using SyncKit's Synchroniser object

This demo app demonstrates the synchronisation of companion videos to a broadcast stream that embeds a TEMI timeline.

It provides an example of how to the use of the SyncKit library's Synchroniser object. It shows how in response to a change of contentId signalled by the TV, the companion screen app can load a relevant media object and register it with a Synchroniser object for synchronisation.

To run the demo app, follow these steps

### Step 1: Open the demo app

This demo app is part of the [dvbcss-synckit-ios](../) distribution. After you have cloned the repository, open the workspace `synckit.xcworkspace` in XCode.

The code for the demo app is in the `SyncKitVideoSyncDemoApp` project.

### Step 2:  Get the TV and companion Content

The example app assumes that the TV is playing the **"mux.ts.24mbit.with_temi.ts"** broadcast transport stream. This transport stream has both PTS and TEMI timelines signalled in it. The demo companion app uses the TEMI timeline for synchronisation (switching to PTS timeline is trivial).

The broadcast transport stream and companion content for each of the channels it contains are available from this site: https://hbbtv-2-0-testing-1.virt.ch.bbc.co.uk/downloads/simple-free-sync-seq-1.zip

Download this zipped file and extract it into a known location on your build device.

Rename the following files as suggested:
1. `channel_a.companion/video.mp4` file to `channel_a.companion/video_a.mp4`
1. `channel_b.companion/video.mp4` file to `channel_b.companion/video_b.mp4`
1. `channel_c.companion/video.mp4` file to `channel_c.companion/video_c.mp4`

### Step 3: Add the companion content to the demo app

In the `SyncKitVideoSyncDemoApp` project, right-click on the `Supporting Files` folder and select the `Add files to SyncKitVideoSyncDemoApp ..` option.

In the dialog that follows, select these files from the location where you originally downloaded them and add them to `SyncKitVideoSyncDemoApp` project:
1. `channel_a.companion/video_a.mp4`
1. `channel_b.companion/video_b.mp4`
1. `channel_c.companion/video_c.mp4`

### Step 4: Build the demo app

In XCode, select the `SyncKitVideoSyncDemoApp` build scheme and launch the build process to deploy the app into a selected target iOS device (or iOS simulator).   

The 





## ContentId and Available Timelines for Sync
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
