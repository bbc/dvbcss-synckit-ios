# TimelineSync iOS Framework Library

* **[How to use](#how-to-use)**
* **[Read the documentation](#read-the-documentation)**
* **[Run the example app](#run-the-example-app)**


A Timeline Synchroniser based on the CSS-TS protocol specified in the [DVB-CSS](https://www.dvb.org/resources/public/standards/a167-2_dvb-css_part_2_content-ID-and-media-sync_June2016.pdf) and [HbbTV2.0](http://www.etsi.org/deliver/etsi_ts%5C102700_102799%5C102796%5C01.03.01_60%5Cts_102796v010301p.pdf) specifications . It is used by Companion Screen applications to synchronise their local estimate of a timeline to an external source of time e.g. the timeline of a media stream played by a TV.


Given a CSS-TS WebSocket address and a CorrelatedClock object for the Synchronisation Timeline, the TimelineSync library will broker a connection with the Timeline Synchronisation server to receive Control Timestamps on a particular timeline. A TV broadcast stream may have many timelines signalled within it. In the setup phase, the TimelineSync library passes a timeline selector string to the CSS-TS server to specify the timeline to choose as the Synchronisation Timeline.

Hints about timeline available for synchronisation may be received via the CSS-CII protocol. The timeline selector string can be chosen from the list of available timelines advertised by the TV via the CSS-CII protocol.  The [CIIProtocolClient](../CIIProtocolClient) component is responsible for reporting CII state information.

[TimelineSynchroniser](TimelineSync/TimelineSynchroniser.h) is the main class in this library. It will create a TSClient instance (a client of the CSS-TS protocol) and register for Control Timestamps delivery notifications. The TSClient class is responsible of setting up the connection to the CSS-TS server and receive protocol messages which contain a Control Timestamp.

The TimelineSynchroniser, on receiving a Control Timestamp, updates the Synchronisation Timeline CorrelatedClock object. On the first update, this clock's availability changes to true and observers notified about this change in status.


### Dependencies
The TimelineSync library requires the following dynamic libraries (iOS frameworks) (these are found in SyncKit):

1. [SyncKitConfiguration](../SyncKitConfiguration)
2. [SimpleLogger](../SimpleLogger)
3. [SocketRocket](../SocketRocket) - the SocketRocket web socket library
4. [SyncKitCollections](../SyncKitCollections)
5. [JSONModelFramework](../JSONModelFramework)
6. [ClockTimelines](../ClockTimelines)



## Read the documentation
The docs for the library can be read [here](TimelineSync/docs/index.html).

## How to use

A Cocoa Pod version of this library is not currently available. To use this library, follow these steps

#### Add the framework and its dependencies to your project

1. *Add the required projects to your workspace*

  The easiest way to use the TimelineSync framework is to include these Xcode projects to your XCode workspace.

  1. [SyncKitConfiguration](../SyncKitConfiguration)
  2. [SimpleLogger](../SimpleLogger)
  3. [SocketRocket](../SocketRocket) - the SocketRocket web socket library
  4. [SyncKitCollections](../SyncKitCollections)
  5. [JSONModelFramework](../JSONModelFramework)
  6. [ClockTimelines](../ClockTimelines)
  7. [TimelineSync]()

  Then, after building these projects, go to your project's target window and *click on project in Project Navigator, then the project's target on right window in General tab*), add these frameworks in the *Linked Frameworks and libraries* section: *SyncKitConfiguration.framework, SimpleLogger.framework, SocketRocketiOS.framework, SyncKitCollections.framework, JSONModelFramework.framework, ClockTimelines.framework, TimelineSync.framework*.

2. *Add the dynamic libraries to your project*

  Or alternatively, clone the SyncKit repository, open the main workspace and build all the projects.

  Then, in your project's target window (*click on project in Project Navigator, then the project's target on right window in General tab*), add the framework files in the *Linked Frameworks and libraries* section:  *SyncKitConfiguration.framework, SimpleLogger.framework, SocketRocketiOS.framework, SyncKitCollections.framework, JSONModelFramework.framework, ClockTimelines.framework, TimelineSync.framework*.
  If you have two XCode instances running you can drag and drop the framework files from their respective project in SyncKit to your own project.

3. *Use the Cocoa Pod version*

  Not available yet.

#### Import the header files

Once the library and its dependencies have been added to your project, import this header file in your source file:

```objective-c

  #import <TimelineSync/TimelineSync.h>

```
#### Create and configure a TimelineSynchroniser object

Create and start a TimelineSynchroniser when the WallClock becomes available. Use iOS's Key-Value-Observation mechanism to observe
the WallClock's `kAvailableKey` (i.e. its Available property).


```objective-c

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (context == WallClockContext) {
        if ([keyPath isEqualToString:kAvailableKey])
        {
            NSNumber *newAvailability = [change objectForKey:@"new"];

            // only start timeline sync when wallclock is in sync
            if (([newAvailability boolValue] == YES) && (tvPTSTimelineSyncer==nil)){
                [self startTimelineSync];
            }
        }
    }

```

This is how the TimelineSynchroniser is started.

```objective-c
- (void)startTimelineSync {
    // -- start Timeline Sync ----
    // create a timeline object to synchronise
    Correlation corel = [CorrelationFactory create:0 Correlation:0];
    tvPTSTimeline = [[CorrelatedClock alloc] initWithParentClock:wallclock
                                                        TickRate:90000
                                                     Correlation:&corel]; // timeline created but unavailable

    tvPTSTimelineSyncer = [TimelineSynchroniser TimelineSynchroniserWithTimeline:tvPTSTimeline
                                                                TimelineSelector:timelineSelector
                                                                         Content:contentId
                                                                             URL:tsEndpointURL];
    assert(tvPTSTimelineSyncer!=nil);

    tvPTSTimelineSyncer.delegate = self;

    [tvPTSTimeline addObserver:self context:TVTimelineContext];


    [tvPTSTimelineSyncer start];

}

```


#### Register for callbacks when the Synchronisation Timeline's availability changes

```objective-c

  [tvPTSTimeline addObserver:self context:TVTimelineContext];


```


## Run the example app
A demo app called [TimelineSyncDemoApp](TimelineSyncDemoApp/) is included with this framework. To run the demo, open the *TimelineSyncWorkSp.xcworkspace* workspace in XCode. Choose the TimelineSyncDemoApp target, build it and deploy the app on your iOS device or run it in the simulator.

The CSS-TS URL is hardcoded in `ViewController.m`. Change these addresses to fit your setup.

```objective-c
NSString *serverAddress     = @"192.168.0.13";
NSString *contentId         = @"dvb://233A.4084.0001";
NSString *timelineSelector  = @"urn:dvb:css:timeline:pts";
NSString *tsEndpointURL     = @"ws://192.168.0.13:7682";
```
Replace the URL with your own CSS-TS server instance URL

On the server side, if you need an example implementation of a CSS-TS server, then clone the following library:
[https://github.com/bbc/pydvbcss]. The `examples` folder has a server implementation: `TSServer.py`

```
$ python examples/TSServer.py
```
The server does not play any media, but instead serves an imaginary set of timelines including a PTS timeline (*“urn:dvb:css:timeline:pts”*).
This server serves at 127.0.0.1 on port 7681 and provides a CSS-TS service at the URL *ws://127.0.0.1:7681/ts*. It also provides a wall clock server bound to *0.0.0.0* on UDP port *6677*.



## Licence

**Author**: Rajiv Ramdhany

The TimelineSync iOS Framework is developed by BBC R&D and distributed under Licensed under the Apache License, [Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).

© Copyright 2016 BBC R&D. All Rights Reserved
