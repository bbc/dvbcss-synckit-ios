//
//  WebViewInterface.h
//
//  Created by Rajiv Ramdhany on 10/03/2015.
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

#import <Foundation/Foundation.h>

//------------------------------------------------------------------------------
#pragma mark - WebViewInterface
//------------------------------------------------------------------------------

/**
 *  An interface with methods to process invocation requests coming from a UIWebView
 */
@protocol InvocationProcessor <NSObject>

//------------------------------------------------------------------------------

/**
 *  Processes an invocation coming from the ios_sync.js JS library. The library must be 
 *  in the webpage.
 *
 *  @param name  name of function to invoke
 *  @param args  list of parameters to pass to function
 *  @param error error object reported by invocation
 *
 *  @return a return value of the invocation.
 */
- (id) processFunctionFromJS:(NSString *) name withArgs:(NSArray*) args error:(NSError **) error;

//------------------------------------------------------------------------------

@end
