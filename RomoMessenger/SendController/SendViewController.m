//
//  MainViewController.m
//  RomoMessenger
//
//  Created by Yuanfeng on 2013-05-22.
//  Copyright (c) 2013 University of Waterloo. All rights reserved.
//



#import "NetworkManager.h"
#import "QNetworkAdditions.h"

#import "SendViewController.h"
enum {
    kSendBufferSize = 32768
};


@interface SendViewController () <NSStreamDelegate>


// stuff for IB

@property (nonatomic, strong, readwrite) IBOutlet UILabel *                   statusLabel;
@property (nonatomic, strong, readwrite) IBOutlet UIActivityIndicatorView *   activityIndicator;
//changed to send button
@property (nonatomic, strong, readwrite) IBOutlet UIButton *cancelButton;

@property (nonatomic, strong, readwrite) IBOutlet UITextView *textView;
@property (nonatomic,strong, readwrite) IBOutlet UILabel *messageSent;
@property (nonatomic,strong, readwrite) IBOutlet UIView *accessoryView;

@property (weak, nonatomic) IBOutlet UIImageView *EmotionPreview;



- (IBAction)cancelAction:(id)sender; 
- (IBAction)clearButtonClicked:(id)sender;
- (IBAction)viewEmotion:(id)sender;

// private properties

@property (nonatomic, assign, readonly ) BOOL               isSending;
@property (nonatomic, strong, readwrite) NSOutputStream *   networkStream;
@property (nonatomic, strong, readwrite) NSInputStream *    fileStream;
@property (nonatomic, assign, readonly ) uint8_t *          buffer;
@property (nonatomic, assign, readwrite) size_t             bufferOffset;
@property (nonatomic, assign, readwrite) size_t             bufferLimit;
@property (nonatomic, assign) BOOL          EmotionButtonStatus;





@end

@implementation SendViewController
{
    uint8_t                     _buffer[kSendBufferSize];
}

@synthesize networkStream = _networkStream;
@synthesize fileStream    = _fileStream;
@synthesize bufferOffset  = _bufferOffset;
@synthesize bufferLimit   = _bufferLimit;

@synthesize statusLabel       = _statusLabel;
@synthesize activityIndicator = _activityIndicator;
@synthesize cancelButton      = _stopButton;


@synthesize textView;
@synthesize accessoryView;


#pragma mark * Status management


// These methods are used by the core transfer code to update the UI.

- (void)sendDidStart
{
    self.statusLabel.text = @"Sending";
    self.cancelButton.enabled = YES;
    [self.activityIndicator startAnimating];
    [[NetworkManager sharedInstance] didStartNetworkOperation];
}

- (void)updateStatus:(NSString *)statusString
{
    assert(statusString != nil);
    self.statusLabel.text = statusString;
}

- (void)sendDidStopWithStatus:(NSString *)statusString
{
    if (statusString == nil) {
        statusString = @"Send succeeded";
    }
    self.statusLabel.text = statusString;
    self.cancelButton.enabled = YES;
    [self.activityIndicator stopAnimating];
    [[NetworkManager sharedInstance] didStopNetworkOperation];
}

#pragma mark * Core transfer code

// This is the code that actually does the networking.

// Because buffer is declared as an array, you have to use a custom getter.
// A synthesised getter doesn't compile.

- (uint8_t *)buffer
{
    return self->_buffer;
}

- (BOOL)isSending
{
    return (self.networkStream != nil);
}

- (void)startSend:(NSString *)text
{
    NSOutputStream *    output;
    BOOL                success;
    NSNetService *      netService;
    
    
    assert(self.networkStream == nil);      // don't tap send twice in a row!
    assert(self.fileStream == nil);         // ditto
    
    // Open a stream for the file we're going to send.
    
    self.fileStream = [[NSInputStream alloc] initWithData:[text dataUsingEncoding:NSUTF8StringEncoding]];
    assert(self.fileStream != nil);
    
    [self.fileStream open];
    
    // Open a stream to the server, finding the server via Bonjour.  Then configure
    // the stream for async operation.
    
    netService = [[NSNetService alloc] initWithDomain:@"local." type:@"_x-SNSUpload._tcp." name:@"Test"];
    assert(netService != nil);
    
    // Until <rdar://problem/6868813> is fixed, we have to use our own code to open the streams
    // rather than call -[NSNetService getInputStream:outputStream:].  See the comments in
    // QNetworkAdditions.m for the details.
    
    success = [netService qNetworkAdditions_getInputStream:NULL outputStream:&output];
    assert(success);
    
    self.networkStream = output;
    self.networkStream.delegate = self;
    [self.networkStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [self.networkStream open];
    
    // Tell the UI we're sending.
    
    [self sendDidStart];
}

- (void)stopSendWithStatus:(NSString *)statusString
{
    if (self.networkStream != nil) {
        self.networkStream.delegate = nil;
        [self.networkStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.networkStream close];
        self.networkStream = nil;
    }
    if (self.fileStream != nil) {
        [self.fileStream close];
        self.fileStream = nil;
    }
    self.bufferOffset = 0;
    self.bufferLimit  = 0;
    [self sendDidStopWithStatus:statusString];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
// An NSStream delegate callback that's called when events happen on our
// network stream.
{
    assert(aStream == self.networkStream);
    
#pragma unused(aStream)
    
    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
            [self updateStatus:@"Opened connection"];
        } break;
        case NSStreamEventHasBytesAvailable: {
            assert(NO);     // should never happen for the output stream
        } break;
        case NSStreamEventHasSpaceAvailable: {
            [self updateStatus:@"Sending"];
            
            // If we don't have any data buffered, go read the next chunk of data.
            
            if (self.bufferOffset == self.bufferLimit) {
                NSInteger   bytesRead;
                
                bytesRead = [self.fileStream read:self.buffer maxLength:kSendBufferSize];
                
                if (bytesRead == -1) {
                    [self stopSendWithStatus:@"File read error"];
                } else if (bytesRead == 0) {
                    [self stopSendWithStatus:nil];
                } else {
                    self.bufferOffset = 0;
                    self.bufferLimit  = bytesRead;
                }
            }
            
            // If we're not out of data completely, send the next chunk.
            
            if (self.bufferOffset != self.bufferLimit) {
                NSInteger   bytesWritten;
                
                bytesWritten = [self.networkStream write:&self.buffer[self.bufferOffset] maxLength:self.bufferLimit - self.bufferOffset];
                assert(bytesWritten != 0);
                if (bytesWritten == -1) {
                    [self stopSendWithStatus:@"Network write error"];
                } else {
                    self.bufferOffset += bytesWritten;
                }
            }
        } break;
        case NSStreamEventErrorOccurred: {
            [self stopSendWithStatus:@"Stream open error"];
        } break;
        case NSStreamEventEndEncountered: {
            // ignore
        } break;
        default: {
            assert(NO);
        } break;
    }
}

#pragma mark * Actions


// send button
- (IBAction)cancelAction:(id)sender
{
#pragma unused(sender)
    
    [self startSend:self.textView.text];
    self.messageSent.text = self.textView.text;//only last message sent
}



- (IBAction)clearButtonClicked:(id)sender
{
    textView.text = @"";
}

#pragma mark * View controller boilerplate

- (void)viewDidLoad
{
    [super viewDidLoad];
    assert(self.statusLabel != nil);
    assert(self.activityIndicator != nil);
    assert(self.cancelButton != nil);
    
    self.activityIndicator.hidden = YES;
    self.statusLabel.text = @"Type text then press start to send";
    self.cancelButton.enabled = YES;
    [self.cancelButton setTitle:@"Send" forState:UIControlStateNormal];
    
    self.textView.inputAccessoryView = self.accessoryView;
    
    
}

- (void)viewDidUnload
{
    [self setEmotionPreview:nil];
    [super viewDidUnload];
    self.statusLabel = nil;
    self.activityIndicator = nil;
    self.cancelButton = nil;
    self.textView = nil;
    self.accessoryView = nil;

}

- (void)dealloc
{
    [self stopSendWithStatus:@"Stopped"];
}



- (IBAction)onExpressionClicked:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
       //NSString *emotionChosen = [NSString stringWithFormat:@"%@%d", @"romo://", btn.tag];
             
        //self.messageSent.text = [NSString stringWithFormat:@"%@%d", @"romo://", btn.tag];
        self.EmotionPreview.image = [UIImage imageNamed:[NSString stringWithFormat:@"R3UI-Expression-%d@2x.png",btn.tag]];
    }
}



- (IBAction)viewEmotion:(id)sender
{
    if (_EmotionButtonStatus == YES){
        _EmotionButtonStatus = NO;
        self.textView.inputView = self.inputView;
        [self.textView reloadInputViews];
    }else{
        self.textView.inputView = _expressionKeyboard;
        [self.textView reloadInputViews];
        _EmotionButtonStatus = YES;
    }
    
}

- (IBAction)doneButton:(id)sender {
    [textView resignFirstResponder];
}




//four drive actions with tag integer 1 for up, 2 for left, 3 for right, 4 for down
//touch down
-(IBAction)directionControl:(id)sender{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        [self startSend:[NSString stringWithFormat:@"%@%d", @"driveAction", btn.tag]];
    }
}

-(IBAction)driveControlCancelled:(id)sender
{
    //touch up inside
    [self startSend:@"stopAction"];
}


#pragma mark - Flipside View

- (void)sendSettingsViewControllerDidFinish:(SendSettingsViewController *)controller
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)showSettings:(id)sender
{    
    SendSettingsViewController *controller = [[SendSettingsViewController alloc] initWithNibName:nil bundle:nil];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:controller animated:YES completion:nil];
}

@end
