//
//  ViewController.m
//  TextAttachmentTest
//
//  Created by Petrus Pietila on 04/07/16.
//  Copyright © 2016 Petrus Pietila. All rights reserved.
//

#import "ViewController.h"



@interface TextAttachmentProxy : NSObject <NSAccessibilityImage>

@property (weak) NSWindow *window;
@property (assign) NSRect frame;
@property (unsafe_unretained) id parent;

@end

@implementation TextAttachmentProxy

- (void)dealloc
{
    NSAccessibilityPostNotification(self, NSAccessibilityUIElementDestroyedNotification);
}

-(id)accessibilityParent
{
    return self.parent;
}

-(NSRect)accessibilityFrame
{
    return self.frame;
}

- (NSString *)accessibilityRole
{
    return NSAccessibilityImageRole;
}

- (NSString *)accessibilitySubrole
{
    return NSAccessibilityTextAttachmentSubrole;
}

- (NSString *)accessibilityRoleDescription
{
    return NSAccessibilityRoleDescription(self.accessibilityRole, self.accessibilitySubrole);
}

- (BOOL)accessibilityIsIgnored
{
    return NO;
}

- (NSString *)accessibilityLabel
{
    return @"test label";
}

@end




@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"square" withExtension:@"png"];
    NSFileWrapper *wrapper = [[NSFileWrapper alloc] initWithURL:URL options:NSFileWrapperReadingImmediate error:NULL];
    NSTextAttachment *attachment = [[NSTextAttachment alloc] initWithFileWrapper:wrapper];
    NSMutableAttributedString *contents = [[[NSAttributedString alloc] initWithString:@"Oh babe, meet me in Tompkins "] mutableCopy];
    [contents appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
    [contents appendAttributedString:[[NSAttributedString alloc] initWithString:@" Park"]];
    
    [self.textView.textStorage setAttributedString:contents];
}

@end


@implementation AccessibleTextView

- (id)accessibilityAttributeValue:(NSString *)attribute forParameter:(id)parameter
{
    if ([attribute isEqualToString:NSAccessibilityAttributedStringForRangeParameterizedAttribute])
    {
        NSRange stringRange = [(NSValue *)parameter rangeValue];

        NSMutableAttributedString *outAttString = [super accessibilityAttributeValue:attribute forParameter:parameter];
        NSAttributedString *selfAttString = [self attributedString];

        // Must use the full string, not the substring, because proxies are stored by their range value
        [selfAttString enumerateAttribute:NSAttachmentAttributeName
                                  inRange:[parameter rangeValue]
                                  options:0
                               usingBlock:^(id value, NSRange linkRange, BOOL *stop) {
                                   if (value != nil)
                                   {
                                       TextAttachmentProxy *proxy = [[TextAttachmentProxy alloc] init];
                                       proxy.window = self.window;
                                       proxy.parent = self;

                                       proxy.frame = [self.layoutManager lineFragmentUsedRectForGlyphAtIndex:linkRange.location effectiveRange:NULL withoutAdditionalLayout:NO];

                                       if (proxy)
                                       {
                                           [outAttString removeAttribute:NSAccessibilityAttachmentTextAttribute range:stringRange];
                                           [outAttString addAttribute:NSAccessibilityAttachmentTextAttribute value:proxy range:stringRange];
                                       }
                                   }
                               }];
        return [[NSAttributedString alloc] initWithAttributedString:outAttString];
    }
    
    return [super accessibilityAttributeValue:attribute forParameter:parameter];
}

@end
