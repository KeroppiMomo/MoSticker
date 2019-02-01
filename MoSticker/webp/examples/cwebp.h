//
//  cwebp.h
//  webp Testing
//
//  Created by Moses Mok on 5/1/2019.
//  Copyright © 2019 Moses Mok. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef HAVE_CONFIG_H
#include "../src/webp/config.h"
#endif

#include "../examples/example_util.h"
#include "../imageio/image_dec.h"
#include "../imageio/imageio_util.h"
#include "./stopwatch.h"
#include "./unicode.h"
#include "../src/webp/encode.h"

int cwebp_main(int argc, const char *argv[]);
