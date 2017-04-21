#import <Foundation/Foundation.h>
#import "PDBluetoothLE.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        int command;
        PDBluetoothLE *podoLE = [[PDBluetoothLE alloc] init];
        NSNumber *cmd = @3;
        [podoLE startBluetoothLE:cmd];
        [[NSRunLoop currentRunLoop] run];
        
        /*
        while(1){
            NSLog(@"Command: ");
            scanf("%d", &command);
            if(command == 0)
            {
                
            }
            [podoLE sendCommand:command];
        }
         */

    }
    return 0;
}
