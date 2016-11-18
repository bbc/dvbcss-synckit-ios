# <small>dvbcss-synckit-ios</small><br/>CIIProtocolClient Framework

* **[How to use](#how-to-use)**
* **[Read the documentation](#read-the-documentation)**
* **[Run the example app](#run-the-example-app)**

A client component for the CSS-CII protocol specified in the DVB-CSS and HbbTV2.0 specifications . It is used by Companion Screen applications to create a setup a connection with an HbbTV device to receive content identifiers and other information such as
* as other DVB-CSS protocol sevice endpoints (CSS-WC, CSS-TS server endpoints)
* available timelines for synchronisation


### Dependencies
The CIIProtocolClient library requires the following dynamic libraries (iOS frameworks) (found in SyncKit):

1. [SyncKitConfiguration](../SyncKitConfiguration)
2. [SimpleLogger](../SimpleLogger)
3. [SocketRocket](../SocketRocket) - the SocketRocket web socket library
4. [SyncKitCollections](../SyncKitCollections)



## Read the documentation
The docs for the library can be read [here](CIIProtocolClient/docs/index.html).

## How to use

A Cocoa Pod version of this library is not currently available. To use this library, follow these steps

#### Add the framework and its dependencies to your project

1. *Add the required projects to your workspace*

  The easiest way to use the CIIProtocolClient framework is to include these Xcode projects to your XCode workspace.

  1. [SyncKitConfiguration](../SyncKitConfiguration)
  2. [SimpleLogger](../SimpleLogger)
  3. [SocketRocket](../SocketRocket) - the SocketRocket web socket library
  4. [SyncKitCollections](../SyncKitCollections)

  Then, after building these projects, go to your project's target window and *click on project in Project Navigator, then the project's target on right window in General tab*), add these frameworks in the *Linked Frameworks and libraries* section: *SyncKitConfiguration.framework, SimpleLogger.framework, SocketRocketiOS.framework, SyncKitCollections.framework, CIIProtocolClient.framework*.

2. *Add the dynamic libraries to your project*

  Or alternatively, clone the SyncKit repository, open the main workspace and build all the projects.

  Then, in your project's target window (*click on project in Project Navigator, then the project's target on right window in General tab*), add the framework files in the *Linked Frameworks and libraries* section: *SyncKitConfiguration.framework, SimpleLogger.framework, SocketRocketiOS.framework, SyncKitCollections.framework, CIIProtocolClient.framework*.
  If you have two XCode instances running you can drag and drop the framework files from their respective project in SyncKit to your own project.

3. *Use the Cocoa Pod version*

  Not available yet.

#### Import the header files

Once the library and its dependencies have been added to your project, import this header file in your source file:

```objective-c

  #import <CIIProtocolClient/CIIProtocolClient.h>

```
#### Create and configure a CIIProtocolClient object

When a TV is discovered using the DIALDeviceDiscovery component, the CSS-CII URL reported in the `HbbTV_InterDevSyncURL` property of a DIALDevice object.
Use this to initialise a protocol client i.e. a [CIIClient]() instance.

```objective-c
  NSString* const kHbbTV_InterDevSyncURL = @"ws://192.168.0.7:7681/cii";

  CIIClient cssCIIClient = [[CIIClient alloc] initWithCIIURL:kHbbTV_InterDevSyncURL];

  if (cssCIIClient)
      [cssCIIClient start];

```

#### Register for notifications about new CII received or CSS-CII WebSocket connection failure

```objective-c

// --- register for CIIProtocolClient notifications ---
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCIINotifications:) name:kCIIConnectionFailure object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCIINotifications:) name:kCIIDidChange object:nil];



```

#### Handle notifications about CII changes or connection failures

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

On the server side, if you need an example implementation of a CSS-CII server, then clone the following library:
[https://github.com/bbc/pydvbcss]. The `examples` folder has a server implementation: `CIIServer.py`

```
$ python examples/CIIServer.py
```

The server listens on 127.0.0.1 on port 7681 and accepts WebSocket connections to *ws://<ip>:<port>/cii*.



## Licence

The CIIProtocolClient iOS Framework is developed by BBC R&D and distributed under the Apache License, [Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).

© Copyright 2016 BBC R&D. All Rights Reserved
