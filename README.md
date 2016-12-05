# SyncKit iOS Companion Screen DVB-CSS Synchronisation Library

**`dvbcss-synckit-ios` is a collection of iOS dynamic libraries ("Frameworks") for building media-based Companion screen applications that are synchronised frame-accurately to a TV.**

It provides iOS implementations of the client side of the [DVB CSS](https://www.dvb.org/standards/dvb_css) media-synchronisation protocols as used in [HbbTV 2](http://hbbtv.org/resource-library/#specifications) compliant connected TVs. It also includes useful building blocks such as native media players, device discovery components, loggers, WebSockets- and UDP- based messaging, JSON to Objective-C deserialisation etc.

* **[Getting Started](#getting-started)**
 * **[Clone the repository](#clone-the-repository)**
 * **[Run the example app](#run-the-example-app)**
 * **[Use SyncKit in your own project](#use-synckit-in-your-own-project)**
[](---START EXCLUDE FROM DOC BUILD---)
* **[Read the documentation](#read-the-documentation)**
[](---END EXCLUDE FROM DOC BUILD---)
* **[Overview of iOS Frameworks provided](#overview-of-ios-frameworks-provided)**
* **[Contact](#contact)**
* **[Licence](#licence)**

## Getting Started

When developing applications with the **SyncKit** framework, either use the lower-level components e.g. the DVB-CSS protocol clients or use the higher-level abstractions that the library provides e.g. timeline synchronisers, sync controllers and the Synchroniser singleton.

Requirements:
* XCode 7 or higher
* iOS 9.3 SDK or higher


### Clone the repository

The first step is to clone this repository, or use one of the release tarballs.

### Run the example app

The repository includes a demo iOS application that uses SyncKit to discover a TV on the network and synchronise to it when playing a video.

*This demo assumes that a DVB-CSS- or HbbTV 2 compliant TV/STB or emulator is being used to play a video stream. The application when deployed on an iOS device will then synchronise against that video stream.*

For details on how it works and how to run it, see [the SyncKitVideoSyncDemoApp README](SyncKitVideoSyncDemoApp/README.md).

**Make sure you add the required companion media files before trying to build and run it.**


### Use SyncKit in your own project

To use these frameworks in your own applications, you must build and import the frameworks into your project that you need.

Either include the project for each framework you need into your own project workspace and build it; or build in in this repository's [synckit.xcworkspace](synckit.xcworkspace).

Then add the frameworks you need under *Linked Frameworks and libraries* in your project's target configuration.

You can omit libraries you do not need. However, ensure that the dependencies of your libraries are always satisfied. The READMEs and [docs](https://bbc.github.io/dvbcss-synckit-ios/latest/) for each framework lists its dependencies.

*There is some [more detailed guidance on how to do this](how-to-import.md) if you need it.*


[](---START EXCLUDE FROM DOC BUILD---)
## Read the documentation

All documentation is [available online here](https://bbc.github.io/dvbcss-synckit-ios/latest/).

Each iOS framework in SyncKit has accompanying documentation and where applicable, example apps that demonstrate usage of the framework.
[](---END EXCLUDE FROM DOC BUILD---)


## Overview of iOS Frameworks provided

SyncKit contains a wide set of functionality divided into frameworks:

  * **Synchroniser** high level interface that automates the use of many of these other frameworks
  * **Media players** that can be synchronised.
  * **Device discovery** to automatically detect the TV on the home network.
  * **Clock objects** that can represent clocks and timelines progress.
  * **Protocol implementations** of the DVB CSS protocols for communicating with the TV:
    * *Content Identification*
    * *Wall Clock synchronisati on*
    * *TV Timeline synchronisation*
  * **SyncController** objects that control the media players to keep them in synckit
  * **other useful frameworks**
 
**For more detailed information, see the [Frameworks overview documentation](https://bbc.github.io/dvbcss-synckit-ios/latest/Frameworks.html).**
 
 
 

## Contact

The original author is Rajiv Ramdhany 'at' bbc.co.uk.


## Licence

The **dvbcss-synckit-ios**  iOS library is developed by BBC R&D and distributed under the Apache License, [Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).

© Copyright 2016 BBC R&D. All Rights Reserved
