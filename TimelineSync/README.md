# <small>dvbcss-synckit-ios</small><br/>TimelineSync Framework

[](---START EXCLUDE FROM DOC BUILD---)
* **[Read the documentation](#read-the-documentation)**
[](---END EXCLUDE FROM DOC BUILD---)
* **[Overview](#overview)**
* **[How to use](#how-to-use)**
* **[Run the example app](#run-the-example-app)**

This framework provides client components for the CSS-TS protocol. A TV that implements 
[DVB CSS](https://www.dvb.org/standards/dvb_css) or 
[HbbTV 2](http://hbbtv.org/resource-library/#specifications) specifications
contains a server for this protocol.

It is used by Companion Screen applications to synchronise their local estimate of a timeline to an external source of time e.g. the timeline of a media stream played by a TV. Use the [TimelineSynchroniser](https://bbc.github.io/dvbcss-synckit-ios/latest/TimelineSync/Classes/TimelineSynchroniser.html) class to synchronise a [CorrelatedClock](https://bbc.github.io/dvbcss-synckit-ios/latest/ClockTimelines/Classes/CorrelatedClock.html) (that you provide) to the timeline position and speed reported by the TV.


#### Dependencies
The TimelineSync library requires the following dynamic libraries (iOS frameworks) (these are found in SyncKit):

  * [SyncKitConfiguration](../SyncKitConfiguration)
  * [SimpleLogger](../SimpleLogger)
  * [SocketRocket](../SocketRocket)
  * [SyncKitCollections](../SyncKitCollections)
  * [JSONModelFramework](../JSONModelFramework)
  * [ClockTimelines](../ClockTimelines)



[](---START EXCLUDE FROM DOC BUILD---)
## Read the documentation
The docs for this framework can be read [here](https://bbc.github.io/dvbcss-synckit-ios/latest/TimelineSync).
[](---END EXCLUDE FROM DOC BUILD---)



## Overview

This framework contains two main classes:

  * **[TimelineSynchroniser](https://bbc.github.io/dvbcss-synckit-ios/latest/TimelineSync/Classes/TimelineSynchroniser.html)** - Use this to synchronise a [CorrelatedClock](https://bbc.github.io/dvbcss-synckit-ios/latest/ClockTimelines/Classes/CorrelatedClock.html) to the *Synchronisation Timeline* reported by the TV.
  * **[TSClient](https://bbc.github.io/dvbcss-synckit-ios/latest/TimelineSync/Classes/TSClient.html)** - This implements a client for the protocol. It is used internally by the *TimelineSynchroniser*.

Given the URL for the CSS-TS endpoint and a [CorrelatedClock](https://bbc.github.io/dvbcss-synckit-ios/latest/ClockTimelines/Classes/CorrelatedClock.html) to represent the Synchronisation Timeline, the client will connect and receive Control Timestamps on a particular timeline. A TV broadcast stream may have many timelines signalled within it. In the setup phase of the protocol, the a *timeline selector* string is passed to the TV to specify the timeline to choose as the Synchronisation Timeline.

Before using the CSS-TS protocol, typically a companion application should:

1. **Connect to the CSS-CII server** in the same TV, using the [CIIProtocolClient](../CIIProtocolClient) to find out:
   * the current content ID
   * the endpoints for CSS-WC and CSS-TS
   * other state information about the TV
   
2. **Connect to CSS-WC endpoint** using the [WallClockSync](https://bbc.github.io/dvbcss-synckit-ios/latest/WallClockSync) framework to synchronise a *CorrelatedClock* to the TV Wall Clock time.

3. **Decide what timeline to request** from the TV. 
   The companion can either choose a timeline suggested by the TV via the CSS-CII protocol, or pick a different one that it knows is available anyway. 
   
4. **Create a *CorrelatedClock* to represent the Synchronisation timeline**, with its parent set to be the clock representing Wall Clock time.

5. Now the companion is ready to start using the *TimelineSynchroniser* to connect to the CSS-TS endpoint.

**TimelineSynchroniser** is the main class in this library. It will create a TSClient instance (a client of the CSS-TS protocol) and register for Control Timestamps delivery notifications. The TSClient class is responsible of setting up the connection to the CSS-TS server and receive protocol messages which contain a Control Timestamp.

The TimelineSynchroniser, on receiving a Control Timestamp, updates the Synchronisation Timeline CorrelatedClock object. On the first update, this clock's availability changes to true and observers notified about this change in status.



## How to use

#### 1. Add the framework and its dependencies to your project

A Cocoa Pod version of this library is not currently available. To use this library, you must add it and its dependencies to your project.

You will need the following projects from this repository:

  * [SyncKitConfiguration](../SyncKitConfiguration)
  * [SimpleLogger](../SimpleLogger)
  * [SocketRocket](../SocketRocket)
  * [SyncKitCollections](../SyncKitCollections)
  * [JSONModelFramework](../JSONModelFramework)
  * [ClockTimelines](../ClockTimelines)
  * [TimelineSync](.)

Either include them in your workspace and build them; or build them in this repository's [synckit.xcworkspace](../synckit.xcworkspace)

Then add them under *Linked Frameworks and libraries* in your project's target configuration:

  * SyncKitConfiguration.framework
  * SimpleLogger.framework
  * SocketRocketiOS.framework
  * SyncKitCollections.framework
  * JSONModelFramework.framework
  * ClockTimelines.framework
  * TimelineSync.framework*.

If you have two XCode instances running you can drag and drop the framework files from their respective project in SyncKit to your own project.


#### 2. Import the header files

Import this header file into your source file:


```objective-c

  #import <TimelineSync/TimelineSync.h>

```
#### Create and configure a TimelineSynchroniser object

Create and start a *TimelineSynchroniser* when the WallClock becomes available. Use iOS's Key-Value-Observation mechanism to observe
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

On the server side, if you need an example implementation of a CSS-TS server. A simple example one is available in [pydvbcss](https://github.com/bbc/pydvbcss) called `TSServer.py`:

```
$ git clone https://github.com/bbc/pydvbcss.git
$ cd pydvbcss
$ cd examples
$ python TSServer.py
```

The server does not play any media, but instead serves an imaginary set of timelines including a PTS timeline (*“urn:dvb:css:timeline:pts”*).

The server serves at 127.0.0.1 on port 7681 and provides a CSS-TS service at the URL *ws://127.0.0.1:7681/ts*. It also provides a wall clock server bound to *0.0.0.0* on UDP port *6677*.



## Licence

**Author**: Rajiv Ramdhany

This framework is developed by BBC R&D and distributed under Licensed under the Apache License, [Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).

© Copyright 2016 BBC R&D. All Rights Reserved
