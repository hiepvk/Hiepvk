#import "Hiepvk.h"

// Tweak's bundle for Localizations support - @PoomSmart - https://github.com/PoomSmart/YouPiP/commit/aea2473f64c75d73cab713e1e2d5d0a77675024f
NSBundle *HiepvkBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"Hiepvk" ofType:@"bundle"];
        if (tweakBundlePath)
            bundle = [NSBundle bundleWithPath:tweakBundlePath];
        else
            bundle = [NSBundle bundleWithPath:ROOT_PATH_NS(@"/Library/Application Support/Hiepvk.bundle")];
    });
    return bundle;
}
NSBundle *tweakBundle = HiepvkBundle();


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
