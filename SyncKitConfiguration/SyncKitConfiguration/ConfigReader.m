//
//  ConfigReader.m
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 18/08/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.
//
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


#import "ConfigReader.h"

@interface ConfigReader()

@property NSDictionary *configValues;

@end


@implementation ConfigReader


+ (ConfigReader *)getInstance {
    static ConfigReader *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ConfigReader alloc] init];
    });
    return instance;
}


+ (ConfigReader *)getInstanceWithConfigFile:(NSString*) filepath
{
    static ConfigReader *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ConfigReader alloc] initWithConfigFile:filepath];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        NSString *configFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"Config"
                                                                   ofType:@"plist"];
        self.configValues = [NSDictionary dictionaryWithContentsOfFile:configFilePath];
    }
    return self;
}

- (id)initWithConfigFile:(NSString*) file {
    self = [super init];
    if (self) {
        
        NSString* filename = [file stringByDeletingPathExtension];
        NSString* ext = [file pathExtension];
        NSString* configFilePath =  [[NSBundle  mainBundle] pathForResource:filename ofType:ext];
        if (configFilePath){
        
            self.configValues = [NSDictionary dictionaryWithContentsOfFile:configFilePath];
        }
    }
    return self;
}



- (NSString *)stringForKey:(NSString *)key defaultValue:(NSString *)defaultValue {
    id valueObject = [_configValues objectForKey:key];
    if ([valueObject isKindOfClass:[NSString class]]) {
        return (NSString *)valueObject;
    }
    else {
        return defaultValue;
    }
}

- (NSInteger)integerForKey:(NSString *)key defaultValue:(NSInteger)defaultValue {
    id valueObject = [_configValues objectForKey:key];
    if ([valueObject isKindOfClass:[NSNumber class]]) {
        return [valueObject integerValue];
    }
    else {
        return defaultValue;
    }
}

- (NSInteger)LongIntegerForKey:(NSString *)key defaultValue:(NSInteger)defaultValue {
    id valueObject = [_configValues objectForKey:key];
    if ([valueObject isKindOfClass:[NSNumber class]]) {
        return [valueObject longValue];
    }
    else {
        return defaultValue;
    }
}


- (unsigned int) unsignedIntegerForKey:(NSString *)key defaultValue:(unsigned int)defaultValue{
    id valueObject = [_configValues objectForKey:key];
    if ([valueObject isKindOfClass:[NSNumber class]]) {
        return [valueObject unsignedIntValue];
    }
    else {
        return defaultValue;
    }
}

- (unsigned long) unsignedLongIntegerForKey:(NSString *)key defaultValue:(unsigned long)defaultValue{
    id valueObject = [_configValues objectForKey:key];
    if ([valueObject isKindOfClass:[NSNumber class]]) {
        return [valueObject unsignedLongValue];
    }
    else {
        return defaultValue;
    }
}

- (double)doubleForKey:(NSString *)key defaultValue:(double)defaultValue {
    id valueObject = [_configValues objectForKey:key];
    if ([valueObject isKindOfClass:[NSNumber class]]) {
        return [valueObject doubleValue];
    }
    else {
        return defaultValue;
    }
}

- (BOOL)boolForKey:(NSString *)key defaultValue:(BOOL)defaultValue {
    id valueObject = [_configValues objectForKey:key];
    if ([valueObject isKindOfClass:[NSNumber class]]) {
        return [valueObject boolValue];
    }
    else {
        return defaultValue;
    }
}
@end
