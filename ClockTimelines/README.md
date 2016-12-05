# <small>dvbcss-synckit-ios</small><br/>ClockTimelines Framework


[](---START EXCLUDE FROM DOC BUILD---)
* **[Read the documentation](#read-the-documentation)**
[](---END EXCLUDE FROM DOC BUILD---)
* **[Overview](#overview)**
* **[How to use](#how-to-use)**
* **[Run the example app](#run-the-example-app)**


An implementation of software "clock" objects in Objective-C. Very similar to that done for [pydvbcss](https://github.com/bbc/pydvbcss).

This framework implements a generic and flexible model for thinking about clocks, timelines and the relationships between them. It defines software clock abstractions to model the passage of time e.g. system time, media timelines progress.
Software clocks can, for example, be used to simulate the system clock, a clock belonging to another device, or the timeline of a media.

* **SystemClock** object represents local system clock time
* **CorrelatedClock** represents time calculated from a parent clock using a *correlation* relationship.
* **TunableClock** represents time calculated from a parent clock using an adjustable *offset* value.


#[](---START EXCLUDE FROM DOC BUILD---)
## Read the documentation
The docs for this framework can be read [here](http://bbc.github.io/dvbcss-synckit-ios/latest/ClockTimelines/).
[](---END EXCLUDE FROM DOC BUILD---)



# Overview

A clock object models time by calculating it based on some other source of time
represented by another clock object (its parent). They can be assembled into hierarchies
or chains. For example: suppose you have a presentation where a video clip is
to be played at a particular point. You describe the timing of that video clip in terms
of when it is to be played on the timeline of the overall presentation. Clock objects
can model this, with a clock representing the video clip time position, and its
parent representing the progress of the timeline of the overall presentation.

A software simulation of a clock still needs to rely on some kind of physical clock or timer to advance time along the timeline and correctly control its speed. In practice this means utilising system clocks provided by the hardware and operating system. So at the root of the hierarchy
or chain is a root clock that has no parent.

Three types of software clocks are provided:

#### [SystemClock](http://bbc.github.io/dvbcss-synckit-ios/latest/ClockTimelines/Classes/SystemClock.html)

*[ClockTimelines/SystemClock.h](ClockTimelines/SystemClock.h)*

A root clock class that is based on `MonotonicTime` as the underlying time source

#### [CorrelatedClock](http://bbc.github.io/dvbcss-synckit-ios/latest/ClockTimelines/Classes/CorrelatedClock.html)

*[ClockTimelines/CorrelatedClock.h](ClockTimelines/CorrelatedClock.h)*

A clock whose time is calculated form a parent clock by using a *correlation* and *speed*.
It also has a *tickRate* that sets the units of the clock. If the clock advances one second then the time it reports increases by the number of ticks dictated by its tick rate.

To model progress of a media timeline, or a clock on another device, we specify the relationship
with respect to a source of time e.g. the System Clock. This relationship is in the form of:

* A **correlation** *(parentTickValue, tickValue)* is a pair of numbers - a time value for the parent clock and the corresponding time for this clock.

* The relative **speed** *s* is a number determining how rapidly this clock advances for every tick of the system clock.

When the parent clock ticks property has the value `parentTickValue`, the ticks property of this clock shall have the value `tickValue`. For every second the parent clock advances, this
clock will advance by the same number of seconds multiplied by `s`.

#### [TunableClock](http://bbc.github.io/dvbcss-synckit-ios/latest/ClockTimelines/Classes/CorrelatedClock.html)

*[ClockTimelines/TunableClock.h](ClockTimelines/CorrelatedClock.h)*

A clock that is related to a parent clock by using a "offset" instead of a "correlation". In practice this is very similar to a CorrelatedClock.

### Reacting to changes

Changes to properties of the clock objects are notified to observers using iOS's Key-Value-Observation (KVO) mechanism. To observe changes to a clock, an object must add itself as an observer using the `addObserver:` method.

In this way, your application can react to updates and changes without having
to continuously poll the clock objects.



## How to use

#### 1. Add the framework to your project

A Cocoa Pod version of this library is not currently available. To use this library, you must add it and its dependencies to your project.

Either include *ClockTimelines* in your workspace and build it; or build it in this repository's [synckit.xcworkspace](../synckit.xcworkspace)

Then add *ClockTimelines.framework* under *Linked Frameworks and libraries* in your project's target configuration.

#### 2. Import the header files

```objective-c
#import <ClockTimelines/ClockTimelines.h>
```


#### Simple Example
The SystemClock class uses a source of monotonic time to simulate system time. Monotonic time is provided by the [MonotonicTime](ClockTimelines/MonotonicTime.h) class.
Now we create a simple hierarchy with one clock at the root and another one based on it via a correlation:

```objective-c
  SystemClock *sysCLK = [[SystemClock alloc] initWithTickRate:1000000];

  Correlation corel = [CorrelationFactory create:0 Correlation:500];

  CorrelatedClock *corelCLK = [[CorrelatedClock alloc] initWithParentClock:sysCLK TickRate:1000 Correlation:&corel];

  NSLog(@"corelCLK ticks: %lld,  time: %f,  nanoseconds: %lld", [corelCLK ticks], [corelCLK time], [corelCLK nanoSeconds])

```

**Create a WallClock using a TunableClock object:**

```objective-c
  SystemClock *sysCLK;
  sysCLK = [[SystemClock alloc] initWithTickRate:_kOneThousandMillion];

  //create a WallClock with start ticks equal to system clock current ticks and same tick rate as the system clock.
  TunableClock *wallClock = [[TunableClock alloc] initWithParentClock:sysCLK TickRate:_kOneThousandMillion Ticks:[sysCLK ticks]];

  NSLog(@"Wall clock time = %f ", [wallClock time]);
```

**Making changes to properties will trigger KVO notifications to observers.**
This will generate 2 change events: one for the `speed` property and one for the `correlation` property):

```objective-c
    wallClock.speed = 2.0

    MockDependent *observer; // a clock change observer

    //  create a system clock
    SystemClock *sysclock = [[SystemClock alloc] initWithTickRate:1000000];

    // Correlation Clock with correlation
    Correlation corel = [CorrelationFactory create:0 Correlation:500];
    CorrelatedClock *corelCLK = [[CorrelatedClock alloc] initWithParentClock:sysclock TickRate:1000 Correlation:&corel];

    // an observer
    observer = [[MockDependent alloc] init];

    [corelCLK addObserver:observer context:nil];

    // change correlation relationship
    Correlation corel_new = [CorrelationFactory create:100 Correlation:5000];
    Correlation corel_old = corelCLK.correlation;

    // carry out actual change
    corelCLK.correlation = corel_new;

```

**To handle the key-value observations, an observer must implement the `observerValueForKeyPath:` method. For example,**

``` objective-c
@implementation MockDependent

- (id) init
{
    self = [super init];
    if (self != nil) {
        self.notifications = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
     if ([keyPath isEqualToString:@"tickRate"]) {
        NSLog(@"tickRate of clock object changed.");
        NSLog(@"%@", change);
    }

    if ([keyPath isEqualToString:@"speed"]) {
        NSLog(@"Speed of clock was changed.");
        NSLog(@"%@", change);
    }

    if ([keyPath isEqualToString:@"correlation"]) {
        NSLog(@"correlation was changed.");
    }

    if ([keyPath isEqualToString:@"startTicks"]) {
        NSLog(@"startTicks was changed.");
         NSLog(@"%@", change);
    }
}

@end

```


## Authors

Rajiv Ramdhany (BBC R&D)

## Licence

This library is developed by BBC R&D and distributed under the Apache License, [Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).

© Copyright 2016 BBC R&D. All Rights Reserved
