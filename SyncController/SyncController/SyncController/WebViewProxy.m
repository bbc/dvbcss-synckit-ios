//
//  WebViewDelegate.m
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

#import "WebViewProxy.h"



//------------------------------------------------------------------------------
#pragma mark - Interface extensions
//------------------------------------------------------------------------------

@interface WebViewProxy ()

//------------------------------------------------------------------------------
#pragma mark - Local Properties
//------------------------------------------------------------------------------

/**
 *  Invocation processor
 */
@property (nonatomic, weak) id<InvocationProcessor> invocator;


@end



//------------------------------------------------------------------------------
#pragma mark - WebViewProxy implementation
//------------------------------------------------------------------------------

@implementation WebViewProxy 


//------------------------------------------------------------------------------
#pragma mark - Initialisers
//------------------------------------------------------------------------------


- (id)initWithWebView:(UIWebView*) webView withInvocationHandler:(id<InvocationProcessor>)invocator
{
	self.webView = webView;
	
	self.webView.delegate = self;
	
	self.invocator = invocator;
	
	return self;
}
//------------------------------------------------------------------------------

- (void)dealloc
{
    NSLog(@"WebViewProxy deallocated.");
}

//------------------------------------------------------------------------------
#pragma mark - UIWebViewDelegate protocol methods
//------------------------------------------------------------------------------

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSURL *url = [request URL];
    NSString *urlStr = url.absoluteString;
    
    return [self processURL:urlStr];
    
}
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
#pragma mark - public methods
//------------------------------------------------------------------------------

- (void) loadPage:(NSString*) pageName fromFolder:(NSString*) folderName
{
	NSRange range = [pageName rangeOfString:@"."];
    if (range.length > 0)
    {
		if (folderName == nil)
			folderName = @"www";
		
    	NSString *fileExt = [pageName substringFromIndex:range.location+1];
        NSString *fileName = [pageName substringToIndex:range.location];
        
       // NSString *path = [[NSBundle mainBundle] bundlePath];
//        NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:fileExt inDirectory:@"www"];
        
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:fileName ofType:fileExt]];
				
		if (url != nil)
		{
       		NSURLRequest *req = [NSURLRequest requestWithURL:url];
            
       		[self.webView loadRequest:req];
		}
    }
}

//------------------------------------------------------------------------------

- (void) loadUrl:(NSString*) url{
    if (url != nil)
    {
        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                             cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [self.webView loadRequest:req];
    }
}

//------------------------------------------------------------------------------

-(void) callJSFunction:(NSString *) name withArgs:(NSMutableDictionary *) args
{
    NSError *jsonError;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:args options:0 error:&jsonError];
    
    if (jsonError != nil)
    {
        //call error callback function here
        NSLog(@"Error creating JSON from the response  : %@",[jsonError localizedDescription]);
        return;
    }
    
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    //NSLog(@"jsonStr = %@", jsonStr);
    
    if (jsonStr == nil)
    {
        NSLog(@"jsonStr is null. count = %lu", (unsigned long)[args count]);
    }
    
    NSString* ret = [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@('%@');",name,jsonStr]];
//    NSLog(@"function call= %@  ret = %@", [NSString stringWithFormat:@"%@('%@');",name,jsonStr],ret);
}

//------------------------------------------------------------------------------

- (void) createError:(NSError**) error withMessage:(NSString *) msg
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:msg forKey:NSLocalizedDescriptionKey];
    
    *error = [NSError errorWithDomain:@"JSiOSBridgeError" code:-1 userInfo:dict];
    
}

//------------------------------------------------------------------------------

-(void) createError:(NSError**) error withCode:(int) code withMessage:(NSString*) msg
{
    NSMutableDictionary *msgDict = [NSMutableDictionary dictionary];
    [msgDict setValue:[NSNumber numberWithInt:code] forKey:@"code"];
    [msgDict setValue:msg forKey:@"message"];
    
    NSError *jsonError;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:msgDict options:0 error:&jsonError];
    
    if (jsonError != nil)
    {
        //call error callback function here
        NSLog(@"Error creating JSON from error message  : %@",[jsonError localizedDescription]);
        return;
    }
    
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    [self createError:error withMessage:jsonStr];
}
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
#pragma mark - private methods
//------------------------------------------------------------------------------

/**
 *  handler for redirected URL request
 *
 *  @param url a URL web view requests for loading
 *
 *  @return YES if URL is a legitimate address, NO is URL is for our bridged invocation
 */
- (BOOL) processURL:(NSString *) url
{
    NSString *urlStr = [NSString stringWithString:url];
    
    NSString *protocolPrefix = @"js2ios://";
    if ([[urlStr lowercaseString] hasPrefix:protocolPrefix])
    {
        urlStr = [urlStr substringFromIndex:protocolPrefix.length];
        
        urlStr = [urlStr stringByRemovingPercentEncoding];
        
        NSError *jsonError;

        NSDictionary *callInfo = [NSJSONSerialization
                                  JSONObjectWithData:[urlStr dataUsingEncoding:NSUTF8StringEncoding]
                                  options:0
                                  error:&jsonError];
        
        if (jsonError != nil)
        {
            //call error callback function here
            NSLog(@"Error parsing JSON for the url %@",url);
            return NO;
        }
        
        
        NSString *functionName = [callInfo objectForKey:@"functionname"];
        if (functionName == nil)
        {
            NSLog(@"Missing function name");
            return NO;
        }
        
        NSString *successCallback = [callInfo objectForKey:@"success"];
        NSString *errorCallback = [callInfo objectForKey:@"error"];
        NSArray *argsArray = [callInfo objectForKey:@"args"];
        
        
        
        [self callFunction:functionName withArgs:argsArray onSuccess:successCallback onError:errorCallback];
        
        return NO; // this is a webview->native invocation, tell UIWebView to not load URL
        
    }
    
    return YES; // this is a legitimate web page loading request, allow UIWebView to proceed.
}

//------------------------------------------------------------------------------

/**
 *  Redirects function invocation request to an object which will process the request
 *
 *  @param name            function name
 *  @param args            arguments list
 *  @param successCallback callback function on successful invocation
 *  @param errorCallback   callback function on error
 */
- (void) callFunction:(NSString *) name withArgs:(NSArray *) args onSuccess:(NSString *) successCallback onError:(NSString *) errorCallback
{
    NSError *error;
    
    id retVal = [self.invocator processFunctionFromJS:name withArgs:args error:&error];
    
    if (error != nil)
    {
        NSString *resultStr = [NSString stringWithString:error.localizedDescription];
        [self callErrorCallback:errorCallback withMessage:resultStr];
        return;
    }
    
    [self callSuccessCallback:successCallback withRetValue:retVal forFunction:name];
    
}

//------------------------------------------------------------------------------

/**
 *  Reports invocation error back to web view
 *
 *  @param name name of JS function to call
 *  @param msg  String argument for JS function
 */
-(void) callErrorCallback:(NSString *) name withMessage:(NSString *) msg
{
    if (name != nil)
    {
        //call error handler
        
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(%@);",name,msg]];
        
    }
    else
    {
        NSLog(@"%@",msg);
    }
    
}

//------------------------------------------------------------------------------

/**
 *  Reports invocation result back to web view
 *
 *  @param name     name of JS function to call
 *  @param retValue returned value from invocation processing
 *  @param funcName name of function that was invoked from JS-land
 */
-(void) callSuccessCallback:(NSString *) name withRetValue:(id) retValue forFunction:(NSString *) funcName
{
    if (name != nil)
    {
        //call success handler
        
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
        [resultDict setObject:retValue forKey:@"result"];
        [self callJSFunction:name withArgs:resultDict];
    }
    else
    {
        NSLog(@"Result of function %@ = %@", funcName,retValue);
    }
    
}

//------------------------------------------------------------------------------

@end


