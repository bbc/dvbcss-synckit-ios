# <small>dvbcss-synckit-ios</small><br/>SyncController Framework

* **[Overview](#overview)**
[](---END EXCLUDE FROM DOC BUILD---)
* **[How to use](#how-to-use)**
[](---START EXCLUDE FROM DOC BUILD---)
* **[Read the documentation](#read-the-documentation)**
* **[Run the example apps](#run-the-example-apps)**


## Overview

TODO (Matt): write something here summarising what is in this library and how it works, once Rajiv has updated the more detailed stuff below.

This framework provides *SyncController* classes that can be used to synchronise a native media player to a given timeline. The timeline source should be available on the local network and advertised via DVB-CSS protocols.

Currently, a distinct *SyncController* class is provided for each media player/web kit.

To synchronise a [VideoPlayer](https://github.com/bbc/dvbcss-synckit-ios/tree/master/VideoPlayer) object, a [VideoPlayerSyncController](https://github.com/bbc/dvbcss-synckit-ios/blob/master/SyncController/SyncController/SyncController/VideoPlayerSyncController.h) must be be initialised with the following:
* the **video player** (only [VideoPlayer](https://github.com/bbc/dvbcss-synckit-ios/tree/master/VideoPlayer) objects accepted currently)
* a **Synchronisation Timeline** (timeline to synchronise to e.g. our local estimate of the TV's timeline)
* a **Correlation Timestamp** (a pair of timestamps) describing the mapping between the media timeline and the Synchronisation Timeline

[AudioSyncController](https://github.com/bbc/dvbcss-synckit-ios/blob/master/SyncController/SyncController/SyncController/AudioSyncController.h) and [WebViewSyncController](https://github.com/bbc/dvbcss-synckit-ios/blob/master/SyncController/SyncController/SyncController/WebViewSyncController.h) objects are initialised in the same way.


#### Dependencies

This framework requires the following dynamic libraries (iOS frameworks) (all found in the  dvbcss-synckit-ios repository):

  * [SyncKitConfiguration](../SyncKitConfiguration)
  * [SimpleLogger](../SimpleLogger)
  * [VideoPlayer](../VideoPlayer)
  * [AudioPlayerEngine](../AudioPlayer)
  * [ClockTimelines](../ClockTimelines)



## How to use

#### 1. Add the framework and its dependencies to your project

To use this library, you must add it and its dependencies to your project. (CocoaPod dependency management currently not supported).

You must build and import these frameworks into your project
  * [SyncController](./)
  * [SyncKitConfiguration](../../SyncKitConfiguration)
  * [SimpleLogger](../../SimpleLogger)
  * [VideoPlayer](../../VideoPlayer)
  * [AudioPlayerEngine](../../AudioPLayer)
  * [ClockTimelines](../../ClockTimelines)

  Either include the project for each framework you need into your own project workspace and build it; or build in in this repository's [synckit.xcworkspace](https://github.com/bbc/dvbcss-synckit-ios/blob/master/synckit.xcworkspace).

  Then add the frameworks you need under Linked Frameworks and libraries in your project's target configuration.
https://github.com/bbc/dvbcss-synckit-ios/blob/master/how-to-import.md

There is some [more detailed guidance on how to do this](https://github.com/bbc/dvbcss-synckit-ios/blob/master/how-to-import.md) if you need it.


#### 2. Create and configure a SyncController object (e.g VideoPlayerSyncController)

Import this header file into your source file:

```objective-c

#import <SyncController/SyncController.h>

```

If you have not created a media player (e.g. video player), create it and load a video asset as follows:

*(Note: only [VideoPlayer](https://github.com/bbc/dvbcss-synckit-ios/tree/master/VideoPlayer), [AudioPlayer](../AudioPlayer) and UIWebView objects are currently supported)*

```objective-c
  VideoPlayerViewController *videoPlayer = [[VideoPlayerViewController alloc] initWithParentView:self.view Delegate:self];

  NSURL *url = [NSURL URLWithString:@"http://localhost/~rajivr/video/channelB/index.m3u8"];
  videoPlayer.videoURL = url;
  videoPlayer.shouldLoop = YES;
```

Then, create a SyncController object for it as follows and start it. You will need to supply the following *a)* the video player object, *b)* a sync timeline and *c)* a correlation mapping the media timeline to the sync timeline.

```objective-c

// setup a sync controller for video player
  Correlation corel = [CorrelationFactory create:0 Correlation:0];

  VideoPlayerSyncController * vSyncController;
  vSyncController = [VideoPlayerSyncController
                        syncControllerWithVideoPlayer:videoPlayer
                                        SyncTimeline:tvTimeline
                                CorrelationTimestamp:&corel
                                        SyncInterval:4.0
                                        AndDelegate:self];
  [self.vSyncController start];

```

When the ```VideoPlayerSyncController``` object detects that the ```tvTimeline``` timeline is available, it will start the video player and synchronise it. The ```VideoPlayerSyncController``` object will periodically re-evaluate the video player's playback and make corrections if necessary to make it realign itself to the sync timeline.

You can control the frequency of this re-evaluation by specifying a value for the ```SyncInterval``` parameter in the constructor method.

The status of all sync controller objects can be monitored via the delegate mechanism. Each sync controller object can be initialised with a delegate object.



[](---START EXCLUDE FROM DOC BUILD---)
## Read the documentation
The docs for this framework can be read [here](http://bbc.github.io/dvbcss-synckit-ios/latest/SimpleLogger/SyncController).
[](---END EXCLUDE FROM DOC BUILD---)

## Run the example apps

Three demo apps are included with this library:
* [VideoSyncDemoApp](VideoSyncDemoApp/) - synchronising an HLS stream or a file-based video asset to a DVB-CSS TV
* [AudioSyncDemoApp](AudioSyncDemoApp/) - synchronising an audio stream (mp3, aac, etc.) to a DVB-CSS TV
* [WebViewSyncDemoApp](WebViewSyncDemoApp) - synchronising a web page animation to a DVB-CSS TV

To run these demo apps, you'll need the companion and TV assets. You can download them [here](https://hbbtv-2-0-testing-1.virt.ch.bbc.co.uk/downloads/simple-free-sync-seq-1.zip).

In each demo app project, you will need to specify values for the following constants:

```objective-c

NSString *serverAddress     = @"192.168.1.74";    // TV's IP address
NSString *contentId         = @"http://127.0.0.1:8123/channel_B_video.mp4";  // contentId of TV asset
NSString *timelineSelector  = @"tag:rd.bbc.co.uk,2015-12-08:dvb:css:timeline:simple-elapsed-time:5000";
NSString *tsEndpointURL     = @"ws://192.168.1.74:7681/ts";
int tick_rate = 5000;

```

To discover valid values for the `contentId`, `timelineSelector` and `tsEndpointURL`, you may use a CII client to connect to your TV.

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
* The timelineSelector is **"tag:rd.bbc.co.uk,2015-12-08:dvb:css:timeline:simple-elapsed-time:5000"**,
* The timeline synchronisation server (tsURL) is **ws://10.5.11.163:7681/ts**



## Licence

The SyncController iOS Framework is developed by BBC R&D and distributed under Licensed under the Apache License, [Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).

© Copyright 2016 BBC R&D. All Rights Reserved
