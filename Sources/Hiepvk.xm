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

// Fix App Group Directory by move it to document directory
%hook NSFileManager
- (NSURL *)containerURLForSecurityApplicationGroupIdentifier:(NSString *)groupIdentifier {
    if (groupIdentifier != nil) {
        NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        NSURL *documentsURL = [paths lastObject];
        return [documentsURL URLByAppendingPathComponent:@"AppGroup"];
    }
    return %orig(groupIdentifier);
}
%end

// Remove App Rating Prompt in YouTube (for Sideloaded - iOS 14+) - @arichornlover
%hook SKStoreReviewController
+ (void)requestReview { }
%end

// YTNoHoverCards: https://github.com/level3tjg/YTNoHoverCards
%hook YTCreatorEndscreenView
- (void)setHidden:(BOOL)hidden {
    if (IS_ENABLED(@"hideHoverCards_enabled"))
        hidden = YES;
    %orig;
}
%end

// NOYTPremium - https://github.com/PoomSmart/NoYTPremium/
// Alert
%hook YTCommerceEventGroupHandler
- (void)addEventHandlers {}
%end

// Full-screen
%hook YTInterstitialPromoEventGroupHandler
- (void)addEventHandlers {}
%end

%hook YTPromosheetEventGroupHandler
- (void)addEventHandlers {}
%end

%hook YTPromoThrottleController
- (BOOL)canShowThrottledPromo { return NO; }
- (BOOL)canShowThrottledPromoWithFrequencyCap:(id)arg1 { return NO; }
- (BOOL)canShowThrottledPromoWithFrequencyCaps:(id)arg1 { return NO; }
%end

%hook YTIShowFullscreenInterstitialCommand
- (BOOL)shouldThrottleInterstitial { return YES; }
%end

// "Try new features" in settings
%hook YTSettingsSectionItemManager
- (void)updatePremiumEarlyAccessSectionWithEntry:(id)arg1 {}
%end

// Survey
%hook YTSurveyController
- (void)showSurveyWithRenderer:(id)arg1 surveyParentResponder:(id)arg2 {}
%end

# pragma mark - Shorts controls overlay options

// Hide "Buy Super Thanks" banner
%hook _ASDisplayView
- (void)didMoveToWindow {
    %orig;
    if ((IS_ENABLED(@"hideBuySuperThanks_enabled")) && ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.suggested_action"])) { 
        self.hidden = YES; 
    }
}
%end

// Hide subscriptions button
%hook YTReelWatchRootViewController
- (void)setPausedStateCarouselView {
    if (IS_ENABLED(@"hideSubcriptions_enabled")) {}
    else { return %orig; }
}
%end

// Disable resume to Shorts
%hook YTShortsStartupCoordinator
- (id)evaluateResumeToShorts { 
    return IS_ENABLED(@"disableResumeToShorts") ? nil : %orig;
}
%end

//ex
%ctor {
    %init;

    // Change the default value of some options
    NSArray *allKeys = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys];
    if (![allKeys containsObject:@"YTVideoOverlay-YouQuality-Enabled"]) { 
       [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"YTVideoOverlay-YouQuality-Enabled"]; 
    }
    if (![allKeys containsObject:@"noAds_enabled"]) { 
       [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"noAds_enabled"]; 
    }
    if (![allKeys containsObject:@"backgroundPlayback_enabled"]) { 
       [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"backgroundPlayback_enabled"]; 
    }
    if (![allKeys containsObject:@"hideHoverCards_enabled"]) { 
       [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hideHoverCards_enabled"]; 
    }
    if (![allKeys containsObject:@"YouPiPEnabled"]) { 
       [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"YouPiPEnabled"]; 
    }
}
