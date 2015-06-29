#import <Cocoa/Cocoa.h>

@protocol MMSliderDelegate;

@interface MMSlider : NSControl

@property (nonatomic, assign) double duration;
@property (nonatomic, assign) double currentTime;
@property (nonatomic, assign) double loadedLength;

@property (nonatomic, unsafe_unretained) id<MMSliderDelegate> delegate;
@property (nonatomic, assign) BOOL isHorizontalHigh;
@property (nonatomic, assign) BOOL isVertical;
@property (nonatomic, assign) BOOL isDragging;

@end


@protocol MMSliderDelegate <NSObject>

- (void)sliderDidBeginDragging:(BOOL)forward slider:(MMSlider *)slider;
- (void)sliderDidEndDragging:(MMSlider*)slider;

@end
