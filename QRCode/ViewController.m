//
//  ViewController.m
//  QRCode
//
//  Created by liangxiu.chen on 16/7/22.
//  Copyright © 2016年 liangxiu.chen. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
<
AVCaptureMetadataOutputObjectsDelegate
>

@property (nonatomic, strong) AVCaptureSession *qrCodeSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *layer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"fdasf" style:UIBarButtonItemStyleDone target:self action:@selector(start)];
    self.title = @"二维码扫描";
    [self start];
}

- (BOOL)authoriseDevice
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:
        {
            __block BOOL result;
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                result = granted;
                !granted ?: NSLog(@"fadsf");
            }];
            return result;
            break;
        }
        case AVAuthorizationStatusAuthorized:
        {
            return YES;
            break;
        }
        default:
        {
            NSLog(@"fadsf");
            return NO;
            break;
        };
    }
}

- (void)start{
    if (![self authoriseDevice]) {
        return;
    }
    self.qrCodeSession = [AVCaptureSession new];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (deviceInput && error == nil) {
        [self.qrCodeSession addInput:deviceInput];
        
        AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
        [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [self.qrCodeSession addOutput:metadataOutput];
        metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
        
        self.layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.qrCodeSession];
        self.layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.layer.frame = self.view.bounds;
        [self.view.layer insertSublayer:self.layer atIndex:0];
    
        [self.qrCodeSession startRunning];
        
    }
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count == 0) {
        return;
    }
    AVMetadataObject *transformedObj = [self.layer transformedMetadataObjectForMetadataObject:metadataObjects.lastObject];
    if ([transformedObj isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
        AVMetadataMachineReadableCodeObject *machineCode = (AVMetadataMachineReadableCodeObject *)transformedObj;
        if (machineCode.type == AVMetadataObjectTypeQRCode) {
            NSLog(@"%@",NSStringFromCGRect(machineCode.bounds));
        }
    }
}

@end
