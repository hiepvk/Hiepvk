#import "Hiepvk.h"


//ex
%ctor {
    %init;

    // Change the default value of some options
    NSArray *allKeys = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys];
    if (![allKeys containsObject:@"YTVideoOverlay-YouQuality-Enabled"]) { 
       [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"YTVideoOverlay-YouQuality-Enabled"]; 
    }
    if (![allKeys containsObject:@"YouPiPEnabled"]) { 
       [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"YouPiPEnabled"]; 
    }
}
