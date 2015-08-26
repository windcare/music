#import "NSImage+MMAddition.h"


#define kDiscBlur @"CIDiscBlur"
#define kRadius   @15.0f


@implementation NSImage (MMAddition)

- (CGImageRef)CGImage {
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    CGImageRef cgImage = [self CGImageForProposedRect:NULL
                                              context:context
                                                hints:NULL];
    return (__bridge CGImageRef)(__bridge id)cgImage;
}

- (void)createBlurredCGImage:(void (^)(CGImageRef cgImage))completion {
    dispatch_async(dispatch_queue_create("com.MyMusic.music.render", NULL), ^{
        CIContext *myCIContext = [CIContext contextWithCGContext:[[NSGraphicsContext currentContext] graphicsPort]
                                                         options: nil];

        CIImage *image = [CIImage imageWithCGImage:self.CGImage];
        CIFilter *filter = [CIFilter filterWithName:kDiscBlur];
        [filter setDefaults];
        [filter setValue:image forKey:kCIInputImageKey];
        [filter setValue:kRadius forKey:kCIInputRadiusKey];
        CIImage *result = [filter valueForKey:kCIOutputImageKey];
        CGImageRef cgImage = [myCIContext createCGImage:result fromRect:[image extent]];

        dispatch_sync(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(cgImage);
            }
            CFRelease(cgImage);
        });
    });
}

@end
