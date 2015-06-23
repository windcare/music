#import "MMSlider.h"
#import "NSImage+RBLResizableImageAdditions.h"
#import "RBLResizableImage.h"


#define kHorizontalKnobWidth   14
#define kVerticalKnobWidth     14

#define kImageVerticalInsets   4
#define kImageHorizontalInsets 4

#define kTrackHorizontalHeight 2
#define kTrackVerticalWidth    7

#define kSliderWidth  NSWidth(self.bounds)
#define kSliderHeight NSHeight(self.bounds)


@interface MMSlider () {
  RBLResizableImage *trackImage;
  RBLResizableImage *playedTrackImage;
  RBLResizableImage *loadedTrackImage;
  NSImage *knobImage;
  NSImage *knobDownImage;
  
  CGRect knobFrame;
  CGRect trackFrame;
  CGRect playedTrackFrame;
  CGRect loadedTrackFrame;
}

@property (nonatomic, strong) NSImage *currentKnobImage;
@property (nonatomic, assign) double dragTime;

@end


@implementation MMSlider

#pragma mark - Designated Initializer

- (id)initWithFrame:(NSRect)frameRect {
  if (self = [super initWithFrame:frameRect]) {
    NSActionCell *cell = [[NSActionCell alloc] init];
    [self setCell:cell];
    [self drawComponents];
  }
  
  return self;
}

#pragma mark - Override NSView Methods

- (void)resizeWithOldSuperviewSize:(NSSize)oldSize {
  [super resizeWithOldSuperviewSize:oldSize];
  
  trackFrame = NSMakeRect(0,
                          (NSHeight(self.bounds) - kTrackHorizontalHeight)/2,
                          NSWidth(self.bounds),
                          kTrackHorizontalHeight);
  
  [self syncLoaded];
}


#pragma mark - Setter

- (void) setIsVertical:(BOOL)isVertical {
  _isVertical = isVertical;
  
  [self drawComponents];
}


- (void)setIsHorizontalHigh:(BOOL)isHorizontalHigh {
  _isHorizontalHigh = isHorizontalHigh;
  
  [self drawHorizontally];
}


- (void)setCurrentTime:(double)currentTime {
  _currentTime = currentTime;
  [self syncSubviews];
}


- (void)setLoadedLength:(double)loadedLength {
  _loadedLength = loadedLength;
  [self syncLoaded];
}


#pragma mark - Override NSControl Methods

- (void)mouseDown:(NSEvent *)theEvent {
  if (self.isEnabled) {
    self.isDragging = YES;
    
    self.currentKnobImage = knobDownImage;
    
    double clickTime = [self timeAtClickPoint:theEvent.locationInWindow];
    self.currentTime = clickTime;
    self.dragTime = clickTime;
    
    [NSApp sendAction:self.action to:self.target from:self];
  }
}


- (void)mouseDragged:(NSEvent *)theEvent {
  if (self.isEnabled) {
    self.isDragging = YES;
    
    self.currentKnobImage = knobDownImage;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(sliderDidBeginDragging:)]) {
      double clickTime = [self timeAtClickPoint:theEvent.locationInWindow];
      BOOL forward = (clickTime >= self.dragTime);
      [self.delegate sliderDidBeginDragging:forward];
    }
    
    [self mouseDown:theEvent];
  }
}


- (void)mouseUp:(NSEvent *)theEvent {
  if (self.isEnabled) {
    self.currentKnobImage = knobImage;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(sliderDidEndDragging)]) {
      [self.delegate sliderDidEndDragging];
    }
    
    [self performSelector:@selector(setEndDragging) withObject:nil afterDelay:0.25];
  }
}


- (void)setEndDragging {
  self.isDragging = NO;
}


- (double)timeAtClickPoint:(NSPoint)point {
  double clickTime = 0;
  
  if (self.duration > 0) {
    NSPoint clickPoint = [self convertPoint:point fromView:nil];
    
    if (self.isVertical) {
      double clickLocation = clickPoint.y;
      clickTime = clickLocation / (kSliderHeight - kVerticalKnobWidth) * self.duration;
    } else {
      double clickLocation = clickPoint.x;
      clickTime = clickLocation / (kSliderWidth - kHorizontalKnobWidth) * self.duration;
    }
    
    if (clickTime >= self.duration) {
      clickTime = self.duration - (self.isVertical ? 0.0 : 1.0);
    }
    if (clickTime < 0.0) {
      clickTime = 0.0;
    }
  }
  
  return clickTime;
}


#pragma mark - Helper Methods

- (void)drawRect:(NSRect)dirtyRect {
  [trackImage drawInRect:trackFrame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
  
  if (!self.isVertical) {
    [loadedTrackImage drawInRect:loadedTrackFrame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
  }
  
  [playedTrackImage drawInRect:playedTrackFrame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
  [self.currentKnobImage drawInRect:knobFrame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}


- (void)drawComponents {
  if (self.isVertical) {
    [self drawVertically];
  } else {
    [self drawHorizontally];
  }
}


- (void)drawVertically {
  
  NSEdgeInsets insets = NSEdgeInsetsMake(
                                         kImageVerticalInsets,
                                         0,
                                         kImageVerticalInsets,
                                         0);
  
  trackImage       = [[NSImage imageNamed:@"playing_slider_bg"] rbl_resizableImageWithCapInsets:insets];
  playedTrackImage = [[NSImage imageNamed:@"player_slider_playback_left"] rbl_resizableImageWithCapInsets:insets];
  knobImage        = [NSImage imageNamed:@"player_slider_playback_thumb"];
  knobDownImage    = [NSImage imageNamed:@"player_slider_playback_thumb"];
  
  trackFrame = NSMakeRect((NSWidth(self.bounds) - kTrackVerticalWidth)/2,
                          0,
                          kTrackVerticalWidth,
                          NSHeight(self.bounds));
  
  playedTrackFrame = NSMakeRect((NSWidth(self.bounds) - kTrackVerticalWidth)/2,
                                0,
                                kTrackVerticalWidth,
                                0);
  
  knobFrame = NSMakeRect((NSWidth(self.bounds) - kHorizontalKnobWidth)/2,
                         0,
                         kHorizontalKnobWidth,
                         kHorizontalKnobWidth);
  
  self.currentKnobImage = knobImage;
}


- (void)drawHorizontally {
  
  NSEdgeInsets insets = NSEdgeInsetsMake(
                                         0,
                                         kImageHorizontalInsets,
                                         0,
                                         kImageHorizontalInsets);
  
  trackImage       = [[NSImage imageNamed:@"playing_slider_bg"] rbl_resizableImageWithCapInsets:insets];
  playedTrackImage = [[NSImage imageNamed:@"player_slider_playback_left"] rbl_resizableImageWithCapInsets:insets];
  knobImage        = [NSImage imageNamed:@"player_slider_playback_thumb"];
  knobDownImage    = [NSImage imageNamed:@"player_slider_playback_thumb"];
  
  trackFrame = NSMakeRect(0,
                          (NSHeight(self.bounds) - kTrackHorizontalHeight)/2,
                          NSWidth(self.bounds),
                          kTrackHorizontalHeight);
  
  NSRect backgroundTrackFrame = NSMakeRect(0,
                                           (NSHeight(self.bounds) - kTrackHorizontalHeight)/2,
                                           1,
                                           kTrackHorizontalHeight);
  
  loadedTrackFrame = backgroundTrackFrame;
  playedTrackFrame = backgroundTrackFrame;
  
  knobFrame = NSMakeRect(0,
                         (NSHeight(self.bounds) - kHorizontalKnobWidth)/2,
                         kHorizontalKnobWidth,
                         kHorizontalKnobWidth);
  
  self.currentKnobImage = knobImage;
}


- (void)syncSubviews {
  
  double knobPosition = 0;
  
  if (!self.isVertical && self.duration > 0) {
    knobPosition = (kSliderWidth - kHorizontalKnobWidth) * (_currentTime / self.duration);
  }
  
  if (self.isVertical) {
    knobPosition = (kSliderHeight - kVerticalKnobWidth) * (_currentTime / self.duration);
  }
  
  NSRect newKnobFrame = knobFrame;
  if (self.isVertical) {
    newKnobFrame.origin.y = knobPosition;
  } else {
    newKnobFrame.origin.x = knobPosition;
  }
  knobFrame = newKnobFrame;
  
  NSRect newPlayedTrackFrame = playedTrackFrame;
  if (self.isVertical) {
    newPlayedTrackFrame.size.height = knobPosition + kVerticalKnobWidth/2;
  } else {
    newPlayedTrackFrame.size.width = knobPosition + kHorizontalKnobWidth/2;
  }
  playedTrackFrame = newPlayedTrackFrame;
  
  [self setNeedsDisplayInRect:self.bounds];
}


- (void)syncLoaded {
  
  double loadedWidth = 0;
  
  if (self.duration > 0) {
    loadedWidth = kSliderWidth * (_loadedLength / self.duration);
  }
  
  NSRect newLoadedFrame = loadedTrackFrame;
  newLoadedFrame.size.width = MAX(loadedWidth, 1);
  loadedTrackFrame = newLoadedFrame;
  
  [self setNeedsDisplayInRect:self.bounds];
}


@end