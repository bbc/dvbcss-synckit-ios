//
//  ViewController.m
//  UDPClientDemo
//
//  Created by Rajiv Ramdhany on 03/06/2015.
//  Copyright (c) 2015 BBC RD. All rights reserved.
//

#import "ViewController.h"
#import <AsyncSocket/AsyncSocket.h>

// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

#define FORMAT(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]
@interface ViewController ()
{
    
    long tag;
    GCDAsyncUdpSocket *udpSocket;
    
    NSMutableString *log;
}


- (IBAction)sendClicked:(id)sender;

@end

@implementation ViewController

- (void)setupSocket
{
    // Setup our socket.
    // The socket will invoke our delegate methods using the usual delegate paradigm.
    // However, it will invoke the delegate methods on a specified GCD delegate dispatch queue.
    //
    // Now we can configure the delegate dispatch queues however we want.
    // We could simply use the main dispatc queue, so the delegate methods are invoked on the main thread.
    // Or we could use a dedicated dispatch queue, which could be helpful if we were doing a lot of processing.
    //
    // The best approach for your application will depend upon convenience, requirements and performance.
    //
    // For this simple example, we're just going to use the main thread.
    
    udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *error = nil;
    
    if (![udpSocket bindToPort:0 error:&error])
    {
        [self logError:FORMAT(@"Error binding: %@", error)];
        return;
    }
    if (![udpSocket beginReceiving:&error])
    {
        [self logError:FORMAT(@"Error receiving: %@", error)];
        return;
    }
    
    [self logInfo:@"Ready"];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    log = [[NSMutableString alloc] init];
    if (udpSocket == nil)
    {
        [self setupSocket];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)getKeyboardHeight:(float *)keyboardHeightPtr
        animationDuration:(double *)animationDurationPtr
                     from:(NSNotification *)notification
{
    float keyboardHeight;
    double animationDuration;
    
    // UIKeyboardCenterBeginUserInfoKey:
    // The key for an NSValue object containing a CGRect
    // that identifies the start frame of the keyboard in screen coordinates.
    
    CGRect beginRect = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect endRect   = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        keyboardHeight = ABS(beginRect.origin.x - endRect.origin.x);
    }
    else
    {
        keyboardHeight = ABS(beginRect.origin.y - endRect.origin.y);
    }
    
    // UIKeyboardAnimationDurationUserInfoKey
    // The key for an NSValue object containing a double that identifies the duration of the animation in seconds.
    
    animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    if (keyboardHeightPtr) *keyboardHeightPtr = keyboardHeight;
    if (animationDurationPtr) *animationDurationPtr = animationDuration;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    float keyboardHeight = 0.0F;
    double animationDuration = 0.0;
    
    [self getKeyboardHeight:&keyboardHeight animationDuration:&animationDuration from:notification];
    
    CGRect webViewFrame = _webView.frame;
    webViewFrame.size.height -= keyboardHeight;
    
    void (^animationBlock)(void) = ^{
        
        _webView.frame = webViewFrame;
    };
    
    UIViewAnimationOptions options = 0;
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:options
                     animations:animationBlock
                     completion:NULL];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    float keyboardHeight = 0.0F;
    double animationDuration = 0.0;
    
    [self getKeyboardHeight:&keyboardHeight animationDuration:&animationDuration from:notification];
    
    CGRect webViewFrame = _webView.frame;
    webViewFrame.size.height += keyboardHeight;
    
    void (^animationBlock)(void) = ^{
        
        _webView.frame = webViewFrame;
    };
    
    UIViewAnimationOptions options = 0;
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:options
                     animations:animationBlock
                     completion:NULL];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    DDLogError(@"webView:didFailLoadWithError: %@", error);
}

- (void)webViewDidFinishLoad:(UIWebView *)sender
{
    NSString *scrollToBottom = @"window.scrollTo(document.body.scrollWidth, document.body.scrollHeight);";
    
    [sender stringByEvaluatingJavaScriptFromString:scrollToBottom];
}

- (void)logError:(NSString *)msg
{
    NSString *prefix = @"<font color=\"#B40404\">";
    NSString *suffix = @"</font><br/>";
    
    [log appendFormat:@"%@%@%@\n", prefix, msg, suffix];
    
    NSString *html = [NSString stringWithFormat:@"<html><body>\n%@\n</body></html>", log];
    [_webView loadHTMLString:html baseURL:nil];
}

- (void)logInfo:(NSString *)msg
{
    NSString *prefix = @"<font color=\"#6A0888\">";
    NSString *suffix = @"</font><br/>";
    
    [log appendFormat:@"%@%@%@\n", prefix, msg, suffix];
    
    NSString *html = [NSString stringWithFormat:@"<html><body>\n%@\n</body></html>", log];
    [_webView loadHTMLString:html baseURL:nil];
}

- (void)logMessage:(NSString *)msg
{
    NSString *prefix = @"<font color=\"#000000\">";
    NSString *suffix = @"</font><br/>";
    
    [log appendFormat:@"%@%@%@\n", prefix, msg, suffix];
    
    NSString *html = [NSString stringWithFormat:@"<html><body>%@</body></html>", log];
    [_webView loadHTMLString:html baseURL:nil];
}



- (IBAction)sendClicked:(id)sender {
    NSString *host = _addrField.text;
    if ([host length] == 0)
    {
        [self logError:@"Address required"];
        return;
    }
    
    int port = [_portField.text intValue];
    if (port <= 0 || port > 65535)
    {
        [self logError:@"Valid port required"];
        return;
    }
    
    NSString *msg = _messageField.text;
    if ([msg length] == 0)
    {
        [self logError:@"Message required"];
        return;
    }
    
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    [udpSocket sendData:data toHost:host port:port withTimeout:-1 tag:tag];
    
    [self logMessage:FORMAT(@"SENT (%i): %@", (int)tag, msg)];
    
    tag++;

}



- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    // You could add checks here
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    // You could add checks here
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (msg)
    {
        [self logMessage:FORMAT(@"RECV: %@", msg)];
    }
    else
    {
        NSString *host = nil;
        uint16_t port = 0;
        [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
        
        [self logInfo:FORMAT(@"RECV: Unknown message from: %@:%hu", host, port)];
    }
}

@end
