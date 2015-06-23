//
//  NSImage+Rotate.m
//  EarthSurfer
//
//   Copyright 2009 Google Inc.
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.

#import "NSImage+Rotate.h"

@implementation NSImage(Rotated)
- (NSImage *)imageRotated:(float)degrees {
  if (0 != fmod(degrees,90.)) { NSLog( @"This code has only been tested for multiples of 90 degrees. (TODO: test and remove this line)"); }
  degrees = fmod(degrees, 360.);
  if (0 == degrees) {
    return self;
  }
  NSSize size = [self size];
  NSSize maxSize;
  if (90. == degrees || 270. == degrees || -90. == degrees || -270. == degrees) {
    maxSize = NSMakeSize(size.height, size.width);
  } else if (180. == degrees || -180. == degrees) {
    maxSize = size;
  } else {
    maxSize = NSMakeSize(20+MAX(size.width, size.height), 20+MAX(size.width, size.height));
  }
  NSAffineTransform *rot = [NSAffineTransform transform];
  [rot rotateByDegrees:degrees];
  NSAffineTransform *center = [NSAffineTransform transform];
  [center translateXBy:maxSize.width / 2. yBy:maxSize.height / 2.];
  [rot appendTransform:center];
  NSImage *image = [[NSImage alloc] initWithSize:maxSize];
  [image lockFocus];
  [rot concat];
  NSRect rect = NSMakeRect(0, 0, size.width, size.height);
  NSPoint corner = NSMakePoint(-size.width / 2., -size.height / 2.);
  [self drawAtPoint:corner fromRect:rect operation:NSCompositeCopy fraction:1.0];
  [image unlockFocus];
  return image;
}

@end

@implementation NSImageView(Rotated)

- (void)setImageAndFrame:(NSImage *)image {
  NSRect frame = [self frame];
  frame.size = [image size];
  [self setFrame:frame];
  [self setImage:image];
}

@end
