# UDPMessaging Library

* **[How to use](#how-to-use)**
* **[Read the documentation](#read-the-documentation)**
* **[Run the example app](#run-the-example-app)**

The UDPMessaging library allows UDP endpoints to be created by a component/protocol requiring asynchronous communication. IPv4/IPv6 are both supported. A UDPEndpoint object enables a UDP server to be started by binding
 the underlying socket to a specified port and provides a method to be scheduled for
 checking for incoming packets. In client mode, a socket is created to target a remote
 address and port. Data packets can then be sent to the remote UDP endpoint by calling
 -sendData:.

## Read the documentation
The docs for the library can be read [here](index.html).

## How to use
* Download the project and build it in Xcode. Add the UDPMessaging.framework library file (found in the build folder) to your own project.
* Import the header files:

```
#import <UDPMessaging/UDPMessaging.h>

```

* To use a UDPEndpoint in server mode, make your class implement the UDPCommsDelegate protocol and then create a UDPEndpoint as follows:

```
    int port= 5567;
    UDPEndpoint udpcomms = [[UDPEndpoint alloc] init];
    assert(udpcomms != nil);

    udpcomms.delegate = self;

    [udpcomms startServerOnPort:port];
```

* To use a UDPEndpoint in client mode,

```
- (BOOL)runClientWithHost:(NSString *)host port:(NSUInteger)port
{
    assert(host != nil);
    assert( (port > 0) && (port < 65536) );

    assert(self.udpcomms == nil);

    self.udpcomms = [[UDPEndpoint alloc] initWithBufferSize:65536];
    assert(self.udpcomms != nil);

    self.udpcomms.delegate = self;

    [self.udpcomms startConnectedToHostName:host port:port];

    while (self.udpcomms != nil) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    // The loop above is supposed to run forever.  If it doesn't, something must
    // have failed and we want main to return EXIT_FAILURE.

    return NO;
}

```

## Run the example app
A demo client-server app called [UDPMessagingDemo](UDPMessagingDemo/) is included with the UDPMessaging library. To run the demo,open the UDPMessagingDemo workspace (UDPMessagingDemo.xcworkspace) in XCode. Build the UDPMessagingServerDemo project to generate the UDPMessagingServerDemo OSX executable.
```
>UDPMessagingServerDemo -l 5566
```  

Build the UDPMessagingClientDemo iOS project and deploy on your iOS device. Make sure your OS X machine and your iOS device are both on the same network. Enter the server address as:
```
<servername>:5566
```

## Licence

The UDPMessaging Framework is developed by BBC R&D and distributed under Licensed under the Apache License, [Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).

© Copyright 2016 BBC R&D. All Rights Reserved
