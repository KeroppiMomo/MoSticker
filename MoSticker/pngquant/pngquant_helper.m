//
//  pngquant_helper.h
//  pngquant Testing
//
//  Created by Moses Mok on 4/1/2019.
//  Copyright © 2019 Moses Mok. All rights reserved.
//

#import "pngquant_helper.h"

void pngquant_cli(NSString* inputPath, NSString* outputPath, int speed) {
    pngquant_my_main(speed, [inputPath UTF8String], [outputPath UTF8String]);
}
