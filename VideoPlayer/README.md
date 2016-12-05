# <small>dvbcss-synckit-ios</small><br/>VideoPlayer Framework

[](---START EXCLUDE FROM DOC BUILD---)
* **[Read the documentation](#read-the-documentation)**
[](---END EXCLUDE FROM DOC BUILD---)
* **[Overview](#overview)**
* **[How to use](#how-to-use)**
* **[Run the example app](#run-the-example-app)**

This framework is designed to play a video file (e.g. an H264-encoded video) or HLS stream and to provide advanced playback adjustment operations. With the playback adaptation features it offers, it is possible to synchronise  video playback to an external timing source.


[](---START EXCLUDE FROM DOC BUILD---)
## Read the documentation
The docs for the library can be read [here](http://bbc.github.io/dvbcss-synckit-ios/latest/VideoPlayer/).
[](---END EXCLUDE FROM DOC BUILD---)



## Overview

The main class for the video player is the [VideoPlayerViewController](http://bbc.github.io/dvbcss-synckit-ios/latest/VideoPlayer/Classes/VideoPlayerViewController.html); it is a UIViewController that encapsulates an AVPlayer and embeds it within a supplied UIView instance. It utilises the AVPlayer object to play a video asset and allows playback to be adapted by skipping frames, changing the speed or changing the (media-timeline, host clock) relationship.

The **VideoPlayerViewController** object allows other components to monitor the progress of the video playback. As the video is loaded and the media-processing pipeline primed, it reports changes to particular video player properties (e.g. asset playable, tracks, duration, loaded time range, current media time) to interested observers via callbacks or notifications.

An object wishing to receive callbacks from the video player must implement the [VideoPlayerDelegate](http://bbc.github.io/dvbcss-synckit-ios/latest/VideoPlayer/Protocols/VideoPlayerDelegate.html) protocol and register itself as a delegate with the **VideoPlayerViewController** object.



## How to use


#### 1. Add the framework to your project

A Cocoa Pod version of this library is not currently available. To use this library, you must add it and its dependencies to your project.

Either include *VideoPlayer* in your workspace and build it; or build it in this repository's [synckit.xcworkspace](../synckit.xcworkspace)

Then add *VideoPlayer.framework* under *Linked Frameworks and libraries* in your project's target configuration.

#### 2. Import the header files

```
#import <VideoPlayer/VideoPlayerError.h>
#import <VideoPlayer/VideoPlayerView.h>
#import <VideoPlayer/VideoPlayerViewController.h>
```

#### Create a VideoPlayerViewController

Create a VideoPlayerViewController instance and set the video asset URL:

```
VideoPlayerViewController videoplayer =
   [[VideoPlayerViewController alloc] initWithParentView:self.VideoView
             Delegate:self];
     url = [NSURL
       URLWithString:@"https://devimages.apple.com.edgekey.net/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8"];

    self.videoPlayerController.videoURL = url;
```

The video player will load the video and start to play.


## Run the example app
A demo app called [TestVideoPlayer](TestVideoPlayer/) is included with the VideoPlayer library. In the VideoPlayer project, choose TestVideoPlayer as the build target and deploy to either a simulator or an iOS device.


## Licence

This framework is developed by BBC R&D and distributed under Licensed under the Apache License, [Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).

© Copyright 2016 BBC R&D. All Rights Reserved
