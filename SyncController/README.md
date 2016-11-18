# <small>dvbcss-synckit-ios</small><br/>SyncController Framework

* **[How to use](#how-to-use)**
* **[Read the documentation](#read-the-documentation)**
* **[Run the example apps](#run-the-example-apps)**

This library provides SyncController classes that can be used to synchronise a native media player to a given timeline.
Currently, a SyncController class is provided for each media player/web kit. Coalescing the various implementations into a single SyncController is in the works.

SyncController objects must be initialised with at least the following objects:
* a media player ([VideoPlayerViewController](), [AudioPlayer](), [AudioStreamPlayer]() instances or in the case of a web view,  a UIWebView instance)
* a timeline to synchronise to (e.g. the Synchronisation Timeline - our local estimate of the TV's timeline)
* a correlation timestamp (a pair of timestamps) describing the relationship between the media timeline and the Synchronisation Timeline

### Dependencies
The CIIProtocolClient library requires the following dynamic libraries (iOS frameworks) (found in SyncKit):

1. [SyncKitConfiguration](../../SyncKitConfiguration)
2. [SimpleLogger](../../SimpleLogger)
3. [VideoPlayer](../../VideoPlayer) -
4. [AudioPlayerEngine](../../AudioPLayer) - the SocketRocket web socket library
5. [ClockTimelines](../../ClockTimelines)



## Read the documentation
The docs for the library can be read [here](SyncController/docs/index.html).

## How to use

A Cocoa Pod version of this library is not currently available. To use this library, follow these steps

#### Add the framework and its dependencies to your project

1. *Add the required projects to your workspace*

  The easiest way to use the CIIProtocolClient framework is to include these Xcode projects to your XCode workspace.

  1. [SyncKitConfiguration](../../SyncKitConfiguration)
  2. [SimpleLogger](../../SimpleLogger)
  3. [VideoPlayer](../../VideoPlayer) -
  4. [AudioPlayerEngine](../../AudioPLayer) - the SocketRocket web socket library
  5. [ClockTimelines](../../ClockTimelines)

  Then, after building these projects, go to your project's target window and *click on project in Project Navigator, then the project's target on right window in General tab*), add these frameworks in the *Linked Frameworks and libraries* section: *SyncKitConfiguration.framework, SimpleLogger.framework, VideoPlayer.framework, AudioPlayerEngine.framework, ClockTimelines.framework*.

2. *Add the dynamic libraries to your project*

  Or alternatively, clone the SyncKit repository, open the main workspace and build all the projects to generate the dynamic libraries.

  Then, in your project's target window (*click on project in Project Navigator, then the project's target on right window in General tab*), add the framework files in the *Linked Frameworks and libraries* section: *SyncKitConfiguration.framework, SimpleLogger.framework, VideoPlayer.framework, AudioPlayerEngine.framework, ClockTimelines.framework*.
  If you have two XCode instances running you can drag and drop the framework files from their respective project in SyncKit to your own project.
  Alternatively, you can include the dynamic libraries from their build locations

3. *Use the Cocoa Pod version*

  Not available yet.

#### Import the header files

Once the library and its dependencies have been added to your project, import this header file in your source file:

```objective-c

#import <SyncController/SyncController.h>

```
#### Create and configure a video SyncController object

When a Synchronisation Timeline is available, a VideoPlayerSyncController can be initialised with a video player, the Synchronisation Timeline and a correlation timestamp and then started. The change in the `available` property is observed using Key-Value-Observer pattern.

A SyncController object uses a timer to trigger a resync operation (reevaluating the media player's current time w.r.t. the expected media time). The

The resync algorithm uses a simple strategy to catchup - if the asynchrony between the media player and the TV is more than `reSyncJitterThreshold` seconds, it requests the media player to seek to the new time position.
The default value is 0.02s for the `reSyncJitterThreshold` of a VideoPlayerSyncController object is `0,02s`.

More sophisticated resync strategies are described in the companion BBC WhitePaper: *"How to synchronise to an HbbTV 2.0 compliant TV: A tutorial for companion app developers"* available [here]().


```objective-c
...
@property(nonatomic, readwrite) VideoPlayerSyncController * vSyncController;
...

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (context == WallClockContext) {
        if ([keyPath isEqualToString:kAvailableKey])
        {
            NSNumber *newAvailability = [change objectForKey:@"new"];

            NSLog(@"ViewController: WallClock is synchronised.");

            // only start timeline sync when wallclock is in sync
            if (([newAvailability boolValue] == YES) && (_tvTimelineSyncer==nil)){
                NSLog(@"ViewController: synchronising timeline");
                [self startTimelineSync];
            }

        }
     }
    else if (context == TVTimelineContext) {

      if ([keyPath isEqualToString:kAvailableKey]) {

            BOOL oldTVTimelineAvailable = [[change objectForKey:@"old"]boolValue];
            BOOL newTVTimelineAvailable = [[change objectForKey:@"new"]boolValue];

            if (newTVTimelineAvailable){

                // start the video player
                [self startVideo];

                // setup a sync controller for video player
                Correlation corel = [CorrelationFactory create:0 Correlation:0];

                self.vSyncController = [VideoPlayerSyncController
                                        syncControllerWithVideoPlayer:self.videoPlayer
                                                        SyncTimeline:self.tvTimeline
                                                CorrelationTimestamp:&corel
                                                        SyncInterval:4.0
                                                        AndDelegate:self];
                [self.vSyncController start];
            }
        }
    }
}

```

#### Observe the SyncController status
Each SyncController object can have a delegate that conforms  [SyncControllerDelegate](SyncController/SyncController/SyncControllerDelegate.h) protocol. The delegate will then receive callbacks when the SyncController changes state. Possible SyncController states are:

```objective-c

typedef NS_ENUM(NSUInteger, VideoSyncControllerState)
{
    VideoSyncCrtlInitialised = 1,
    VideoSyncCrtlRunning,
    VideoSyncCrtlStopped,
    VideoSyncCrtlPaused,
    VideoSyncCrtlSynchronising,
    VideoSyncCrtlSyncTimelineUnavailable,
    VideoSyncCrtlSyncTimelineAvailable
};

```

Here is an example of a state change callback handler:


```objective-c

- (void) SyncController:(id) controller DidChangeState:(NSUInteger) state
{
    if (state == VideoSyncCrtlSyncTimelineAvailable) {

        if (![self.videoPlayer isPlaying])
        {
            [self.videoPlayer play];
        }
    }
}

```


## Run the example apps

Three demo apps are included with this library:
* [VideoSyncDemoApp](VideoSyncDemoApp/) - synchronising an HLS stream or a file-based video asset to a DVB-CSS TV
* [AudioSyncDemoApp](AudioSyncDemoApp/) - synchronising an audio stream (mp3, aac, etc.) to a DVB-CSS TV
* [WebViewSyncDemoApp](WebViewSyncDemoApp) - synchronising a web page animation to a DVB-CSS TV

To run these demo apps, you'll need the companion and TV assets. You can download them [here](https://hbbtv-2-0-testing-1.virt.ch.bbc.co.uk/downloads/simple-free-sync-seq-1.zip).

In each demo app project, you will need to specify the following constants:

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
