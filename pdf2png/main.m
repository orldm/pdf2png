//
//  main.m
//  pdf2png
//
//  Created by John Smith on 9/20/13.
//  Copyright (c) 2013 Bullet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        NSArray *arguments = [[NSProcessInfo processInfo] arguments];
        
        if ([arguments count] > 1) {
            
            NSString *filename = arguments[1];
            
            BOOL b = [[NSFileManager defaultManager] fileExistsAtPath:filename];
            
            if (!b) {
                NSLog(@"No such file");
                return 0;
            }
            
            NSData *pdfData = [NSData dataWithContentsOfFile:filename];
            NSPDFImageRep *pdfImageRep = [NSPDFImageRep imageRepWithData:pdfData];
            NSInteger pageCount = [pdfImageRep pageCount];
            float resolutionFactor;
            if ([arguments count] > 2) {
                resolutionFactor = [arguments[2] floatValue]/72.0;
            } else {
                resolutionFactor = 1.0;
            }
            for (int i=0; i<pageCount; i++) {
                pdfImageRep.currentPage = i;
                NSImage *pdfImage = [[NSImage alloc] init];
                [pdfImage addRepresentation:pdfImageRep];
                NSSize origSize = pdfImage.size;
                CGFloat width = origSize.width;
                CGFloat height = origSize.height;
                pdfImage.scalesWhenResized = YES;
                NSSize newSize;
                newSize.width = width * resolutionFactor;
                newSize.height = height * resolutionFactor;
                
                NSImage *newImage = [[NSImage alloc]initWithSize:newSize];
                [newImage lockFocus];
                [pdfImage setSize:newSize];
                [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
                [pdfImage drawAtPoint:NSZeroPoint
                             fromRect:CGRectMake(0.0, 0.0, newSize.width, newSize.height)
                            operation:NSCompositeCopy
                             fraction:1.0];
                [newImage unlockFocus];
                
                NSData *tiffRepresentation = [newImage TIFFRepresentation];
                NSBitmapImageRep *bmpImage = [NSBitmapImageRep imageRepWithData:tiffRepresentation];
                NSDictionary *properties = [NSDictionary dictionaryWithObjects:@[NSImageCompressionFactor] forKeys:@[@1.0]];
                NSData *pngData = [bmpImage representationUsingType:NSPNGFileType properties:properties];
                NSString *newFilename = [filename stringByDeletingPathExtension];
                if (pageCount > 1) newFilename = [newFilename stringByAppendingString:[NSString stringWithFormat:@"_%d",i]];
                newFilename = [newFilename stringByAppendingString:@".png"];
                [pngData writeToFile:newFilename atomically:YES];
            }
        }
    }
    return 0;
}

