# <small>dvbcss-synckit-ios</small><br/>WallClockClient Framework

* **[How to use](#how-to-use)**
* **[Read the documentation](#read-the-documentation)**
* **[Run the example app](#run-the-example-app)**

A Wall Clock time synchronisation component that uses the DVB-CSS WallClock synchronisation (CSS-WC) protocol. It is used by Companion Screen applications to synchronise their Wall Clock with a DVB-CSS/HbbTV2.0 TV/STB.

The **WallClockClient** iOS framework library includes a number of components that when connected together will exchange messages with a CSS-WC protocol server, process the messages and generate measurements for the offset between the Companion Screen application's local WallClock and a TV and the initial dispersion value for that measurement. These candidate measurements (called Candidates) are then filtered and submitted to an algorithm for processing.

The Candidate measurement filter is used to drop candidates that are unlikely to provide a good estimate of the TV's WallClock time. For example, measurements  collected with large round-trip times (RTT) can be discarded by an RTTThreshold filter.

The candidate-processing algorithm determines if a new candidate measurement offers a better estimate of the TV's Wall Clock time than a previously-seen candidate measurement. For example, the [LowestDispersion](WallClockClient/WallClockClient/LowestDispersionAlgorithm.h) algorithm is used to ensure that only the candidate measurement with the current lowest dispersion value is selected as the currently-known best estimate of the TV WallClock time.


To perform WallClock time synchronisation using this library, the following classes are used:

1. [WallClockSynchroniser](WallClockClient/WallClockClient/WallClockSynchroniser.h) - A [WallClockSynchroniser](WallClockClient/WallClockClient/WallClockSynchroniser.h) instance initialised with a CSS-WC server's host address and port number.
  This is a configurator object to assemble the various objects together and start/stop the WallClock sync.

2. [TunableClock](https://github.com/bbc/dvbcss-synckit-ios/blob/master/src/ClockTimelines/ClockTimelines/TunableClock.h) -  A local WallClock that will be updated by the offset, initial error and error growth rate. In this implementation, the same WallClock in used to timestamp WC protocol
   messages.
3. [WCProtocolClient](WallClockClient/WallClockClient/WCProtocolClient.h) - A CSS-WC protocol client to send CSS-WC requests and receive CSS-WC responses.
   On reception of WC response messages, the WCProtocolClient object creates a Candidate
     measurement object and submits it to a CandidateSink object for further proccesing.

4. [CandidateSink](WallClockClient/WallClockClient/CandidateSink.h) - A Candidate measurement handler object to send each new candidate through a chain of filters. If the candidate survives the filtration process, the CandidateSink object serves it to an algorithm for processing.

5. [LowestDispersionAlgorithm](WallClockClient/WallClockClient/LowestDispersionAlgorithm.h) - An algorithm object to process Candidates and readjust the local WallClock's offset. WC
   algorithms must conform to the IWCAlgo protocol. Other algorithms such as lowest RTT can be plugged in as long as they implement the IWCAlgo interface.

6. A list of filters e.g. [RTTThresholdFilter](WallClockClient/WallClockClient/RTTThresholdFilter.h) (IFilter protocol-conforming objects) to reject unsuitable Candidates e.g. a candidates with an RTT that exceeds a specified threshold.

### Dependencies
The WallClockClient library requires the following dynamic libraries (iOS frameworks) (found in SyncKit):

1. [SyncKitCollections](../SyncKitCollections)
2. [SimpleLogger](../SimpleLogger)
3. [UDPMessaging](../UDPMessaging)
4. [ClockTimelines](../ClockTimelines)



## Read the documentation
The docs for the library can be read [here](WallClockClient/docs/index.html).

## How to use

A Cocoa Pod version of this library is not currently available. To use this library,

#### Add the framework and its dependencies to your project

1. *Add the required projects to your workspace*

  The easiest way to use the WallClockClient framework is to include these Xcode projects to your XCode workspace.
  * WallClockClient
  * SyncKitCollections
  * SimpleLogger
  * UDPMessaging
  * ClockTimelines
  
  Then, after building these projects, go to your project's target window and *click on project in Project Navigator, then the project's target on right window in General tab*), add these frameworks in the *Linked Frameworks and libraries* section: *WallClockClient.framework, SyncKitCollections.framework, SimpleLogger.framework, UDPMessaging.framework, ClockTimelines.framework*.

2. *Add the dynamic libraries to your project*

  Or alternatively, clone the SyncKit repository, open the main workspace and build all the projects.
  
  Then, in your project's target window (*click on project in Project Navigator, then the project's target on right window in General tab*), add the framework files in the *Linked Frameworks and libraries* section: *DIALDeviceDiscovery.framework, SyncKitConfiguration.framework, SyncKitCollections.framework, SimpleLogger.framework, AsyncSocket.framework*.
  If you have two XCode instances running you can drag and drop the framework files from their respective project in SyncKit to your own project.

3. *Use the Cocoa Pod version*

  Not available yet.

#### Import the header files

Once the library and its dependencies have been added to your project, import this header file in your source file:

```objective-c

  #import <WallClockClient/WallClockClient.h>
  #import <ClockTimelines/ClockTimelines.h>

```
#### Create and configure a WallClock synchroniser object

Create a WallClock, candidate-processing algorithm and filter list and use this to initialise a WallClockSynchroniser instance:

```objective-c

  SystemClock             *sysCLK;            // a system clock based on this device monotonic time
  TunableClock            *wallclock;         // a WallClock whose time will be synchronised using the WC protocol
  id<IWCAlgo>             algorithm;          // an algorithm for processing candidate measurements
  id<IFilter>             filter;             // a filter to reject unsuitable candidate measurements
  NSMutableArray          *filterList;        // a filter list
  WallClockSynchroniser   *wallclock_syncer;  // a component that drives our time synchronisation


  sysCLK = [[SystemClock alloc] initWithTickRate:_kOneThousandMillion];

  //create a tunable clock with start ticks equal to system clock current ticks and same tick rate as the system clock.
  wallclock = [[TunableClock alloc] initWithParentClock:sysCLK TickRate:_kOneThousandMillion Ticks:0];

  algorithm = [[LowestDispersionAlgorithm alloc] initWithWallClock:wallclock];
  filter = [[RTTThresholdFilter alloc] initWithThreshold:1000];
  filterList = [NSMutableArray arrayWithObject:filter];

  wallclock_syncer = [[WallClockSynchroniser alloc] initWithWCServer:serverAddress
                                                                Port:6677 WallClock:wallclock
                                                           Algorithm:algorithm
                                                          FilterList:filterList];

```

#### Register for notifications of when the WallClock becomes `available` i.e. in a synchronised state

```objective-c

  [_wallclock addObserver:self forKeyPath:kAvailableKey options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:WallClockContext];


```

#### Start the WallClock synchroniser

```objective-c
// --- start WallClock Sync ----
[wallclock_syncer start];


```


## Run the example app
A demo app called [WallClockCientDemoApp](WallClockCientDemoApp/) is included with the library. To run the demo,open the WallClockSync workspace (*WallClockSync.xcworkspace* file) in XCode. Choose the WallClockCientDemoApp target, build it and deploy the app on your iOS device.

On the server side, if you need an example implementation of a CSS-WC server, then clone the following library:
[https://github.com/bbc/pydvbcss]. The `examples` folder has a server implementation: `WallClockServer.py`

Run this WallClock Synchronisation server specifying a network interface address and a port number as illustrated below:

```
$ python examples/WallClockServer.py 192.168.0.2 6677
```


## Licence

The WallClockClient Framework is developed by BBC R&D and distributed under Licensed under the Apache License, [Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).

© Copyright 2016 BBC R&D. All Rights Reserved
