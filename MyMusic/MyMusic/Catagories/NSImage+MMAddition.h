#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface NSImage (MMAddition)

- (CGImageRef)CGImage;
- (void)createBlurredCGImage:(void (^)(CGImageRef cgImage))block;

@end
