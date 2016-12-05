//
//  SyncController.h
//  SyncController
//
//  Created by Rajiv Ramdhany on 16/05/2016.
//  Copyright © 2016 BBC RD. All rights reserved.
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

//! Project version number for SyncController.
FOUNDATION_EXPORT double SyncControllerVersionNumber;

//! Project version string for SyncController.
FOUNDATION_EXPORT const unsigned char SyncControllerVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <SyncController/PublicHeader.h>


#import <SyncController/SyncControllerError.h>
#import <SyncController/VideoPlayerSyncController.h>
#import <SyncController/AudioSyncController.h>
#import <SyncController/WebViewSyncController.h>
#import <SyncController/InvocationProcessor.h>
#import <SyncController/WebViewProxy.h>
#import <SyncController/SyncControllerDelegate.h>