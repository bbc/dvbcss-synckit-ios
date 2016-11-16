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

// We need all the log functions visible so we set this to DEBUG
#ifdef MW_COMPILE_TIME_LOG_LEVEL
#undef MW_COMPILE_TIME_LOG_LEVEL
#define MW_COMPILE_TIME_LOG_LEVEL ASL_LEVEL_DEBUG
#endif

#define MW_COMPILE_TIME_LOG_LEVEL ASL_LEVEL_DEBUG

#import "MWLogging.h"
#import <asl.h>

static void AddStderrOnce()
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		asl_add_log_file(NULL, STDERR_FILENO);
	});
}

#define __MW_MAKE_LOG_FUNCTION(LEVEL, NAME) \
void NAME (NSString *format, ...) \
{ \
	AddStderrOnce(); \
	va_list args; \
	va_start(args, format); \
	NSString *message = [[NSString alloc] initWithFormat:format arguments:args]; \
	asl_log(NULL, NULL, (LEVEL), "%s", [message UTF8String]); \
    message = nil; \
	va_end(args); \
}

__MW_MAKE_LOG_FUNCTION(ASL_LEVEL_EMERG, MWLogEmergency)
__MW_MAKE_LOG_FUNCTION(ASL_LEVEL_ALERT, MWLogAlert)
__MW_MAKE_LOG_FUNCTION(ASL_LEVEL_CRIT, MWLogCritical)
__MW_MAKE_LOG_FUNCTION(ASL_LEVEL_ERR, MWLogError)
__MW_MAKE_LOG_FUNCTION(ASL_LEVEL_WARNING, MWLogWarning)
__MW_MAKE_LOG_FUNCTION(ASL_LEVEL_NOTICE, MWLogNotice)
__MW_MAKE_LOG_FUNCTION(ASL_LEVEL_INFO, MWLogInfo)
__MW_MAKE_LOG_FUNCTION(ASL_LEVEL_DEBUG, MWLogDebug)

#undef __MW_MAKE_LOG_FUNCTION
