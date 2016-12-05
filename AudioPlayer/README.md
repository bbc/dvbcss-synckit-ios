# <small>dvbcss-synckit-ios</small><br/>AudioPlayerEngine Framework


* **[Overview](#overview)**
[](---START EXCLUDE FROM DOC BUILD---)
* **[Read the documentation](#read-the-documentation)**
[](---END EXCLUDE FROM DOC BUILD---)
* **[How to use](#how-to-use)**
* **[Run the example apps](#run-the-example-apps)**

The AudioPlayerEngine iOS Framework is an extension of the [EZAudio Framework](https://github.com/syedhali/EZAudio) to provide audio players to play audio files and streams, with the possibility of producing visualisations of the audio data ( visualisation is currently supported only with audio files) . Three players are provided:

 * **AudioPlayer** - a player for audio files
 * **AudioPlayerViewController** -  a UIViewController which includes player for audio file playback and visualisation of the audio data in a provided UIView.
 * **AudioStreamPlayer** - a player for audio streams

The audio players have very similar interfaces and export similar properties. The library provides demo examples for each type of player.

A common protocol (interface) for the audio players will be specified in the near future.


## Overview
The AudioPlayerEngine's audio players support seeking in the audio stream. The audio-file players support audio-frame-accurate playhead position adjustment. The AudioStreamPlayer only supports seeking for on-demand internet audio-streams

### AudioPlayer

*[AudioPlayerEngine/AudioPlayer.h](AudioPlayerEngine/AudioPlayerEngine/AudioPlayer.h)*

This class is designed to play an audio file (e.g. mp3, wav, aifc, aiff, m4a, mp4, caf, aac files) to provide advanced playback adjustment operations and the possibility to add audio processing functionality in the audio filter graph.

To play audio files, the AudioPlayer internally uses the *EZAudioFile* and *EZOutput* objects from the [EZAudio Framework](https://github.com/syedhali/EZAudio). It creates an *EZAudioFile* instance to read audio data from the file. For playback of the audio data, it uses an *EZOutput* instance - this object makes use of AudioUnit to convert the audio data coming into a playback graph of audio processing units. When an *EZOutput* instance is created, it contains by default an output device at the end of the pipeline.

### AudioPlayerViewController

*[AudioPlayerEngine/AudioPlayerViewController.h](AudioPlayerEngine/AudioPlayerEngine/AudioPlayerViewController.h)*

This class represents a file-playing audio player similar to [AudioPlayer](#AUdioPlayer), but is a UIViewController that provides a visual waveform visualisation. Two types of visualisations are supported:
*  Rolling mirrored waveform
*  Buffered waveform

Internally, it uses an *EZAudioPlotGL* instance (a CoreGraphics-based audio plotting UIView
) to plot a waveform representation of the audio data in the buffer. 
Like the AudioPlayer, it uses an *EZAudioFile* instance to read audio data from the file and an *EZOutput* instance to send audio data in a pipeline of audio-processing elements. An empty *EZOutput* pipeline will have a playback device at the end.

### AudioStreamPlayer

*[AudioPlayerEngine/AudioStreamPlayer.h](AudioPlayerEngine/AudioPlayerEngine/AudioStreamPlayer.h)*

This class is similar to AudioPlayer](#AUdioPlayer) but play a stream from
a URL, instead of a file.

When initialised with an audio stream's URL, this class will use the Core Audio Framework *AudioFileStream* to load the stream and parse the frame headers/data for AudioFileStream properties such as [data format]() and audio data packets. A callback method is invoked by the audio file stream parser when it finds audio data in the audio file stream. This cause the audio data to be added to a buffer and then enqueued for playback in an [AudioQueue]().



[](---START EXCLUDE FROM DOC BUILD---)
## Read the documentation
The docs for this framework can be read [here](http://bbc.github.io/dvbcss-synckit-ios/latest/AudioPlayerEngine/).
[](---END EXCLUDE FROM DOC BUILD---)



## How to use

#### 1. Add the framework to your project

A Cocoa Pod version of this library is not currently available. To use this library, you must add it and its dependencies to your project.

Either include *AudioPlayerEngine* in your workspace and build it; or build it in this repository's [synckit.xcworkspace](../synckit.xcworkspace)

Then add *AudioPlayerEngine.framework* under *Linked Frameworks and libraries* in your project's target configuration.

#### 2. Import the header files

```objective-c
#import <AudioPlayerEngine/EZAudio.h>
```

#### 3. Create and commence playback

Create a player instance e.g. AudioPlayerViewController (it needs a UIView of type EZAudioPlot and a player delegate object for status callbacks):

```objective-c
#define kAudioFileDefault [[NSBundle mainBundle] pathForResource:@"simple-drum-beat" ofType:@"wav"]

audioPlayerVC = [[AudioPlayerViewController alloc] initWithAudioFilePath:kAudioFileDefault ParentView:self.audioPlot Delegate:self];

[audioPlayerVC.player play];
```

The audio player will load the audio file and start to play.



## Run the example apps
There are two demo apps included with the library:
* [AudioPlayerDemo](AudioPlayerDemo) - a demo app showing how to use this library's AudioPlayer/AudioPlayerViewController class
* [AudioStreamPlayerDemo](AudioStreamPlayerDemo) - a demo app that illustrates how an AudioStreamPlayer can be used to play an internet audio stream.


## Licence

The AudioPlayerEngine iOS Framework is developed by BBC R&D and distributed under the Apache License, [Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).

© Copyright 2016 BBC R&D. All Rights Reserved

The components of the EZAudio Framework used here were originally licensed under the MIT licence. See [LICENSE-EZAUDIO](AudioPlayerEngine/LICENSE-EZAUDIO).
