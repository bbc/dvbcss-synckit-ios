These are the frameworks in dvbcss-synckit-ios providing the various functions
needed to build synchronised companion applications.


## Overview of iOS Frameworks provided

* [Clocks and Media Timelines](#clocks-and-media-timelines)
* [WallClock Synchronisation](#wallclock-synchronisation)
* [Content Identification](#content-identification)
* [Timeline Synchronisation](#timeline-synchronisation)
* [SyncController Objects](#synccontroller-objects)
* [MediaSynchroniser](#mediasynchroniser)
* [UI components](#ui-components)
* [Logging, Configuration and other utilities](#logging-configuration-and-other-utilities)


### Media Players

`AudioPlayerEngine.framework`<br/>
`VideoPlayer.framework`

These are file/stream -based media players with enhanced playback control capability. They provide the capability to adapt the way the media is being played:
* change playback position,
* change the playback speed
* query the buffered time range
* adjust the playback by an offset
* change the alignment of video and audio tracks for a video stream

The following media players are included within **dvbcss-synckit-ios**.

| Framework | Component | Description |
| --- | --- | --- |
| [AudioPlayerEngine](AudioPlayerEngine/) |  [AudioPlayer](AudioPlayerEngine/Classes/AudioPlayer.html)  | A Core Audio SDK based player for audio files (e.g. mp3, wav, aifc, aiff, m4a, mp4, caf, aac files) and audio processing via units in an audio filter graph.  |
| [AudioPlayerEngine](AudioPlayerEngine/) |  [AudioStreamPlayer](AudioPlayerEngine/Classes/AudioStreamPlayer.html)   | A Core Audio SDK based player for audio streams. It uses Apple's Audio Queue Services and AudioFileStream to handle audio buffers and audio streaming  |
| [AudioPlayerEngine](AudioPlayerEngine/) |  [AudioPlayerViewController](AudioPlayerEngine/Classes/AudioPlayerViewController.html)  | a UIViewController that uses a CoreGraphics-based audio plotting UIView to show a waveform representation of the audio data in the buffer for an AudioPlayer |
| [VideoPlayer](VideoPlayer/) |  [VideoPlayerViewController](VideoPlayer/Classes/VideoPlayerViewController.html)  | A player for video files (e.g. MP4, QuickTime) and adaptive HTTP-based streams (e.g. HLS) |

Each player uses the delegate pattern to report progress information about the media playback. Callbacks will report about:
* player's state (initialised, paused, playing, ready to play, seeking)
* current playback time (periodically called)
* end of asset reached
* media properties such as media format, duration, available tracks
* buffered media time ranges

### Device Discovery

`DIALDeviceDiscovery.framework`

The **DIALDeviceDiscovery** framework provides APIs for the discovery of services via SSDP and the discovery of devices via DIAL. It allows HbbTV terminals existing on the same network to be discovered by the Companion Screen Application.
Using the DIAL protocol, the Companion Screen Application can launch an HbbTV application on the television.

| Framework | Component | Description |
| --- | --- | --- |
| [DIALDeviceDiscovery](DIALDeviceDiscovery/) |  [SSDPServiceDiscovery](DIALDeviceDiscovery/Classes/SSDPServiceDiscovery.html)   | Discovery of UPnP devices advertising a type of service type  |
| [DIALDeviceDiscovery](DIALDeviceDiscovery/) |  [DIALServiceDiscovery](DIALDeviceDiscovery/Classes/DIALServiceDiscovery.html)   | Discovery of devices on the network running a DIAL server and web applications such an HbbTV  |

### Clocks and Media Timelines

`ClockTimelines.framework`

The **ClockTimelines** framework provides software clock classes to represent timelines (of clocks and media assets). A timeline is represented by a clock object. Clock objects also allow relationships between timelines to be expressed using parent-child mapping relationships.

These clock objects work in the same way as the ones in the [pydvbcss](https://github.com/bbc/pydvbcss) python library (documented [here](http://pydvbcss.readthedocs.io/en/latest/clock.html)).

| Framework | Component | Description |
| --- | --- | --- |
| [ClockTimelines](ClockTimelines/) |  [SystemClock](ClockTimelines/Classes/SystemClock.html)   | A root clock class that is based on monotonic time as the underlying time source  |
| [ClockTimelines](ClockTimelines/) |  [CorrelatedClock](ClockTimelines/Classes/CorrelatedClock.html)   | A clock represent a timeline's relationship with a parent timeline as a correlation  |
| [ClockTimelines](ClockTimelines/) |  [TunableClock](ClockTimelines/Classes/TunableClock.html)   | A clock for a timeline with a correlation mapping to a parent clock, but with  adjustible tick offset and speed. |  


### WallClock Synchronisation

`WallClockClient.framework`

The WallClockClient framework provides an API to synchronise a WallClock with another device (e.g. an HbbTV) using the DVB-CSS WallClock Synchronisation protocol (CSS-WC). It uses UDP as the transport for CSS-WC messages. The framework allows different filters to be plugged in to exclude time offset measurements. Also, different algorithms can be plugged in to
to process the measurements and update the WallClock.

| Framework | Component | Description |
| --- | --- | --- |
| [WallClockClient](WallClockClient/) |  [WallClockSynchroniser](WallClockClient/Classes/WallClockSynchroniser.html)   | WallClock synchroniser using RTT Threshold filter and Lowest Dispersion algorithm |
| [WallClockClient](WallClockClient/) |  [WCProtocolClient](WallClockClient/Classes/WCProtocolClient.html)   | A CSS-WC protocol client  |
| [WallClockClient](WallClockClient/) |  [LowestDispersionAlgorithm](WallClockClient/Classes/LowestDispersionAlgorithm.html)   | Measurement-processing algo based on lowest dispersion for best-candidate selection  |
| [WallClockClient](WallClockClient/) |  [LowestDispersionFilter](WallClockClient/Classes/LowestDispersionFilter.html),  [RTTThresholdFilter](WallClockClient/Classes/RTTThresholdFilter.html) | Candidate measurement filters  |

### Content Identification

`CIIProtocolClient.framework`

The CIIProtocolClient framework allows a Companion Screen Application to receive updates about the current TV content's identifier and other service endpoints (e.g.  timeline synchronisation, material resolution (MRS), etc.). Also reported are timelines made available by the TV for synchronisation. Uses WebSockets for CSS-CII protocol.

| Framework | Component | Description |
| --- | --- | --- |
| [CIIProtocolClient](CIIProtocolClient/) |  [CIIClient](CIIProtocolClient/Classes/CIIClient.html)   | A CSS-CII protocol client |
| [CIIProtocolClient](CIIProtocolClient/) |  [TimelineOption](CIIProtocolClient/Classes/TimelineOption.html)   | A timeline description object. |

### Timeline Synchronisation

`TimelineSync.framework`

The TimelineSync framework provides an API to synchronise a timeline to the timeline exported by the TV for synchronisation (called the Synchronisation Timeline). The local estimate of the Synchronisation Timeline is represented by a CorrelatedClock object. Uses WebSockets.

| Framework | Component | Description |
| --- | --- | --- |
| [TimelineSync](TimelineSync/) |  [TSClient](TimelineSync/Classes/TSClient.html)   | A CSS-TS protocol client. Receives Control Timestamps from the TV. |
| [TimelineSync](TimelineSync/) |  [TimelineSynchroniser](TimelineSync/Classes/TimelineSynchroniser.html)   | A wrapper object that synchronises a CorrelatedClock object based on Synchronisation Timeline updates received from the TV via a TSClient|


### SyncController Objects

`SyncController.framework`

The SyncController framework provides  sync controller objects that can be used to synchronise a native media player to a given timeline. The SyncController object use a particular strategy to adapt the media player's playback (change speed of play, seek, or both) to ensure that it adheres to the given timeline.

It uses a [Correlation](ClockTimelines/classes/CorrelatedClock.html) and a [CorrelatedClock](ClockTimelines/Classes/CorrelatedClock.html) object to synthesise the expected timeline for the media player. The Correlation gives a mapping (a pair of timestamps) between the Synchronisation Timeline and the media asset's timeline.

For web views, it provides a JS framework (ios_sync.js) to register the web page for current-time updates on the TV's timeline. The framework includes example apps to demonstrate usage of the sync controller objects.

*Currently, a SyncController class is provided for each media player/web kit.*

| Framework | Component | Description |
| --- | --- | --- |
| [SyncController](SyncController/) |  [VideoPlayerSyncController](SyncController/Classes/VideoPlayerSyncController.html)   | Synchronises a video player (VideoPlayerViewController) to an expected timeline |
| [SyncController](SyncController/) |  [AudioSyncController](SyncController/Classes/AudioSyncController.html)   | Synchronises an audio player (AudioPlayer, AudioStreamPlayer or AudioPlayerViewController) to an expected timeline |
| [SyncController](SyncController/) |  [WebViewSyncController](SyncController/Classes/WebViewSyncController.html)   | A SyncController to send timestamps reporting progress of a TV programme to a web view |
| [SyncController](SyncController/) |  ios_sync.js   | JS library to register for register the web page for current-time updates on the TV's timeline. To be used in tandem with a [WebViewSyncController](SyncController/Classes/WebViewSyncController.html) on the native side. |


### MediaSynchroniser

`CSASynchroniser.framework`

The CSASynchroniser (also called MediaSynchroniser) dynamic framework provides a high-level Synchroniser object for media sync. It is a singleton that Companion Screen Applications can use to synchronise a media object to an external timeline source e.g. a TV video broadcast. It simplifies launching a synchronisation process using the DVB-CSS machinery. With the Synchroniser API, media objects only need to be registered with the Synchroniser to be synchronised.

To use the Synchroniser singletob, you need to initialise it with these parameters

* ```InterDeviceSyncURL``` - the master device's URL for interdevice synchronisation (obtained from discovery of the TV using DIAL, see [DIALDeviceDiscovery](DIALDeviceDiscovery/) sub-project for examples).
* ```App2AppURL``` - the master device's endpoint for communication between TV apps and companion screen Applications.
* ```TimelineSelector``` - a ```TimelineOption``` object providing a timeline name and other properties (e.g. tick rate, accuracy).

Media players are registered with the Synchroniser by adding MediaPlayerObject objects.

| Framework | Component | Description |
| --- | --- | --- |
| [CSASynchroniser](CSASynchroniser/) |  [MediaPlayerObject](CSASynchroniser/Classes/MediaPlayerObject.html)   | An object encapsulating a media player instance, the media URL and a correlation for mapping the Synchronisation Timeline to the media timeline |
| [CSASynchroniser](CSASynchroniser/) |  [Synchroniser](CSASynchroniser/Classes/Synchroniser.html)   | A singleton that accepts  MediaPlayerObject instances (each playing a media object) or web views to synchronise against a  TV |


## UI Components
| Framework | Component | Description |
| --- | --- | --- |
| [DIALTVSelectionUIViews](DIALTVSelectionUIViews/) |  [DIALDeviceCollectionViewController](DIALTVSelectionUIViews/Classes/DIALDeviceCollectionViewController.html)   | A ViewController which displays devices discovered by the DIALDeviceDiscovery framework as a collection (UICollectionView)|
| [DIALTVSelectionUIViews](DIALTVSelectionUIViews/) |  [DIALDeviceSelectorViewController](DIALTVSelectionUIViews/Classes/DIALDeviceSelectorViewController.html)   |A ViewController which displays devices discovered by the DIALDeviceDiscovery framework as a list (UITableView)  |

## Logging, Configuration and other utilities

| Framework | Component | Description |
| --- | --- | --- |
| [SimpleLogger](SimpleLogger/) |  SimpleLogger.h   |  Simple wrapper macros/functions around ASL (Apple System Log) |
| [SyncKitConfiguration](SyncKitConfiguration/) |  [ConfigReader](SyncKitConfiguration/Classes/ConfigReader.html)   | A library to read configuration key-value pairs from a config file and make them globally available.  |
| [SyncKitCollections](SyncKitCollections/) |  SyncKitCollections.h |  A collection of data structures and utility classes.|