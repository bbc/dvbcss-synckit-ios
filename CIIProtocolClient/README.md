# <small>dvbcss-synckit-ios</small><br/>CIIProtocolClient Framework

* **[Dependencies](#dependencies)**
[](---START EXCLUDE FROM DOC BUILD---)
* **[Read the documentation](#read-the-documentation)**
[](---END EXCLUDE FROM DOC BUILD---)
* **[How to use](#how-to-use)**
* **[Run the example app](#run-the-example-app)**

This framework provides a client component for the CSS-CII protocol. A TV that implements 
[DVB CSS](https://www.dvb.org/standards/dvb_css) or 
[HbbTV 2](http://hbbtv.org/resource-library/#specifications) specifications
contains a server for this protocol.

A companion screen application should connect to a TV using this protocol to receive
receive content identifiers and other information such as the URL of other
DVB-CSS protocol endpoints (for the CSS-WC and CSS-TS protocols)


#### Dependencies
The CIIProtocolClient library requires the following dynamic libraries (iOS frameworks) (found in SyncKit):

* [SyncKitConfiguration](../SyncKitConfiguration)
* [SimpleLogger](../SimpleLogger)
* [SocketRocket](../SocketRocket) - the SocketRocket web socket library
* [SyncKitCollections](../SyncKitCollections)



[](---START EXCLUDE FROM DOC BUILD---)
## Read the documentation
The docs for this framework can be read [here](https://bbc.github.io/dvbcss-synckit-ios/latest/CIIProtocolClient).
[](---END EXCLUDE FROM DOC BUILD---)



## How to use

#### 1. Add the framework and its dependencies to your project

A Cocoa Pod version of this library is not currently available. To use this library, you must add it and its dependencies to your project.

You will need the following projects from this repository:

  * [SyncKitConfiguration](../SyncKitConfiguration)
  * [SimpleLogger](../SimpleLogger)
  * [SocketRocket](../SocketRocket)
  * [SyncKitCollections](../SyncKitCollections)
  * [CIIProtocolClient](.)

Either include them in your workspace and build them; or build them in this repository's [synckit.xcworkspace](../synckit.xcworkspace)

Then add them under *Linked Frameworks and libraries* in your project's target configuration:

  * SyncKitConfiguration.framework
  * SimpleLogger.framework
  * SocketRocketiOS.framework
  * SyncKitCollections.framework
  * CIIProtocolClient.framework

If you have two XCode instances running you can drag and drop the framework files from their respective project in SyncKit to your own project.

#### 2. Import the header files

Import this header file in your source file:

```objective-c

  #import <CIIProtocolClient/CIIProtocolClient.h>

```
#### 3. Create and configure a CIIProtocolClient object

When a TV is discovered using the DIALDeviceDiscovery component, the CSS-CII URL reported in the `HbbTV_InterDevSyncURL` property of a DIALDevice object.
Use this to initialise a protocol client i.e. a [CIIClient]() instance.

```objective-c
  NSString* const kHbbTV_InterDevSyncURL = @"ws://192.168.0.7:7681/cii";

  CIIClient cssCIIClient = [[CIIClient alloc] initWithCIIURL:kHbbTV_InterDevSyncURL];

  if (cssCIIClient)
      [cssCIIClient start];

```

#### 4. Register for notifications about new CII received or CSS-CII WebSocket connection failure

```objective-c

// --- register for CIIProtocolClient notifications ---
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCIINotifications:) name:kCIIConnectionFailure object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCIINotifications:) name:kCIIDidChange object:nil];



```

#### 5. Handle notifications about CII changes or connection failures

A change in a received CII is indicated by the appropriate bit being set in a bitmask.  To determine
which fields have changed in a new CII object, use the CIIChangeStatus bitmask in the notification handler routine.

```objective-c
- (void) handleCIINotifications:(NSNotification*) notification
{
    NSUInteger ciiChangeStatus=0;

    // --- 2. Handle new CII and start WallClock synchronisation ----

    if  ([[notification name] caseInsensitiveCompare:kCIIDidChange] == 0) {

        id temp = [[notification userInfo] objectForKey:kCIIDidChange];

        NSNumber *status = [[notification userInfo] objectForKey:kCIIChangeStatusMask];

        if (status) {
            ciiChangeStatus = [status unsignedIntegerValue];
        }


        if ((ciiChangeStatus & NewCIIReceived) !=0)
        {
            NSLog(@"CSSynchroniser: Received New CII notification ... ");


            if ([temp isKindOfClass:[CII class]])
            {
                currentCII = temp;
            }
        }

        if (ciiChangeStatus  & ContentIdChanged) {

            if ([temp isKindOfClass:[CII class]])
            {
                currentCII = temp;
            }
            // TODO: Handle ContentId change

            // content Id has changed.

            // ...

        }
    }

```


## Run the example app
A demo app called [CIIProtocolClientDemoApp](CIIProtocolClientDemoApp/) is included with this framework. To run the demo,open the CIIProtocolClient project in XCode. Choose the CIIProtocolClientDemoApp target, build it and deploy the app on your iOS device or run it in the simulator.

The CSS-CII URL is hardcoded in `ViewController.m`:

```objective-c
NSString* const kHbbTV_InterDevSyncURL = @"ws://192.168.0.7:7681/cii";
```
Replace the URL with your own CII server instance URL

If you don't have a suitable TV, you can use the CSS-CII example server in [pydvbcss](https://github.com/bbc/pydvbcss):

```
$ git clone https://github.com/bbc/pydvbcss.git
$ cd examples
$ python CIIServer.py
```

The server listens on 127.0.0.1 on port 7681 and accepts WebSocket connections to *ws://ip-address:port-number/cii*.



## Licence

The CIIProtocolClient iOS Framework is developed by BBC R&D and distributed under the Apache License, [Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).

© Copyright 2016 BBC R&D. All Rights Reserved
