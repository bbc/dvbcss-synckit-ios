# <small>dvbcss-synckit-ios</small><br/>AudioPlayerEngine Framework

* **[How to use](#how-to-use)**
* **[Read the documentation](#read-the-documentation)**
* **[Run the example apps](#run-the-example-apps)**

The AudioPlayerEngine iOS Framework is an extension of the [EZAudio Framework](https://github.com/syedhali/EZAudio) to provide audio players to play audio files and streams, with the possibility of producing visualisations of the audio data ( visualisation is currently supported only with audio files) . Three players are provided:

1. [AudioPlayer](AudioPlayerEngine/AudioPlayerEngine/AudioPlayer.h) - a player for audio files
2. [AudioPlayerViewController](AudioPlayerEngine/AudioPlayerEngine/AudioPlayerViewController.h) -  a UIViewController which includes player for audio file playback and visualisation of the audio data in a provided UIView.
3. [AudioStreamPlayer](AudioPlayerEngine/AudioPlayerEngine/AudioStreamPlayer.h) - a player for audio streams

The audio players have very similar interfaces and export similar properties. The library provides demo examples for each type of player.

A common protocol (interface) for the audio players will be specified in the near future.


## Audio Players
The AudioPlayerEngine's audio players support seeking in the audio stream. The audio-file players support audio-frame-accurate playhead position adjustment. The AudioStreamPlayer only supports seeking for on-demand internet audio-streams

### AudioPlayer

The [AudioPlayer](AudioPlayerEngine/AudioPlayerEngine/AudioPlayer.h) class is designed to play an audio file (e.g. mp3, wav, aifc, aiff, m4a, mp4, caf, aac files) to provide advanced playback adjustment operations and the possibility to add audio processing functionality in the audio filter graph. To play audio files, the AudioPlayer uses the **EZAudioFile** and **EZOutput** objects from the [EZAudio Framework](https://github.com/syedhali/EZAudio). It creates an EZAudioFile instance to read audio data from the file. For playback of the audio data, it uses an EZOutput instance - this object makes use of AudioUnit to convert the audio data coming into a playback graph of audio processing units. When an EZOutput instance is created, it contains by default an output device at the end of the pipeline.

### AudioPlayerViewController

The AudioPlayerViewController class represents a file-playing audio player similar to [AudioPlayer](#AUdioPlayer). It uses an EZAudioPlotGL instance (a CoreGraphics-based audio plotting UIView
) to plot a waveform representation of the audio data in the buffer. Two types of visualisations are supported:
*  Rolling mirrored waveform
*  Buffered waveform

Like the AudioPlayer, it uses an EZAudioFile instance to read audio data from the file and an EZOutput instance to send audio data in a pipeline of audio-processing elements. An empty EZOutput pipeline will have a playback device at the end.

### AudioStreamPlayer
An [AudioStreamPlayer](AudioPlayerEngine/AudioPlayerEngine/AudioStreamPlayer.h) when initialised with an audio stream's URL will use the Core Audio Framework [AudioFileStream] () to load the stream and parse the frame headers/data for AudioFileStream properties such as [data format]() and audio data packets. A callback method is invoked by the audio file stream parser when it finds audio data in the audio file stream. This cause the audio data to be added to a buffer and then enqueued for playback in an [AudioQueue]().

## How to use
A CocoaPod version of this project is not currently available. To use this framework library, you will need to

1. Download the project and build it in Xcode.
2. Add the AudioPlayerEngine.framework dynamic library (found in the build folder) to your own project.
3. Import the header files:

```objective-c
#import <AudioPlayerEngine/EZAudio.h>
```

4. Create a player instance e.g. AudioPlayerViewController (it needs a UIView of type EZAudioPlot and a player delegate object for status callbacks):

```objective-c
#define kAudioFileDefault [[NSBundle mainBundle] pathForResource:@"simple-drum-beat" ofType:@"wav"]

audioPlayerVC = [[AudioPlayerViewController alloc] initWithAudioFilePath:kAudioFileDefault ParentView:self.audioPlot Delegate:self];

[audioPlayerVC.player play];


```

The audio player will load the audio file and start to play.


## Read the documentation
The docs for the library can be read [here](AudioPlayerEngine/docs/index.html).



## Run the example apps
There are two demo apps included with the library:
* [AudioPlayerDemo](/AudioPlayerDemo) - a demo app showing how to use this library's AudioPlayer/AudioPlayerViewController class
* [AudioStreamPlayerDemo](/AudioStreamPlayerDemo) - a demo app that illustrates how an AudioStreamPlayer can be used to play an internet audio stream.


## Licence

The AudioPlayerEngine iOS Framework is developed by BBC R&D and distributed under the Apache License, [Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).

© Copyright 2016 BBC R&D. All Rights Reserved
