//
//  WebViewProxy
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
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "InvocationProcessor.h"


//------------------------------------------------------------------------------
#pragma mark - WebViewProxy Class declaration
//------------------------------------------------------------------------------

/**
 *  @brief A class that intercepts and redirects calls from JS code running in a UIWebView
 *  to an object that will evaluate whether the call is a web page loading call or
 *  an invocation for a method in the native environment.
 *  The proxy object also allows calling a JS method in the web view from the native side.
 */
@interface WebViewProxy : NSObject <UIWebViewDelegate>

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

/**
 *  A UIWebView instance
 */
@property UIWebView* webView;

//------------------------------------------------------------------------------
#pragma mark - Initialisers
//------------------------------------------------------------------------------

/**
 *  Initialise a WebViewProxy object with a webview and a handler for invocation
 *  requests
 *
 *  @param webView   a UIWebView instance
 *  @param invocator an object that implements the InvocationProcessor. This object
 *  will handle the invocation requests coming from the web view and call the 
 *  appropriate method on the native side.
 *
 *  @return a WebViewProxy instance.
 */
- (id)initWithWebView:(UIWebView*) webView withInvocationHandler:(id<InvocationProcessor>) invocator;



//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

/**
 *  Loads page from a given folder. Supports only simple file and folder names. Does not support name with folder path. Valid usage - loadPage:@"index.html" fromFolder:@"www"
 *
 *  @param pageName   file name
 *  @param folderName folder name
 */
- (void) loadPage:(NSString*) pageName fromFolder:(NSString*) folderName;

//------------------------------------------------------------------------------

/**
 *  Loads web page pointed to by URL in the UIWebView instance it holds a reference to.
 *
 *  @param url a URL string.
 */

- (void) loadUrl:(NSString*) url;

//------------------------------------------------------------------------------

/**
 *  create an NSError object.
 *
 *  @param error error object
 *  @param code  error code
 *  @param msg   error message
 */
- (void) createError:(NSError**) error withCode:(int) code withMessage:(NSString*) msg;

//------------------------------------------------------------------------------

/**
 *  Call a JS function on the webpage in the UIWebView instance.
 *
 *  @param name JS function name
 *  @param args a dictionary of argument name-value pairs.
 */
- (void) callJSFunction:(NSString *) name withArgs:(NSDictionary *) args;

//------------------------------------------------------------------------------
@end

