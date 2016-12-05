//
//  ConfigurableClock.m
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 06/08/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.
//

#import "ConfigurableClock.h"


@interface ConfigurableClock()
/** timestamp from masterclock when this clock is started. [lastticks, ticks] is a correlation timestamp */
@property (atomic, readwrite) uint64_t lastticks;

// redeclare as read-write
/** Master clock to drive this clock */
@property (atomic, readwrite) ClockBase* masterClock;
/** A multiplier to the tick rate of the master clock. */
@property (atomic, readwrite) float rate;
/** Start tick count for this clock*/
@property (atomic, readwrite) uint64_t ticks;
/** Boolean flag for clock activity */
@property (atomic, readwrite, getter = isActive) BOOL active;


@end


@implementation ConfigurableClock
{
    
}
const int64_t kOne_ThousandMillion = 1000000000;

/**
 * initialises instance of ConfigurableClock with a master clock, rate relative to the master clock and ticks offset
 *
 * @param aClock an instance of or an object which is a subtype of ClockBase, which will be the master clock driving this clock
 * @param rate a relative rate with respect to the frequency (ticks per second) of the master clock. A rate of 0.0 means the
 * ConfigurableClock does not advance over time. A rate of 1.0 means that the ConfigurableClock progresses forward at the same frequency
 * as its master clock; a rate of -0.5 means that ConfigurableClock time progresses backwards at the half the rate of the master clock.
 * @param ticks the tick count to start this clock with.
 * @return an instance of the confifgurable clock.
 */
- (id) initWithClock: (ClockBase*) aClock Rate:(float) rate Ticks:(uint64_t) ticks{
    
    self = [super init];
    if (self != nil) {
       
        _masterClock = aClock;
        _rate = rate;
        _ticks = ticks;
        _active = false;
    }
    return self;
}


/**
* initialises instance of ConfigurableClock with a master clock, rate relative to the master clock and ticks offset
*
* @param aClock an instance of or an object which is a subtype of ClockBase, which will be the master clock driving this clock
* @param rate a relative rate with respect to the frequency (ticks per second) of the master clock. A rate of 0.0 means the
* ConfigurableClock does not advance over time. A rate of 1.0 means that the ConfigurableClock progresses forward at the same frequency
* as its master clock; a rate of -0.5 means that ConfigurableClock time progresses backwards at the half the rate of the master clock.
* @param offset
* @return an instance of the confifgurable clock.
*/
- (id) initWithClock: (ClockBase*) aClock Rate:(float) rate NanosOffset:(uint64_t) offsetns{
    
    self = [super init];
    if (self != nil) {
        
        _masterClock = aClock;
        _rate = rate;
        _ticks = [_masterClock nanoSecondsToTicks:offsetns];
        _active = false;
    }
    return self;
    
}

/**
 Start the clock from <code>ticks</code> at specified rate
 lastticks is the tickcount reading from the master clock.
 */
- (void) start
{
    if ([self isActive])
    {
        return;
    }else{
        
        _active = true;
        _lastticks = [_masterClock getTicks];
    }
    
}

/**
 Stop the clock; set active to false
 */
- (void) invalidate
{
    _active = false;
}

/**
 adjust the offset
 */
- (void) adjustTicks:(uint64_t) offset{
    
    _ticks += offset;
    [self notifyObservers:kClockDidChangeTickOffset object:self userInfo:nil];
}


/**
 adjust the offset 
 */
- (void) adjustNanos:(uint64_t) offset_nanos{
    
     uint64_t offset_ticks = [self nanoSecondsToTicks:offset_nanos];
    
    _ticks = _ticks + offset_ticks;
    
    [self notifyObservers:kClockDidChangeTickOffset object:self userInfo:nil];
 }

/**
 adjust the offset, if it is negative
 */
- (void) adjustNegNanos:(int64_t) offset_nanos{
    
    if (offset_nanos < 0) {
        offset_nanos *= -1;
    }
    
    uint64_t offset_ticks = [self nanoSecondsToTicks:(offset_nanos)];
    
    _ticks = _ticks - offset_ticks;

    [self notifyObservers:kClockDidChangeTickOffset object:self userInfo:nil];
}


- (uint64_t) NanosToMasterClockNanos:(uint64_t) timeInNanos
{
    
    // 1. convert time to ticks on this clock, 2. get delta for ticks lapsed on this clock,
    //  3. and then add to lastticks to get corresponding ticks on master clock
    
    //    uint64_t timeInTicks = [self nanoSecondsToTicks:timeInNanos];
    //
    //    uint64_t diff = (timeInTicks - _ticks);
    //
    //    uint64_t ticksElapsedonMasterClock = diff/_rate;
    //
    //    uint64 timeInMasterClockTicks = _lastticks + ticksElapsedonMasterClock;
    //
    //    uint64 timeInMasterClockNanos = [_masterClock ticksToNanoSeconds:timeInMasterClockTicks];
    
    uint64_t masterClockTicks = _lastticks + ([self nanoSecondsToTicks:timeInNanos] - _ticks)/_rate;
    
    
    return ([_masterClock ticksToNanoSeconds:masterClockTicks]);
    
    //    return timeInMasterClockNanos;
    
    
}


/**
 * adjust the clock's rate relative to the master clock.
 */
- (void) adjustRate:(float) rate{
    
    // how many ticks have elapsed since clock was (re-)initalised.
    uint64_t now = [_masterClock getTicks] ;
    uint64_t delta = now - _lastticks;
    
    // readjust clock to make such that it runs at new rate from now on
    _ticks += delta * _rate;
    _lastticks = [_masterClock getTicks];
    
    // new correlation is [lastticks, ticks]
    
    // now set rate to new rate
    _rate = rate;
    
    // notify observers
    [self notifyObservers:kClockDidChangeRate object:self userInfo:nil];
}



#pragma mark SystemClock methods



- (NSString*) toString
{
    return @" ";
}


#pragma mark ClockProtocol methods


/**
 get tick count of this clock
 */
- (uint64_t) getTicks
{
    uint64_t now = [_masterClock getTicks];
    uint64_t delta = now - _lastticks;
    
    //NSLog(@"clock ticks: %llu", now);
    
    
    if (_rate != 0.0)
    {
        return _ticks + (uint64_t) ((Float64) delta * (Float64) _rate);
        
    }else
    {

        return _ticks;
    }
   
    
}


- (uint64_t) getTicksPerSecond
{
 
    if (_rate < 0.0)
        
        return (-1 * _masterClock.getTicksPerSecond * _rate);
    else
        
        return ( _masterClock.getTicksPerSecond * _rate);
}




- (CMTime) getTime
{
    
    return CMTimeMake((int64_t)[self getNanoSeconds], kOne_ThousandMillion);
}


#pragma mark cleanup
- (void)dealloc
{
    _masterClock = nil;
}






@end
