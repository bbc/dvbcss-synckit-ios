# <small>dvbcss-synckit-ios</small><br/>CSASynchroniser Framework

[](---START EXCLUDE FROM DOC BUILD---)
* **[Read the documentation](#read-the-documentation)**
[](---END EXCLUDE FROM DOC BUILD---)
* **[Overview](#overview)**
* **[How to use](#how-to-use)**
* **[Run the example app](#run-the-example-app)**

This framework provides a high-level Synchroniser object that Companion Screen Applications can use to synchronise a media object to an external timeline source e.g. a TV video broadcast.

This component provides a high-level funcitonality. It is a facade API over the library components; this API simplifies launching a synchronisation process using the DVB-CSS machinery. This API also provides operations to add media objects to be synchronised by the Synchroniser.

#### Dependencies
This framework requires the following dynamic libraries (iOS frameworks) (found in SyncKit):

  * [SyncKitConfiguration](../SyncKitConfiguration)
  * [SimpleLogger](../SimpleLogger)
  * [VideoPlayer](../VideoPlayer) -
  * [AudioPlayerEngine](../AudioPlayer)
  * [ClockTimelines](../ClockTimelines)
  * [CIIProtocolClient](../CIIProtocolClient)
  * [SyncController](../SyncController)
  * [TimelineSync](../TimelineSync)
  * [WallClockClient](../WallClockSync)



#[](---START EXCLUDE FROM DOC BUILD---)
## Read the documentation
The docs for this framework can be read [here](http://bbc.github.io/dvbcss-synckit-ios/latest/CSASynchroniser).
[](---END EXCLUDE FROM DOC BUILD---)



# Overview

This framework provides a singleton of type [Synchroniser](https://bbc.github.io/dvbcss-synckit-ios/latest/CSASynchroniser/Classes/Synchroniser.html) that enables synchronisation to an device implementing the DVB CSS protocols (such as an HbbTV 2 compliant TV). he DVB-CSS protocols enable Companion devices to build an estimate of this timeline (called **Synchronisation Timeline**) locally and hence know where the TV is at.

1. To use a Synchroniser object, you need to provide these parameters during initialisation:

* ```InterDeviceSyncURL``` - the master device's URL for interdevice synchronisation (obtained from discovery of the TV using DIAL, see [DIALDeviceDiscovery](../DIALDeviceDiscovery) sub-project for examples).
* ```App2AppURL``` - the master device's endpoint for communication between TV apps and companion screen Applications.
* ```TimelineSelector``` - a [TimelineOption](https://bbc.github.io/dvbcss-synckit-ios/latest/CIIProtocolClient/Classes/TimelineOption.html) object specifying the timeline to request from the TV, along with related properties (e.g. tick rate, accuracy).

2. Then, to start using it, call the ```enableSynchronisation``` method to start it communicating with the TV.
3. Create media player (player objects, or player ViewController objects, from the [AudioPlayerEngine](https://bbc.github.io/dvbcss-synckit-ios/latest/AudioPlayerEngine) or [https://bbc.github.io/dvbcss-synckit-ios/latest/VideoPlayer) frameworks) and start it playing.
4. Create a [MediaPlayerObject](https://bbc.github.io/dvbcss-synckit-ios/latest/CSASynchroniser/MediaPlayerObject) and populate it with the media stream URL, the player instance playing it and a Correlation Timestamp mapping the media time to the Synchronisation Timeline time.
5. Add this to the ```Synchroniser``` using the ```addMediaObject``` method.


#### Properties

The Synchroniser has these properties that can be inspected. Updates to these properties are advertised via state changes notifications (```SynchroniserStateNotification``` ) and via callbacks via the [SynchroniserDelegate](CSASynchroniser/docs/Protocols/SynchroniserDelegate.html) interface.

| Name | Type | Description |
| --- | --- | --- |
| ```contentId``` | ```string``` | A content identifier for the content currently shown on the master device |
| ```contentIdStatus``` | ```string``` |  A string with value "partial" or "final" that provides the status of the current contentId |
| ```presentationStatus``` | ```string``` | a string value describing the current status of presentation of Timed Content by the TV  |
| ```availableTimelines``` | ```array``` | Media timelines supported by the TV for synchronisation.|
| ```MRS_URL``` | ```object``` | A [CorrelatedClock](../ClockTimelines/ClockTimelines/CorrelatedClock.h) object representing the internal WallClock. It can be queried for its current time or used to set timers. |
| ```WC_URL``` | ```string``` | The TV's CSS-WC server endpoint URL received from the TV's CSS-CII protocol endpoint |
| ```TS_URL``` | ```string``` | The TV's CSS-TS server endpoint URL received from the TV's CSS-CII protocol endpoint |
| ```MRS_URL``` | ```string``` | The URL for the Material Resolution Service reported by the TV via the  CSS-CII protocol  |
| ```wallclock``` | ```object``` | A [CorrelatedClock](../ClockTimelines/ClockTimelines/CorrelatedClock.h) object representing the internal WallClock. It can be queried for its current time or used to set timers. |
| ```syncTimeline``` | ```object``` | A [CorrelatedClock](../ClockTimelines/ClockTimelines/CorrelatedClock.h) object representing the Synchronisation Timeline. It can be queried for the current time on the timeline. It also has these properties: timeline selector, unitsPerTick, unitsPerSecond and accuracy.|
| ```syncTimelineOffset``` | ```double``` | An offset in fractions of a second to add to the Synchronisation Timeline|
| ```error``` | ```double``` | The current synchronisation error on the timeline synchronisation|


#### Event notifications

The Synchroniser produces the following event notifications:

* ```SynchroniserStateNotification``` - an NSNotification instance reporting the Synchroniser's current state (a [SynchroniserState](CSASynchroniser/docs/Enums/SynchroniserState.html) value accessible in a Dictionary using this key: "SynchroniserStateNotification" )
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



## How to use

#### 1. Add the framework and its dependencies to your project

A Cocoa Pod version of this library is not currently available. To use this library, you must add it and its dependencies to your project.

You will need the following projects from this repository:

  * [SyncKitConfiguration](../SyncKitConfiguration)
  * [SimpleLogger](../SimpleLogger)
  * [VideoPlayer](../VideoPlayer)
  * [AudioPlayerEngine](../AudioPlayer)
  * [ClockTimelines](../ClockTimelines)
  * [CIIProtocolClient](../CIIProtocolClient)
  * [SyncController](../SyncController)
  * [TimelineSync](../TimelineSync)
  * [WallClockClient](../WallClockSync)

Either include them in your workspace and build them; or build them in this repository's [synckit.xcworkspace](../synckit.xcworkspace)

Then add them under *Linked Frameworks and libraries* in your project's target configuration:

  * SyncKitConfiguration.framework
  * SimpleLogger.framework
  * VideoPlayer.framework
  * AudioPlayerEngine.framework
  * ClockTimelines.framework
  * CIIProtocolClient.framework
  * SyncController.framework
  * TimelineSync.framework
  * WallClockClient.framework
  
If you have two XCode instances running you can drag and drop the framework files from their respective project in SyncKit to your own project.


#### 2. Import the header files

Import this header file into your source file:

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


## Run the example app

A example app that demonstrates the use of the Synchroniser is included: [../SyncKitVideoSyncDemoApp](../SyncKitVideoSyncDemoApp). 


## Contact

The original author is Rajiv Ramdhany 'at' bbc.co.uk.


## Licence

The CSASynchroniser iOS Framework is developed by BBC R&D and distributed under Licensed under the Apache License, [Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).

© Copyright 2016 BBC R&D. All Rights Reserved
