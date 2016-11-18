# <small>dvbcss-synckit-ios</small><br/>ClockTimelines Framework


* **[How to use](#how-to-use)**
* **[Read the documentation](#read-the-documentation)**
* **[Run the example app](#run-the-example-app)**


An implementation of software "clock" objects in Objective-C. Very similar to that done for [pydvbcss](https://github.com/bbc/pydvbcss).

The **ClockTimelines** iOS framework library implements a generic and flexible model for thinking about clocks, timelines and the relationships between them. This model is described  in the BBC R&D WhitePaper [WHP321 "How to synchronise to an HbbTV 2.0 compliant TV"]().
It defines software clock abstractions to model the passage of time e.g. system time, media timelines progress.
Software clocks can, for example, be used to simulate the system clock, a clock belonging to another device, the timeline of a media.

A software simulation of a clock still needs to rely on some kind of physical clock or timer to advance time along the timeline and correctly control its speed. In practice this means utilising system clocks provided by the hardware and operating system. The [SystemClock](ClockTimelines/SystemClock.h) class uses a monotonic source of time with sufficient precision to simulate system time. A clock is simulated by specifying its relationship with respect to a source of time e.g. the SystemClock. This relationship is in the form of

* A **correlation** *(cx, cy)* is a pair of numbers - a time value (cx) for the system clock and the corresponding time (cy) for the simulated clock.

* The relative **speed** *s* is a number determining how rapidly the simulated clock advances for every tick of the system clock.

Three types of software clocks are provided:

1. [SystemClock](ClockTimelines/SystemClock.h) - A root clock class that is based on `MonotonicTime` as the underlying time source

2. [CorrelatedClock](ClockTimelines/CorrelatedClock.h) - a clock locked to the tick count of the parent clock by a correlation and frequency setting. Correlation is a tuple `(parentTicks, selfTicks)`. When the parent clock ticks property has the value `parentTicks`, the ticks property of this clock shall have the value `selfTicks`.

3. [TunableClock](ClockTimelines/CorrelatedClock.h) - A clock whose tick offset and speed can be adjusted on the fly.  Must be based on another clock, a parent clock. A tunable clock specifies a correlation relationship with respect to its parent clock. This correlation specifies a tick value, a tick rate and a speed value for this clock and a tick value from the parent clock as from which this relationship applies.

Changes to properties of the clock objects are notified to observers using iOS's Key-Value-Observation (KVO) mechanism. To observe changes to a clock, an object must add itself as an observer using the `addObserver:` method.


## Read the documentation
The documentation for the classes in the library can be read [here](index.html).

## How to use

#### Download and install
1.  Download and install using CocoaPods

// TODO  
2. Alternatively, download and build the project to generate the iOS framework and then include the framework in your projects.


#### Import the header files

Once the library and its dependencies have been added to your project, import this header file in your source file:

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

** Making changes to properties will trigger KVO notifications to observers **
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

The ClockTimelines library is developed by BBC R&D and distributed under the Apache License, [Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).

© Copyright 2016 BBC R&D. All Rights Reserved
