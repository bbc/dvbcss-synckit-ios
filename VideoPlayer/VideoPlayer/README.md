# Video Player

* **[How to use](#how-to-use)**
* **[Read the documentation](#read-the-documentation)**
* **[Run the example app](#run-the-example-app)**

The VideoPlayer is designed to play a video file (e.g. an H264-encoded video) or HLS stream and to provide advanced playback adjustment operations. With the playback adaptation features it offers, it is possible to synchronise  video playback to an external timing source.

The main class for the video player is the [VideoPlayerViewController](Classes/VideoPlayerViewController.html); it is a UIViewController that encapsulates an AVPlayer and embeds it within a supplied UIView instance. It utilises the AVPlayer object to play a video asset and allows playback to be adapted by skipping frames, changing the speed or changing the (media-timeline, host clock) relationship.

The **VideoPlayerViewController** object allows other components to monitor the progress of the video playback. As the video is loaded and the media-processing pipeline primed, it reports changes to particular video player properties (e.g. asset playable, tracks, duration, loaded time range, current media time) to interested observers via callbacks or notifications.

An object wishing to receive callbacks from the video player must implement the [VideoPlayerDelegate](Protocols/VideoPlayerDelegate.html) protocol and register itself as a delegate with the **VideoPlayerViewController** object.

## Read the documentation
The docs for the library can be read [here](index.html).

## How to use
* Download the project and build it in Xcode. Add the VideoPlayer.framework library file (found in the build folder) to your own project.
* Import the header files:

```
#import <VideoPlayer/VideoPlayerError.h>
#import <VideoPlayer/VideoPlayerView.h>
#import <VideoPlayer/VideoPlayerViewController.h>
```

* Create a VideoPlayerViewController instance and set the video asset URL:

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
A demo app called [TestVideoPlayer](../../TestVideoPlayer) is included with the VideoPlayer library. In the VideoPlayer project, choose TestVideoPlayer as the build target and deploy to either a simulator or an iOS device.


## Licence

The VideoPlayer Framework is developed by BBC R&D and distributed under Licensed under the Apache License, [Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).

© Copyright 2016 BBC R&D. All Rights Reserved
