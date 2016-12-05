//
//  AudioStreamPlayer.h
//  AudioStreamPlayer
//
//  Created by Rajiv Ramdhany on 29/05/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.
//


//  Copyright 2015 British Broadcasting Corporation
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
#import <Cocoa/Cocoa.h>


#endif // TARGET_OS_IPHONE

#include <pthread.h>
#include <AudioToolbox/AudioToolbox.h>

#import <Foundation/Foundation.h>


//------------------------------------------------------------------------------
#pragma mark - constants
//------------------------------------------------------------------------------

#define LOG_QUEUED_BUFFERS 0

/**
 Number of audio queue buffers we allocate.
 Needs to be big enough to keep audio pipeline
 busy (non-zero number of queued buffers) but
 not so big that audio takes too long to begin
 (kNumAQBufs * kAQBufSize of data must be
 loaded before playback will start).
 Set LOG_QUEUED_BUFFERS to 1 to log how many
 buffers are queued at any time -- if it drops
 to zero too often, this value may need to
 increase. Min 3, typical 8-24.
 */
#define kNumAQBufs 16

/**
 Number of bytes in each audio queue buffer
 Needs to be big enough to hold a packet of
 audio from the audio file. If number is too
 large, queuing of audio before playback starts
 will take too long.
 Highly compressed files can use smaller
 numbers (512 or less). 2048 should hold all
 but the largest packets. A buffer size error
 will occur if this number is too small.
 */
#define kAQDefaultBufSize 2048

/**
 * Number of packet descriptions in our array
 */
#define kAQMaxPacketDescs 512


//------------------------------------------------------------------------------
#pragma mark - Data Structures
//------------------------------------------------------------------------------

/**
 AudioStreamPlayer states
 */
typedef enum
{
    AS_INITIALIZED = 0,
	AS_STARTING_FILE_THREAD,
	AS_WAITING_FOR_DATA,
	AS_FLUSHING_EOF,
	AS_WAITING_FOR_QUEUE_TO_START,
	AS_PLAYING,
	AS_BUFFERING,
	AS_STOPPING,
	AS_STOPPED,
	AS_PAUSED
}AudioStreamPlayerState;

//------------------------------------------------------------------------------

/**
 AudioStreamPlayer stopped reasons
 */
typedef enum
{
	AS_NO_STOP = 0,
	AS_STOPPING_EOF,
	AS_STOPPING_USER_ACTION,
	AS_STOPPING_ERROR,
	AS_STOPPING_TEMPORARILY
} AudioStreamPlayerStopReason;

//------------------------------------------------------------------------------

/**
 Audiostreamer error codes
 */
typedef enum
{
	AS_NO_ERROR = 0,
	AS_NETWORK_CONNECTION_FAILED,
	AS_FILE_STREAM_GET_PROPERTY_FAILED,
	AS_FILE_STREAM_SET_PROPERTY_FAILED,
	AS_FILE_STREAM_SEEK_FAILED,
	AS_FILE_STREAM_PARSE_BYTES_FAILED,
	AS_FILE_STREAM_OPEN_FAILED,
	AS_FILE_STREAM_CLOSE_FAILED,
	AS_AUDIO_DATA_NOT_FOUND,
	AS_AUDIO_QUEUE_CREATION_FAILED,
	AS_AUDIO_QUEUE_BUFFER_ALLOCATION_FAILED,
	AS_AUDIO_QUEUE_ENQUEUE_FAILED,
	AS_AUDIO_QUEUE_ADD_LISTENER_FAILED,
	AS_AUDIO_QUEUE_REMOVE_LISTENER_FAILED,
	AS_AUDIO_QUEUE_START_FAILED,
	AS_AUDIO_QUEUE_PAUSE_FAILED,
	AS_AUDIO_QUEUE_BUFFER_MISMATCH,
	AS_AUDIO_QUEUE_DISPOSE_FAILED,
	AS_AUDIO_QUEUE_STOP_FAILED,
	AS_AUDIO_QUEUE_FLUSH_FAILED,
	AS_AUDIO_STREAMER_FAILED,
	AS_GET_AUDIO_TIME_FAILED,
	AS_AUDIO_BUFFER_TOO_SMALL,
    AS_AUDIO_SESSION_SETUP_FAILED
} AudioStreamPlayerErrorCode;

//------------------------------------------------------------------------------
#pragma mark - Data Structures
//------------------------------------------------------------------------------

extern NSString * const ASStatusChangedNotification;


//------------------------------------------------------------------------------
#pragma mark - AudioStreamPlayer
//------------------------------------------------------------------------------

/**
 *  An audio stream player based on Apple's Core Audio Framework. More specifically, Audio Queue 
 * Services and AudioFileStream are used to handle audio buffers and audio streaming respectively.
 *
 * @discussion: Special threading consideration- The audioQueue property should only ever be accessed inside a synchronized(self) block and only *after* checking that ![self isFinishing]
 */
@interface AudioStreamPlayer : NSObject
{
    
//------------------------------------------------------------------------------
#pragma mark - Instance variables
//------------------------------------------------------------------------------
    /**
     *  audio stream URL
     */
    NSURL *url;
    
    /**
   	 *  Audio Queue object
   	 */
   	AudioQueueRef audioQueue;
    
    /**
     *  the audio file stream parser
     */
	AudioFileStreamID audioFileStream;
    
    /**
     *  Audio file
     */
    AudioFileID audioFile;
    /**
     *  description of the audio
     */
  	AudioStreamBasicDescription asbd;
    
    /**
     *  the thread where the download and audio file stream parsing occurs
     */
    NSThread *internalThread;
    
    /**
     *  audio queue buffers
     */
	AudioQueueBufferRef audioQueueBuffer[kNumAQBufs];
    
    /**
     *  packet descriptions for enqueuing audio
     */
	AudioStreamPacketDescription packetDescs[kAQMaxPacketDescs];
    
    /**
   	 *  the index of the audioQueueBuffer that is being filled
   	 */
   	unsigned int fillBufferIndex;
    
	UInt32 packetBufferSize;
    
    /**
     *  how many bytes have been filled
     */
    size_t bytesFilled;
    
    /**
     *  how many packets have been filled
     */
    size_t packetsFilled;
    
    /**
   	 *  flags to indicate that a buffer is still in use
   	 */
   	bool inuse[kNumAQBufs];
    
	NSInteger buffersUsed;
	NSDictionary *httpHeaders;
	NSString *fileExtension;
	
	AudioStreamPlayerState state;
	AudioStreamPlayerState laststate;
	AudioStreamPlayerStopReason stopReason;
	AudioStreamPlayerErrorCode errorCode;
	OSStatus err;
	
    /**
     *  flag to indicate middle of the stream
     */
	bool discontinuous;
	
    /**
     *  a mutex to protect the inuse flags
     */
	pthread_mutex_t queueBuffersMutex;
    
    /**
     *  a condition varable for handling the inuse flags
     */
	pthread_cond_t queueBufferReadyCondition;
    
	CFReadStreamRef stream;
	NSNotificationCenter *notificationCenter;
	
    /**
     *  Bits per second in the file
     */
	UInt32 bitRate;
    
    /**
     *  Offset of the first audio packet in the stream
     */
	NSInteger dataOffset;
    
    /**
     *  Length of the file in bytes
     */
	NSInteger fileLength;
    
    /**
     *  Seek offset within the file in bytes
     */
	NSInteger seekByteOffset;
    
    /**
     *  Used when the actual number of audio bytes in
      the file is known (more accurate than assuming
      the whole file is audio)

     */
	UInt64 audioDataByteCount;
    /**
     *  number of packets accumulated for bitrate estimation
     */
	UInt64 processedPacketsCount;
    
    /**
     *  byte size of accumulated estimation packets
     */
	UInt64 processedPacketsSizeTotal;
    
	double seekTime;
	BOOL seekWasRequested;
	double requestedSeekTime;
    
    /**
     *  Sample rate of the file (used to compare with
     samples played by the queue for current playback
     time)
     */
    double sampleRate;
    
    /**
     *  sample rate times frames per packet
     */
    double packetDuration;
    
    /**
     *  last calculated progress point
     */
	double lastProgress;
    
#if TARGET_OS_IPHONE
	BOOL pausedByInterruption;
#endif
}

//------------------------------------------------------------------------------
#pragma mark - AudioStreamPlayer properties
//------------------------------------------------------------------------------

@property (readwrite) NSTimeInterval offset;

/**
 *  Error code after AudioStreamPlayer internal error
 */
@property AudioStreamPlayerErrorCode errorCode;

/**
 *  AudioStreamPlayer's current state
 */
@property (readonly) AudioStreamPlayerState state;

/**
 *  AudioStreamPlayer current playback time
 */
@property (readonly) double currentTime;

/**
 *  The duration of available audio in seconds. Calculated from the bitRate and fileLength.
 */
@property (readonly) double duration;

/**
 *  The audio stream's bit rate, if known.
 */
@property (readwrite) UInt32 bitRate;

/**
 *  HTTP headers from received audio stream messages. Includes the mime type.
 */
@property (readonly) NSDictionary *httpHeaders;

/**
 *  File extension for audio file stream
 */
@property (copy,readwrite) NSString *fileExtension;

/**
 *  to control whether the alert is displayed in failWithErrorCode
 */
@property (nonatomic) BOOL shouldDisplayAlertOnError;




//------------------------------------------------------------------------------
#pragma mark - Initialisation routines
//------------------------------------------------------------------------------

/**
 *  Initialiser
 *
 *  @param aURL audio stream internet address
 *
 *  @return initialised instance.
 */
- (id)initWithURL:(NSURL *)aURL;


//------------------------------------------------------------------------------
#pragma mark - instantiation routines
//------------------------------------------------------------------------------
/**
 Creates an AudioStreamPlayer instance with an NSURL instance representing the HTTP address of the audio stream.
 @param url The NSURL instance representing the internet address of the audio stream.
 @return The newly created AudioStreamPlayer instance
 */
+ (instancetype)audioStreamPlayerWithURL:(NSURL*)url;


//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------
/**
 *  Start audio stream playback
 */
- (void)start;

//------------------------------------------------------------------------------

/**
 *   Stops audio stream playback
 */
- (void)stop;

//------------------------------------------------------------------------------

/**
 *   Pauses audio stream playback
 */
- (void)pause;

//------------------------------------------------------------------------------

/**
 *  Skips audio samples to move playhead to new position.
 *
 *  @param newSeekTime new playhead position in seconds (and fractions of a second)
 */
- (void)seekToTime:(NSTimeInterval)newSeekTime;

//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
#pragma mark - Status methods
//------------------------------------------------------------------------------

/**
 *  Playing status check
 *
 *  @return true is player is playing audio stream
 */
- (BOOL)isPlaying;

//------------------------------------------------------------------------------

/**
 *  Paused status check
 *
 *  @return true is player is paused
 */
- (BOOL)isPaused;

//------------------------------------------------------------------------------

/**
 *  Check if audio player is waiting for audio samples in the stream
 *
 *  @return YES if in AS_WAITING_FOR_DATA state
 */
- (BOOL)isWaiting;

//------------------------------------------------------------------------------

/**
 *  Check if audio player is initalised but not doing anything
 *
 *  @return YES if the AudioStream is in the AS_INITIALIZED state
 */
- (BOOL)isIdle;

//------------------------------------------------------------------------------

/**
 *  return YES if streaming halted due to error (AS_STOPPING + AS_STOPPING_ERROR)
 *
 *  @return YES if streaming halted due to error (AS_STOPPING + AS_STOPPING_ERROR)
 */
- (BOOL)isAborted;

//------------------------------------------------------------------------------

/**
 *  Caclulates bitrate of the stream.
 *
 *  @return returns the bit rate, if known. Uses packet duration times running bits per packet 
 *  if available, otherwise it returns the nominal bitrate. Will return zero if no useful 
 *  option available.
 */
- (double)calculatedBitRate;

//------------------------------------------------------------------------------


@end
