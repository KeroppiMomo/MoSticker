//
//  cwebp_wrapper.m
//  webp Testing
//
//  Created by Moses Mok on 5/1/2019.
//  Copyright © 2019 Moses Mok. All rights reserved.
//


#import "cwebp_wrapper.h"

void cwebp_wrapper(NSString* inputPath, NSString* outputPath, int targetSize) {
    char* argv[7];
    argv[0] = "cwebp";
    argv[1] = [inputPath UTF8String];
    argv[2] = "-o";
    argv[3] = [outputPath UTF8String];
    argv[4] = "-size";
    argv[5] = [[NSString stringWithFormat:@"%d", targetSize] UTF8String];
    argv[6] = "-progress";
    cwebp_main(7, argv);
}
