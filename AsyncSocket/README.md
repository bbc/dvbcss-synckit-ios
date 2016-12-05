# <small>dvbcss-synckit-ios</small><br/>ASyncSocket Framework

* **[Overview](#overview)**
[](---START EXCLUDE FROM DOC BUILD---)
* **[Read the documentation](#read-the-documentation)**
[](---END EXCLUDE FROM DOC BUILD---)
* **[Run the example app](#run-the-example-app)**

## Overview

**ASyncSocket** is a framework that contains a subset of the CocoaAsyncSocket library developed and maintained by Robbie Hanson: https://github.com/robbiehanson/CocoaAsyncSocket. Only the UDP socket class variant that uses GCD for dispatching packet handlers is retained.

In Robbie Hanson's words:
> **GCDAsyncUdpSocket** is a UDP/IP socket networking library built atop Grand Central Dispatch. Here are the key features available:
> 
> - Native objective-c, fully self-contained in one class.<br/>
>   _No need to muck around with low-level sockets. This class handles everything for you._
> 
> - Full delegate support.<br/>
>   _Errors, send completions, receive completions, and disconnections all result in a call to your delegate method._
> 
> - Queued non-blocking send and receive operations, with optional timeouts.<br/>
>   _You tell it what to send or receive, and it handles everything for you. Queueing, buffering, waiting and checking errno - all handled for you automatically._
> 
> - Support for IPv4 and IPv6.<br/>
>   _Automatically send/recv using IPv4 and/or IPv6. No more worrying about multiple sockets._
> 
> - Fully GCD based and Thread-Safe<br/>
>   _It runs entirely within its own GCD dispatch_queue, and is completely thread-safe. Further, the delegate methods are all invoked asynchronously onto a dispatch_queue of your choosing. This means parallel operation of your socket code, and your delegate/processing code._


[](---START EXCLUDE FROM DOC BUILD---)
#### Read the Documentation
Documentation about **GCDAsyncUdpSocket** can be found at the [original GitHub site](https://github.com/robbiehanson/CocoaAsyncSocket/blob/master/Source/GCD/Documentation.html).

The automatically generated docs for this framework can be read [here](http://bbc.github.io/dvbcss-synckit-ios/latest/AudioPlayerEngine/).
[](---END EXCLUDE FROM DOC BUILD---)


#### Run the example app

An example UDP echo application is provided in the [ASyncSocketDemo folder](AsyncSocketDemo).

Open the *ASyncSocketDemo* workspace in XCode and build the *UDPClientDemo* and *UDPEchoServer* projects.
