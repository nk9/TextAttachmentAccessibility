//
//  ViewController.h
//  TextAttachmentTest
//
//  Created by Petrus Pietila on 04/07/16.
//  Copyright © 2016 Petrus Pietila. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AccessibleTextView : NSTextView

@property (strong) NSMutableDictionary *attachmentProxies;

@end

@interface ViewController : NSViewController

@property (strong) IBOutlet AccessibleTextView *textView;

@end

