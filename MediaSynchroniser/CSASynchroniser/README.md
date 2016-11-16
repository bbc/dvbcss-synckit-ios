# CSASynchroniser iOS Framework Library

* **[How to use](#how-to-use)**
* **[Read the documentation](#read-the-documentation)**
* **[Run the example apps](#run-the-example-apps)**

The CSASynchroniser dynamic library provides a Synchroniser object that Companion Screen Applications can use to synchronise a media object to an external timeline source e.g. a TV video broadcast.

This component provides a facade API over the library components; this API simplifies launching a synchronisation process using the DVB-CSS machinery. This API also provides operations to add media objects to be synchronised by the Synchroniser.

### ```Synchroniser```
A singleton of type ```Synchroniser``` that enables synchronisation to an external timing source e.g. the timeline of a TV programme. The TV exposes a media timeline for synchronisation using the DVB-CSS protocols. The DVB-CSS protocols enable Companion devices to build an estimayte of this timeline (called **Synchronisation Timeline**) locally and hence know where the TV is at. To use a Synchroniser object, you need to provide these parameters during initialisation

* ```InterDeviceSyncURL``` - the master device's URL for interdevice synchronisation (obtained from discovery of the TV using DIAL, see [DIALDeviceDiscovery](../../../DIALDeviceDiscovery) sub-project for examples).
* ```App2AppURL``` - the master device's endpoint for communication between TV apps and companion screen Applications.
* ```TimelineSelector``` - a ```TimelineOption``` object providing a timeline name and other properties (e.g. tick rate, accuracy).

To start the Synchroniser, call the ```enableSynchronisation``` method. Add media objects (players of type ```VideoPlayerViewController```, ```AudioPlayer```, ```AudioStreamPlayer```, etc.) to the Synchroniser using the ```addMediaObject:(MediaPlayerObject*) media_obj``` method. A ```MediaPlayerObject``` contains the media stream URL, the player instance playing it and a Correlation Timestamp mapping the media time to the Synchronisation Timeline time.


#### Properties

The Synchroniser has these properties that can be inspected. Updates to these properties are advertised via state changes notifications (```SynchroniserStateNotification``` ) and via callbacks via the [SynchroniserDelegate](Protocols/SynchroniserDelegate.html) interface.

| Name | Type | Description |
| --- | --- | --- |
| ```contentId``` | ```string``` | A content identifier for the content currently shown on the master device |
| ```contentIdStatus``` | ```string``` |  A string with value "partial" or "final" that provides the status of the current contentId |
| ```presentationStatus``` | ```string``` | a string value describing the current status of presentation of Timed Content by the TV  |
| ```availableTimelines``` | ```array``` | Media timelines supported by the TV for synchronisation.|
| ```MRS_URL``` | ```object``` | A [CorrelatedClock](../../../ClockTimelines/docs/index.html) object representing the internal WallClock. It can be queried for its current time or used to set timers. |
| ```WC_URL``` | ```string``` | The TV's CSS-WC server endpoint URL received from the TV's CSS-CII protocol endpoint |
| ```TS_URL``` | ```string``` | The TV's CSS-TS server endpoint URL received from the TV's CSS-CII protocol endpoint |
| ```MRS_URL``` | ```string``` | The URL for the Material Resolution Service reported by the TV via the  CSS-CII protocol  |
| ```wallclock``` | ```object``` | A [CorrelatedClock](../../../ClockTimelines/docs/index.html) object representing the internal WallClock. It can be queried for its current time or used to set timers. |
| ```syncTimeline``` | ```object``` | A [CorrelatedClock](../../../ClockTimelines/docs/index.html) object representing the Synchronisation Timeline. It can be queried for the current time on the timeline. It also has these properties: timeline selector, unitsPerTick, unitsPerSecond and accuracy.|
| ```syncTimelineOffset``` | ```double``` | An offset in fractions of a second to add to the Synchronisation Timeline|
| ```error``` | ```double``` | The current synchronisation error on the timeline synchronisation|


#### Event notifications

The Synchroniser produces the following event notifications:

* ```SynchroniserStateNotification``` - an NSNotification instance reporting the Synchroniser's current state (a [SynchroniserState](Enums/SynchroniserState.html) value accessible in a Dictionary using this key: "SynchroniserStateNotification" )
* ```SynchroniserSyncAccuracyNotification``` - an NSNotification instance reporting when the synchronisation accuracy threshold has been exceeded
* ```SynchroniserNewContentIdNotification``` - an NSNotification instance reporting when the TV advertises a new contentId via the CSS-CII protocol. The Dictionary object attached to this event contains a ```CII``` object (acessible using the key "SynchroniserNewContentIdNotification"). The new contentId is included in this CII object. Alternatively, the contentId can be read from the Synchroniser's contentId property.
* ```SynchroniserSyncTimelinesAvailableNotification``` - an NSNotification instance reporting when the synchronisation timeline has become available. The companion's estimated Synchronisation Timeline can be accessed directly from the Synchroniser's ```syncTimeline``` property.

#### Useful operations

##### getInstance

Get the ```Synchroniser``` instance.

##### Initialisers
 To initialise  method ```initWithInterDeviceSyncURL:App2AppURL:TimelineSelector:Delegate```

##### ```enableSynchronisation()```
Starts the Synchroniser object's sync operation. This will trigger connection requests to be sent to synchronisation services. The availability of the Synchronisation Timeline is signalled to the application via an event/callback..

##### ```disableSynchronisation()```
Disables the interdevice/distributed synchronisation running in an application. Closes connections to synchronisation protocol endpoints. The Synchroniser object goes back to the initialized state. The ```enableSynchronisation()``` method can be called to enable sync again.

### Dependencies
The CSASynchroniser library requires the following dynamic libraries (iOS frameworks) (found in SyncKit):

1. [SyncKitConfiguration](../../../SyncKitConfiguration)
2. [SimpleLogger](../../../SimpleLogger)
3. [VideoPlayer](../../../VideoPlayer) -
4. [AudioPlayerEngine](../../../AudioPlayer)
5. [ClockTimelines](../../../ClockTimelines)
6. [CIIProtocolClient](../../../CIIProtocolClient)
7. [SyncController](../../../SyncController)
8. [TimelineSync](../../../TimelineSync)
9. [WallClockClient](../../../WallClockSync)



## Read the documentation
The docs for the library can be read [here](index.html).

## How to use
A Cocoa Pod version of this library is not currently available. To use this library, follow these steps

#### Add the framework and its dependencies to your project

1. *Add the required projects to your workspace*

  The easiest way to use the CSASynchroniser framework is to include these Xcode projects to your XCode workspace.

  1. [SyncKitConfiguration](../../../SyncKitConfiguration)
  2. [SimpleLogger](../../../SimpleLogger)
  3. [VideoPlayer](../../../VideoPlayer) -
  4. [AudioPlayerEngine](../../../AudioPlayer)
  5. [ClockTimelines](../../../ClockTimelines)
  6. [CIIProtocolClient](../../../CIIProtocolClient)
  7. [SyncController](../../../SyncController)
  8. [TimelineSync](../../../TimelineSync)
  9. [WallClockClient](../../../WallClockSync)

  Then, after building these projects, go to your project's target window and *click on project in Project Navigator, then the project's target on right window in General tab*), add these frameworks in the *Linked Frameworks and libraries* section: *SyncKitConfiguration.framework, SimpleLogger.framework, VideoPlayer.framework, AudioPlayerEngine.framework, ClockTimelines.framework, CIIProtocolClient.framework, SyncController.framework, TimelineSync.framework, WallClockClient.framework* .

2. *Add the dynamic libraries to your project*

  Or alternatively, clone the SyncKit repository, open the main workspace and build all the projects to generate the dynamic libraries.

  Then, in your project's target window (*click on project in Project Navigator, then the project's target on right window in General tab*), add the framework files in the *Linked Frameworks and libraries* section: *SyncKitConfiguration.framework, SimpleLogger.framework, VideoPlayer.framework, AudioPlayerEngine.framework, ClockTimelines.framework, CIIProtocolClient.framework, SyncController.framework, TimelineSync.framework, WallClockClient.framework*.
  If you have two XCode instances running you can drag and drop the framework files from their respective project in SyncKit to your own project.
  Alternatively, you can include the dynamic libraries from their build locations.

3. *Use the Cocoa Pod version*

  Not available yet.

#### Import the header files

Once the library and its dependencies have been added to your project, import this header file in your source file:

```objective-c

#import <CSASynchroniser/CSASynchroniser.h>

```
#### Create and configure a Synchroniser object

Create a timeline selector object of type TimelineOption

```objective-c

NSString* const SET_TimelineSelector = @"tag:rd.bbc.co.uk,2015-12-08:dvb:css:timeline:simple-elapsed-time:1000";
int const SET_UnitsPerTick = 1;
int const SET_UnitsPerSecond = 1000;

timelineOpt = [TimelineOption TimelineOptionWithSelector:SET_TimelineSelector
                                               UnitsPerTick:SET_UnitsPerTick
                                             UnitsPerSecond:SET_UnitsPerSecond
                                                   Accuracy:0];
```

Then, create a Synchroniser object using the ```HbbTV_InterDevSyncURL``` and ```HbbTV_App2AppURL``` values reported from your DIAL client.
The DIALDeviceDiscovery component provides a list of ```DIALDevice``` objects, each representing an HbbTV device discovered on the network.
A DIALDevice object will contain information such as ```HbbTV_InterDevSyncURL``` and ```HbbTV_App2AppURL```.

Start the Synchroniser using the `enableSynchronisation` method and specifying a

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


#### Add media objects to be synchronised

To synchronise a media player playing a stream, first use the media player to create a ```MediaPlayerObject``` instance.  Add a correlation timestamp to the ```MediaPlayerObject``` instance. The correlation timestamp is a pair of timestamps mapping a time on the Synchronisation Timeline (the TV timeline) to the media time.

Next, add the media player object to the Synchroniser.

```objective-c

     // create a video player
     __weak UIViewController<VideoPlayerDelegate> *weakVideoPlayerDelegate = self;
     VideoPlayerViewController* videoplayer = [[VideoPlayerViewController alloc] initWithParentView:self.view
                                                                Delegate:weakVideoPlayerDelegate];

   // create a MediaPlayerObject out of the video player
    MediaPlayerObject* mediaPlayerObj = [[MediaPlayerObject alloc] init];
    mediaPlayerObj.mediaURL = @"http://192.168.1.106/~rajivr/video/channelB/index.m3u8";

    // assuming that the companion video starts when the TV programme starts
    Correlation corel = [CorrelationFactory create:0 Correlation:0];
    mediaPlayerObj.correlation = corel;
    mediaPlayerObj.mediaPlayer = videoplayer;

    // Make the video player play the stream
    videoplayer.videoURL = [NSURL URLWithString:mediaPlayerObj.mediaURL];

    // Add the media object to the Synchroniser to be synchronised.
    [mediaSynchroniser addMediaObject:self.mediaObject];

```


#### Remove media objects when they are no longer relevant

This can be done by simply calling the ```removeMediaObject``` method.

```objective-c

  [mediaSynchroniser removeMediaObject:mediaPlayerObj];

    // clean up video player
    VideoPlayerViewController *videoPlayer = (VideoPlayerViewController*) _mediaObject.mediaPlayer;

    [videoPlayer stopAndRemoveFromParentView];

    videoPlayer.delegate = nil;

```


## Run the example apps

A example app that demonstrates the use of the Synchroniser is included here: [../../SyncKitVideoSyncDemoApp](). This example shows how to use the
Synchroniser object to synchronise an HLS stream to a TV. The example app assumes that the TV is playing the `channel_B_video.mp4` MP4 video file.

The HLS stream and other test assets can be downloaded from: https://hbbtv-2-0-testing-1.virt.ch.bbc.co.uk/downloads/simple-free-sync-seq-1.zip

An implementation of the TV is not included.


In the demo app project, you will need to specify the following constants:

```objective-c
// the URL of the companion asset to play (can be an HLS stream or a video file)
NSString* const kCompanionVideoURL = @"http://192.168.1.106/~rajivr/video/channelB/index.m3u8";
// the contentId reported by the TV
NSString* const kContentId_ChannelB = @"http://127.0.0.1:8123/channel_B_video.mp4";


```

To discover the contentId and timelines available for synchronisation , you may use a CII client to connect to your TV.

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
* Available timelines are given by the **timelines** field,

## Contact

The original author is Rajiv Ramdhany 'at' bbc.co.uk.


## Licence

The CSASynchroniser iOS Framework is developed by BBC R&D and distributed under Licensed under the Apache License, [Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).

© Copyright 2016 BBC R&D. All Rights Reserved
