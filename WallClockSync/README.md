# <small>dvbcss-synckit-ios</small><br/>WallClockClient Framework

[](---START EXCLUDE FROM DOC BUILD---)
* **[Read the documentation](#read-the-documentation)**
[](---END EXCLUDE FROM DOC BUILD---)
* **[Overview](#overview)**
* **[How to use](#how-to-use)**
* **[Run the example app](#run-the-example-app)**

This framework provides a client component that uses the DVB-CSS WallClock synchronisation (CSS-WC) protocol. It is used by Companion Screen applications to synchronise their Wall Clock with a TV that implements 
[DVB CSS](https://www.dvb.org/standards/dvb_css) or 
[HbbTV 2](http://hbbtv.org/resource-library/#specifications) specifications.

Use a **WallClockSynchroniser** to control a **TunableClock** object so that it represents an estimate of the TV's Wall Clock time. The tick rate of this clock must be 1,000,000,000.


#### Dependencies
This framework requires the following dynamic libraries (iOS frameworks) (found in SyncKit):

  * [SyncKitCollections](../SyncKitCollections)
  * [SimpleLogger](../SimpleLogger)
  * [UDPMessaging](../UDPMessaging)
  * [ClockTimelines](../ClockTimelines)



[](---START EXCLUDE FROM DOC BUILD---)
## Read the documentation
The docs for this framework can be read [here](http://bbc.github.io/dvbcss-synckit-ios/latest/WallClockSync/).
[](---END EXCLUDE FROM DOC BUILD---)



## Overview

This framework library includes a number of components that, when connected together, will exchange messages with a CSS-WC protocol server, process the messages and generate measurements for the offset between the Companion Screen application's local WallClock and a TV and the initial dispersion value for that measurement. These candidate measurements (called Candidates) are then filtered and submitted to an algorithm for processing.

To perform WallClock time synchronisation, typically a companion application should:

1. **Connect to the CSS-CII server** in the same TV, using the [CIIProtocolClient](../CIIProtocolClient) to find out:
   * the current content ID
   * the endpoints for CSS-WC and CSS-TS
   * other state information about the TV
   
2. **Create a *TunableClock* to represent the wall clock**, with tick rate 1,000,000,000.

3. **Create a WallClockSynchroniser**, telling it the URL of the endpoint for CSS-WC server in the TV, and providing the clock object.

You can optionally choose to specify candidate measurement filters and processing algorithms:

  * The Candidate measurement filter is used to drop candidates that are unlikely to provide a good estimate of the TV's WallClock time. For example, measurements  collected with large round-trip times (RTT) can be discarded by an RTTThreshold filter.

  * The candidate-processing algorithm determines if a new candidate measurement offers a better estimate of the TV's Wall Clock time than a previously-seen candidate measurement. For example, the [LowestDispersion](WallClockClient/WallClockClient/LowestDispersionAlgorithm.h) algorithm is used to ensure that only the candidate measurement with the current lowest dispersion value is selected as the currently-known best estimate of the TV WallClock time.

Internally the WallClockSynchroniser instantiates other components in this framework:

 * *WCProtocolClient* - A CSS-WC protocol client to send CSS-WC requests and receive CSS-WC responses. On reception of WC response messages, the *WCProtocolClient* object creates a *Candidate* measurement object and submits it to a *CandidateSink* object for further proccesing.

 * *CandidateSink* - A *Candidate* measurement handler object to send each new candidate through a chain of filters. If the candidate survives the filtration process, the *CandidateSink* object serves it to an algorithm for processing.

 * *Algorithms (IWCAlgo protocol)* - e.g. *LowestDispersionAlgorithm* - An algorithm object to process Candidates and readjust the local WallClock's offset. WC algorithms must conform to the *IWCAlgo* protocol. Other algorithms can be developed and plugged in so long as they conform to the protocol.

6. *Filters (IFilter protocol)* - e.g. *RTTThresholdFilter* - A filter that rejects unsuitable Candidates e.g. a candidates with an RTT that exceeds a specified threshold. Filters must conform to the *IFilter* protocol. Other filters can be developed and plugged in so long as they conform to the protocol.



## How to use

#### 1. Add the framework and its dependencies to your project

A Cocoa Pod version of this library is not currently available. To use this library, you must add it and its dependencies to your project.

You will need the following projects from this repository:

  * [SyncKitCollections](../SyncKitCollections)
  * [SimpleLogger](../SimpleLogger)
  * [UDPMessaging](../UDPMessaging)
  * [ClockTimelines](../ClockTimelines)

Either include them in your workspace and build them; or build them in this repository's [synckit.xcworkspace](../synckit.xcworkspace)

Then add them under *Linked Frameworks and libraries* in your project's target configuration:

  * SyncKitCollections.framework
  * SimpleLogger.framework
  * UDPMessaging.framework
  * ClockTimelines.framework

If you have two XCode instances running you can drag and drop the framework files from their respective project in SyncKit to your own project.


#### Import the header files

Import this header file into your source file:

```objective-c
#import <WallClockClient/WallClockClient.h>
#import <ClockTimelines/ClockTimelines.h>
```

#### Create and configure a WallClock synchroniser object

Create a clock object to represent the wall clock, with a system clock as its parent:

```objective-c
SystemClock *sysCLK; 
TunableClock *wallclock;

sysCLK = [[SystemClock alloc] initWithTickRate:_kOneThousandMillion];

// create a tunable clock with tick rate of 1,000,000,000
// (matching the tick rate used for the Wall Clock protocol)

wallclock = [[TunableClock alloc] initWithParentClock:sysCLK TickRate:_kOneThousandMillion Ticks:0];
```

Using the defaults for candidate-processing algorithm (lowest dispersion) and filtering (RTT threshold), initialise a WallClockSynchroniser instance:

```objective-c
WallClockSynchroniser   *wallclock_syncer; 

wallclock_syncer = [[WallClockSynchroniser alloc] initWithWCServer:serverAddress
                                                Port:6677 WallClock:wallclock];
```
#### Register for notifications

Register to be notified when the WallClock becomes `available` i.e. in a synchronised state

```objective-c
[wallclock addObserver:self forKeyPath:kAvailableKey options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:WallClockContext];
```

#### Start the WallClock synchroniser

```objective-c
[wallclock_syncer start];
```


## Run the example app

A demo app called [WallClockCientDemoApp](WallClockCientDemoApp/) is included with the library. To run the demo,open the WallClockSync workspace (*WallClockSync.xcworkspace* file) in XCode. Choose the WallClockCientDemoApp target, build it and deploy the app on your iOS device.

On the server side, if you need an example implementation of a CSS-WC server. An example one is available in [https://github.com/bbc/pydvbcss]. In that repository, the `examples` folder has a server implementation: `WallClockServer.py`

Run this WallClock Synchronisation server specifying a network interface address and a port number as illustrated below:

```
$ python examples/WallClockServer.py 192.168.0.2 6677
```


## Licence

The WallClockClient Framework is developed by BBC R&D and distributed under Licensed under the Apache License, [Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).

© Copyright 2016 BBC R&D. All Rights Reserved
