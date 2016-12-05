# <small>dvbcss-synckit-ios</small><br/>UDPMessaging Framework

* **[How to use](#how-to-use)**
[](---START EXCLUDE FROM DOC BUILD---)
* **[Read the documentation](#read-the-documentation)**
[](---END EXCLUDE FROM DOC BUILD---)
* **[Run the example app](#run-the-example-app)**

This framework allows UDP endpoints to be created by a component/protocol requiring asynchronous communication. IPv4/IPv6 are both supported.

A [UDPEndpoint](https://bbc.github.io/dvbcss-synckit-ios/latest/UDPMessaging/Classes/UDPEndpoint.html) object enables a UDP server to be started by binding
 the underlying socket to a specified port and provides a method to be scheduled for
 checking for incoming packets. In client mode, a socket is created to target a remote
 address and port. Data packets can then be sent to the remote UDP endpoint by calling
 `-sendData:`.


[](---START EXCLUDE FROM DOC BUILD---)
## Read the documentation
The docs for this framework can be read [here](https://bbc.github.io/dvbcss-synckit-ios/latest/UDPMessaging/).
[](---END EXCLUDE FROM DOC BUILD---)


## How to use

#### 1. Add the framework to your project

A Cocoa Pod version of this library is not currently available. To use this library, you must add it and its dependencies to your project.

Either include *UDPMessaging* in your workspace and build it; or build it in this repository's [synckit.xcworkspace](../synckit.xcworkspace)

Then add *UDPMessaging.framework* under *Linked Frameworks and libraries* in your project's target configuration.


#### 2. Import the header files

```
#import <UDPMessaging/UDPMessaging.h>

```

To use a UDPEndpoint in server mode, make your class implement the UDPCommsDelegate protocol and then create a UDPEndpoint as follows:

```
    int port= 5567;
    UDPEndpoint udpcomms = [[UDPEndpoint alloc] init];
    assert(udpcomms != nil);

    udpcomms.delegate = self;

    [udpcomms startServerOnPort:port];
```

To use a UDPEndpoint in client mode:

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

A demo client-server app [UDPMessagingDemo](UDPMessagingDemo/) is included. To run the demo:

1. Open the [UDPMessagingDemo workspace](UDPMessagingDemo.xcworkspace) in XCode.

2. Build and run the *UDPMessagingServerDemo* project to generate the UDPMessagingServerDemo OSX executable.
    
    Start the server listening to, for example, port 5566:
    
    ```
    $ UDPMessagingServerDemo -l 5566
    ```

3. Build and run the *UDPMessagingClientDemo* iOS project and deploy on your iOS device. Make sure your OS X machine and your iOS device are both on the same network.

    Enter the server address and port number as:

    ```
    <servername>:5566
    ```

## Licence

This framework is developed by BBC R&D and distributed under Licensed under the Apache License, [Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).

© Copyright 2016 BBC R&D. All Rights Reserved
