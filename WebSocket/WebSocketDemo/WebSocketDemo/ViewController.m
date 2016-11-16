//
//  ViewController.m
//  WebSocketDemo
//
//  Created by Rajiv Ramdhany on 07/10/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.
//

#import "ViewController.h"
#import "utils.h"

@interface ViewController ()

@end

@implementation ViewController
{
    SRWebSocket *webSocket;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)connectClicked:(id)sender {
    
    [self connectWebSocket];
    
    
    
}

#pragma mark - Connection

- (void)connectWebSocket {
    webSocket.delegate = nil;
    webSocket = nil;
    
    NSString *urlString = @"ws://192.168.1.104:7681";
    SRWebSocket *newWebSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:urlString]];
    newWebSocket.delegate = self;
    
    [newWebSocket open];
}


#pragma mark - SRWebSocket delegate

- (void)webSocketDidOpen:(SRWebSocket *)newWebSocket {
    webSocket = newWebSocket;
    //[webSocket send:[NSString stringWithFormat:@"Hello from %@", [UIDevice currentDevice].name]];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    assert(error != nil);
    NSLog(@"received error: %@", DisplayErrorFromError(error));
    //[self connectWebSocket];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
     NSLog(@"websocket closed with code: %ld, reason: %@", (long)code, reason);
    //[self connectWebSocket];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
//    self.messagesTextView.text = [NSString stringWithFormat:@"%@\n%@", self.messagesTextView.text, message];
    
    NSLog(@"Message received: %@", message);
}


@end
