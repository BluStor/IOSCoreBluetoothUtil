#import <Foundation/Foundation.h>
#import "PDBluetoothLE.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        PDBluetoothLE *podoLE = [[PDBluetoothLE alloc] init];

        [podoLE startBluetoothLE];
     
        [[NSRunLoop currentRunLoop] run];
    }
    return 0;
}
