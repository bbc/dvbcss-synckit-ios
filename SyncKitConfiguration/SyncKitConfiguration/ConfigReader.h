//
//  ConfigReader.h
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

#import <Foundation/Foundation.h>

/**
 *  Interface to the values stored in the Config.plist resource file
 */
@interface ConfigReader : NSObject

/**
*   Return singleton instance
*
*  @return ConfigReader singleton
*/
+ (ConfigReader *)getInstance;



+ (ConfigReader *)getInstanceWithConfigFile:(NSString*) filepath;

/**
 *  Return string value with specified key from Config.plist, or default value if not specified in the file
 *
 *  @param key          specified key from Config.plist
 *  @param defaultValue default value if not specified in the file
 *
 *  @return  string value for specified key
 */
- (NSString *)stringForKey:(NSString *)key defaultValue:(NSString *)defaultValue;

/**
 *  Return integer value with specified key from Config.plist, or default value if not specified in the file
 *
 *  @param key          specified key from Config.plist
 *  @param defaultValue default value if not specified in the file
 *
 *  @return  integer value for specified key
 */
- (NSInteger)integerForKey:(NSString *)key defaultValue:(NSInteger)defaultValue;


/**
 *  Return long integer value with specified key from Config.plist, or default value if not specified in the file
 *
 *  @param key          specified key from Config.plist
 *  @param defaultValue default value if not specified in the file
 *
 *  @return  long integer value for specified key
 */
- (NSInteger)LongIntegerForKey:(NSString *)key defaultValue:(NSInteger)defaultValue;

/**
 *  Return unsigned integer value with specified key from Config.plist, or default value if not specified in the file
 *
 *  @param key          specified key from Config.plist
 *  @param defaultValue default value if not specified in the file
 *
 *  @return  unsigned integer value for specified key
 */
- (unsigned int) unsignedIntegerForKey:(NSString *)key defaultValue:(unsigned int)defaultValue;

/**
 *  Return unsigned long integer value with specified key from Config.plist, or default value if not specified in the file
 *
 *  @param key          specified key from Config.plist
 *  @param defaultValue default value if not specified in the file
 *
 *  @return  unsigned long integer value for specified key
 */
- (unsigned long) unsignedLongIntegerForKey:(NSString *)key defaultValue:(unsigned long)defaultValue;

/**
 *  Return floating-point value with specified key from Config.plist, or default value if not specified in the file
 *
 *  @param key          specified key from Config.plist
 *  @param defaultValue default value if not specified in the file
 *
 *  @return  floating-point value for specified key
 */
- (double)doubleForKey:(NSString *)key defaultValue:(double)defaultValue;

/**
 *  Return boolean value with specified key from Config.plist, or default value if not specified in the file
 *
 *  @param key          specified key from Config.plist
 *  @param defaultValue default value if not specified in the file
 *
 *  @return  fboolean value for specified key
 */
- (BOOL)boolForKey:(NSString *)key defaultValue:(BOOL)defaultValue;

@end
