
//
//  AddDelayAudioTapProcessor.m
//  Acolyte
//
//  Created by Rajiv Ramdhany on 27/07/2015.
//  Copyright (c) 2015 BBC RD. All rights reserved.
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

#import "AddDelayAudioTapProcessor.h"
#import <AVFoundation/AVFoundation.h>
#import "TPCircularBuffer+AudioBufferList.h"

//------------------------------------------------------------------------------
#pragma mark - Data Structures
//------------------------------------------------------------------------------

/**
 *  This struct is used to pass along data between the MTAudioProcessingTap callbacks.
 */
typedef struct DelayAudioTapProcessorContext {
    Boolean supportedTapProcessingFormat;
    AudioStreamBasicDescription asbd;
    Boolean isNonInterleaved;
    UInt32  delayInMs;
    UInt32  bytesPerBuffer;
    UInt32  totalBufferSize;
    TPCircularBuffer cbuffer;
    void *self;
} DelayAudioTapProcessorContext;


//------------------------------------------------------------------------------
#pragma mark - Callback Methods for MTAudioProcessingTap
//------------------------------------------------------------------------------

static void tap_InitCallback(MTAudioProcessingTapRef tap, void *clientInfo, void **tapStorageOut);
static void tap_FinalizeCallback(MTAudioProcessingTapRef tap);
static void tap_PrepareCallback(MTAudioProcessingTapRef tap, CMItemCount maxFrames, const AudioStreamBasicDescription *processingFormat);
static void tap_UnprepareCallback(MTAudioProcessingTapRef tap);
static void tap_ProcessCallback(MTAudioProcessingTapRef tap, CMItemCount numberFrames, MTAudioProcessingTapFlags flags, AudioBufferList *bufferListInOut, CMItemCount *numberFramesOut, MTAudioProcessingTapFlags *flagsOut);




//------------------------------------------------------------------------------
#pragma mark - AddDelayAudioTapProcessor (Interface Extension)
//------------------------------------------------------------------------------

@interface AddDelayAudioTapProcessor ()
{
        AVAudioMix *_audioMix;
    
}
#pragma mark properties
/**
 *  Circular buffer for writing
 */
@property (readwrite, nonatomic) TPCircularBuffer *buffer;

@end



//------------------------------------------------------------------------------
#pragma mark - AddDelayAudioTapProcessor (Implementation)
//------------------------------------------------------------------------------


@implementation AddDelayAudioTapProcessor

//------------------------------------------------------------------------------
#pragma mark - Lifecycle methods
//------------------------------------------------------------------------------

- (id)initWithAudioAssetTrack:(AVAssetTrack *)audioAssetTrack
{
    NSParameterAssert(audioAssetTrack && [audioAssetTrack.mediaType isEqualToString:AVMediaTypeAudio]);
    
    self = [super init];
    
    if (self)
    {
        _audioAssetTrack = audioAssetTrack;
        
        _delayInMilliSecs = 0;
    }
    
    return self;
}

//------------------------------------------------------------------------------

- (void) dealloc{
    
    NSLog(@"AddDelayAudioTapProcessor dealloc: cleanup");
}



//------------------------------------------------------------------------------
#pragma mark - Getters
//------------------------------------------------------------------------------

- (AVAudioMix *)audioMix
{
    if (!_audioMix)
    {
        AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
        if (audioMix)
        {
            AVMutableAudioMixInputParameters *audioMixInputParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:self.audioAssetTrack];
            if (audioMixInputParameters)
            {
                MTAudioProcessingTapCallbacks callbacks;
                
                callbacks.version = kMTAudioProcessingTapCallbacksVersion_0;
                callbacks.clientInfo = (__bridge void *)self,
                callbacks.init = tap_InitCallback;
                callbacks.finalize = tap_FinalizeCallback;
                callbacks.prepare = tap_PrepareCallback;
                callbacks.unprepare = tap_UnprepareCallback;
                callbacks.process = tap_ProcessCallback;
                
                MTAudioProcessingTapRef audioProcessingTap;
                if (noErr == MTAudioProcessingTapCreate(kCFAllocatorDefault, &callbacks, kMTAudioProcessingTapCreationFlag_PreEffects, &audioProcessingTap))
                {
                    audioMixInputParameters.audioTapProcessor = audioProcessingTap;
                    
                    CFRelease(audioProcessingTap);
                    
                    audioMix.inputParameters = @[audioMixInputParameters];
                    
                    _audioMix = audioMix;
                }
            }
        }
    }
    
    return _audioMix;
}

@end


//------------------------------------------------------------------------------
#pragma mark - MTAudioProcessingTap Callbacks
//------------------------------------------------------------------------------

static void tap_InitCallback(MTAudioProcessingTapRef tap, void *clientInfo, void **tapStorageOut)
{
    DelayAudioTapProcessorContext *context = calloc(1, sizeof(DelayAudioTapProcessorContext));
    
    // Initialize MTAudioProcessingTap context.
    context->supportedTapProcessingFormat = false;
    context->isNonInterleaved = false;
    context->bytesPerBuffer = 0;
    context->self = clientInfo;
    
    *tapStorageOut = context;
}

//------------------------------------------------------------------------------

static void tap_FinalizeCallback(MTAudioProcessingTapRef tap)
{
    DelayAudioTapProcessorContext *context = (DelayAudioTapProcessorContext *)MTAudioProcessingTapGetStorage(tap);
    
    // Clear MTAudioProcessingTap context.
    context->self = NULL;
    
    free(context);
    
    NSLog(@"AddDelayAudioTapProcessor: tap_FinalizeCallback. ");
    
}

//------------------------------------------------------------------------------

static void tap_PrepareCallback(MTAudioProcessingTapRef tap, CMItemCount maxFrames, const AudioStreamBasicDescription *processingFormat)
{
   
    DelayAudioTapProcessorContext *context = (DelayAudioTapProcessorContext *)MTAudioProcessingTapGetStorage(tap);
    
    // Store sample rate, bytes per frame, channels per frame ...
    context->asbd = *processingFormat; //deep copy
    
    /* Verify processing format */
    
    context->supportedTapProcessingFormat = true;
    
    if (processingFormat->mFormatID != kAudioFormatLinearPCM)
    {
        NSLog(@"Unsupported audio format ID for audioProcessingTap. LinearPCM only.");
        context->supportedTapProcessingFormat = false;
    }
    
    if (!(processingFormat->mFormatFlags & kAudioFormatFlagIsFloat))
    {
        NSLog(@"Unsupported audio format flag for audioProcessingTap. Float only.");
        context->supportedTapProcessingFormat = false;
    }
    
    if (processingFormat->mFormatFlags & kAudioFormatFlagIsNonInterleaved)
    {
        context->isNonInterleaved = true;
    }
    
    AddDelayAudioTapProcessor *self = ((__bridge AddDelayAudioTapProcessor *)context->self);

    
    /* Create a circular buffer that will contain our delay-samples block + 2 x AudioBufferList block of audio */
    
    // Get number of AudioBuffer in AudioBufferList
    UInt32 numberOfBuffers = (processingFormat->mFormatFlags & kAudioFormatFlagIsNonInterleaved) ? processingFormat->mChannelsPerFrame : 1;
    
    // calculate the delay block length
    UInt32 nDelayFrames = (processingFormat->mSampleRate * self.delayInMilliSecs)/1000;
    
    UInt32 delay_block_length  = sizeof(TPCircularBufferABLBlockHeader) +
                                ((numberOfBuffers - 1) * sizeof(AudioBuffer)) +
                                (numberOfBuffers * (nDelayFrames * processingFormat->mBytesPerFrame));
    
    // calculate normal audio block length
    UInt32 block_length = sizeof(TPCircularBufferABLBlockHeader) +
                            ((numberOfBuffers - 1) * sizeof(AudioBuffer)) +
                            (numberOfBuffers * ((UInt32) maxFrames * processingFormat->mBytesPerFrame));

    context->bytesPerBuffer = ((UInt32) maxFrames) * processingFormat->mBytesPerFrame;
    context->totalBufferSize = delay_block_length + 2 * block_length;
    
    // create circular buffer of length = 'totalBufferSize'
        if (TPCircularBufferInit(&(context->cbuffer), context->totalBufferSize))
    {
        NSLog(@"AddDelayAudioTapProcessor.tap_PrepareCallback(): Circular buffer created.");
        
        // --- add our delay samples ---
        // prepare an empty AudioBufferList
        AudioBufferList *delayBufferList = TPCircularBufferPrepareEmptyAudioBufferListWithAudioFormat(&context->cbuffer, processingFormat, nDelayFrames, NULL);
        
        // set samples in buffer to silence
        for ( int i=0; i<numberOfBuffers; i++ )
        {
            memset(delayBufferList->mBuffers[i].mData, 0, delayBufferList->mBuffers[i].mDataByteSize);
        }
        
        // update circular buffer to reflect our block addition
        TPCircularBufferProduceAudioBufferList(&context->cbuffer, NULL);
        
        
    }else{
         NSLog(@"AddDelayAudioTapProcessor.tap_PrepareCallback(): Circular buffer mem allocation failed.");
    }

}

//------------------------------------------------------------------------------


static void tap_UnprepareCallback(MTAudioProcessingTapRef tap)
{
    DelayAudioTapProcessorContext *context = (DelayAudioTapProcessorContext *)MTAudioProcessingTapGetStorage(tap);
    
    /* Release delay filter Audio Unit */
    
    if (context->cbuffer.buffer)
    {
        TPCircularBufferCleanup(&context->cbuffer);
        NSLog(@"AddDelayAudioTapProcessor: TPCircularBuffer cleanup. ");
        
    }
}

//------------------------------------------------------------------------------

static void tap_ProcessCallback(MTAudioProcessingTapRef tap, CMItemCount numberFrames, MTAudioProcessingTapFlags flags, AudioBufferList *bufferListInOut, CMItemCount *numberFramesOut, MTAudioProcessingTapFlags *flagsOut)
{
    DelayAudioTapProcessorContext *context = (DelayAudioTapProcessorContext *)MTAudioProcessingTapGetStorage(tap);

    OSStatus status;

    // Skip processing when format not supported.
    if (!context->supportedTapProcessingFormat)
    {
        NSLog(@"Unsupported tap processing format.");
        return;
    }
    AddDelayAudioTapProcessor *self = ((__bridge AddDelayAudioTapProcessor *)context->self);
    assert(context->cbuffer.buffer != NULL);
    assert(context->bytesPerBuffer !=0);

    /* ---- read audio samples from Audio Tap and write into circular buffer -----*/
    
    // Get actual audio samples from MTAudioProcessingTap
    status = MTAudioProcessingTapGetSourceAudio(tap, numberFrames, bufferListInOut, flagsOut, NULL, numberFramesOut);
    if (noErr != status)
    {
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        NSLog(@"MTAudioProcessingTapGetSourceAudio: Error: %d , %@", (int)status, error.description);
        return;
    }
    
//    NSLog(@"bufferListInOut: mNumberBuffers=%d mBuffers[0].mNumberChannels=%d  mBuffers[0].mDataByteSize=%d numberFrames=%ld numberFramesOut=%ld", bufferListInOut->mNumberBuffers, bufferListInOut->mBuffers[0].mNumberChannels,  bufferListInOut->mBuffers[0].mDataByteSize, numberFrames, *numberFramesOut);
    
    if (self.isDelayFilterEnabled) {
        
        // copy all samples returned from MTAudioProcessingTapGetSourceAudio() into our circular buffer
        if (!TPCircularBufferCopyAudioBufferList(&context->cbuffer, bufferListInOut, NULL, kTPCircularBufferCopyAll, &context->asbd)) {
            NSLog(@"Error copying audio samples to circular buffer");
            return;
        }
        
       // read number of frames requested by callback (numberFrames) from buffer into system-allocated bufferListInOut
       // Note: samples may span across more than one blocks
       
        
        UInt32 ioLengthInFrames = (UInt32) numberFrames;
        
        if (bufferListInOut->mBuffers[0].mData == NULL)
            NSLog(@"bufferListInOut->mBuffers[0].mData is NULL !!!!!!");
        
        if (bufferListInOut->mBuffers[1].mData == NULL)
            NSLog(@"bufferListInOut->mBuffers[0].mData is NULL !!!!!!");
        
        
        TPCircularBufferDequeueBufferListFrames(&context->cbuffer, &ioLengthInFrames, bufferListInOut, NULL, &(context->asbd));
      
        
        
        *numberFramesOut = ioLengthInFrames;
    
    }
    
}
//------------------------------------------------------------------------------
