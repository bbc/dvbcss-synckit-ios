# <small>dvbcss-synckit-ios</small><br/>DIALTVSelectionUIViews Framework

* **[Read the documentation](#read-the-documentation)**
[](---END EXCLUDE FROM DOC BUILD---)
* **[How to use](#how-to-use)**
[](---START EXCLUDE FROM DOC BUILD---)

This framework provides UI elements (Views) for presenting the discovered TVs and allowing the user to select one.

### Dependencies
This framework requires the following dynamic libraries (iOS frameworks) (found in SyncKit):

  * DIALDeviceDiscovery
  * SyncKitConfiguration
  * SyncKitCollections
  * SyncKitDelegate
  * SimpleLogger

[](---START EXCLUDE FROM DOC BUILD---)
## Read the documentation
The docs for this framework can be read [here](https://bbc.github.io/dvbcss-synckit-ios/latest/DIALTVSelectionUIViews/).
[](---END EXCLUDE FROM DOC BUILD---)



# How to use

#### 1. Add the framework and its dependencies to your project

A Cocoa Pod version of this library is not currently available. To use this library, you must add it and its dependencies to your project.

You will need the following projects from this repository:

  * [DIALTVSelectionUIViews](.)
  * [DIALDeviceDiscovery](../DIALDeviceDiscovery)
  * [SyncKitConfiguration](../SyncKitConfiguration)
  * [SyncKitCollections](../SyncKitCollections)
  * [SimpleLogger](../SimpleLogger)
  * [SyncKitDelegate](../SyncKitDelegate)

Either include them in your workspace and build them; or build them in this repository's [synckit.xcworkspace](../synckit.xcworkspace)

Then add them under *Linked Frameworks and libraries* in your project's target configuration:

  * DIALTVSelectionUIViews.framework
  * DIALDeviceDiscovery.framework
  * SyncKitConfiguration.framework
  * SyncKitCollections.framework
  * SimpleLogger.framework
  * SyncKitDelegate.framework

You must also *embed* the resource bundle `DIALTV_UI_ResourceBundle.bundle`.

If you have two XCode instances running you can drag and drop the framework files from their respective project in SyncKit to your own project.

#### 2. Import the header files

Import this header file into your source file:

```
#import <DIALTVSelectionUIViews/DIALTVSelectionUIViews.h>
```

#### Usage

Use the *Device Collection View Controller*, and pass it a *DIALServiceDiscovery* object when you initialise it.

The view controller automatically populates its list of devices from those provided by the discovery component and listens for updates, refreshing the list if needed.

When the user selects a device from the list a notification of type `kNewDIAL_HbbTV_ServiceSelected` is posted with `userInfo` dict containing the key `kNewDIAL_HbbTV_ServiceSelected` whose value is the selected DIAL device object.

If you use `SyncKitDelegate`, then a selection by the user will also cause the `currentDIALdevice` to be set on the delegate.



# Licence

This framework is developed by BBC R&D and distributed under the Apache License, [Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).

© Copyright 2016 BBC R&D. All Rights Reserved
