These frameworks are used internally by *dvbcss-synckit-ios*. 

An application using *dvbcss-synckit-ios* frameworks is not expected to need to
directly use these frameworks, however they are documented here in case they are
helpful.

#### 3rd party frameworks

Some of these frameworks are 3rd party frameworks and for convenience are
included in the repository and Xcode workspace. 

See the documentation for each framework for details of the original authorship
and licence terms for that framework.



| Framework | Component | Description |
| --- | --- | --- |
| [AsyncSocket](AsyncSocket/) |  [GCDAsyncUdpSocket](AsyncSocket/Classes/GCDAsyncUdpSocket.html)   |  A UDP/IP socket networking framework built atop Grand Central Dispatch. |
| [UDPMessaging](UDPMessaging/) |  [UDPEndpoint](UDPMessaging/Classes/UDPEndpoint.html)   | A class representing a UDP socket endpoint (server- or client-mode)  |
| [SocketRocket](SocketRocket/) |  [SRWebSocket](SocketRocket/Classes/SRWebSocket.html)   |  Facebook's [SRWebSocket](https://github.com/facebook/SocketRocket) framework (available under a BSD-licence) re-packaged as an iOS framework |
| [JSONModelFramework](JSONModelFramework/) |  JSONModelFramework.h   |  Framework for serialising Objective C objects into JSON and deserialise JSON back to Objective C. A repackaging of the open-source [JSONModel](https://github.com/jsonmodel/jsonmodel) library as an iOS framework |

