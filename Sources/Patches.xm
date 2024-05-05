#import "Hiepvk.h"

// Fix Google Sign in by @PoomSmart and @level3tjg (qnblackcat/uYouPlus#684)
%hook NSBundle
- (NSDictionary *)infoDictionary {
    NSMutableDictionary *info = %orig.mutableCopy;
    if ([self isEqual:NSBundle.mainBundle])
        info[@"CFBundleIdentifier"] = @"com.google.ios.youtube";
    return info;
}
%end

// YouAreThere - https://github.com/PoomSmart/YouAreThere
%hook YTColdConfig

- (BOOL)enableYouthereCommandsOnIos { return IS_ENABLED(@"YouAreThere_enabled") ? YES : NO; }

%end

%hook YTYouThereController

- (BOOL)shouldShowYouTherePrompt { return IS_ENABLED(@"YouAreThere_enabled") ? YES : NO; }

%end

// YTNoPaidPromo: https://github.com/PoomSmart/YTNoPaidPromo
%hook YTMainAppVideoPlayerOverlayViewController
- (void)setPaidContentWithPlayerData:(id)data {
    if (IS_ENABLED(@"hidePaidPromotionCard_enabled")) {}
    else { return %orig; }
}
- (void)playerOverlayProvider:(YTPlayerOverlayProvider *)provider didInsertPlayerOverlay:(YTPlayerOverlay *)overlay {
    if ([[overlay overlayIdentifier] isEqualToString:@"player_overlay_paid_content"] && IS_ENABLED(@"hidePaidPromotionCard_enabled")) return;
    %orig;
}
%end

%hook YTInlineMutedPlaybackPlayerOverlayViewController
- (void)setPaidContentWithPlayerData:(id)data {
    if (IS_ENABLED(@"hidePaidPromotionCard_enabled")) {}
    else { return %orig; }
}
%end

// Hide Upgrade Dialog by @arichorn
%hook YTGlobalConfig
- (BOOL)shouldBlockUpgradeDialog { return YES;}
- (BOOL)shouldForceUpgrade { return NO;}
- (BOOL)shouldShowUpgrade { return NO;}
- (BOOL)shouldShowUpgradeDialog { return NO;}
%end

// Hide YouTube Logo
%hook YTHeaderView
- (void)setCustomTitleView:(UIView *)customTitleView { if (!IS_ENABLED(@"noYTLogo_enabled")) %orig; }
- (void)setTitle:(NSString *)title { IS_ENABLED(@"noYTLogo_enabled") ? %orig(@"") : %orig; }
%end

// Premium logo
%hook UIImageView
- (void)setImage:(UIImage *)image {
    if (!IS_ENABLED(@"premiumYTLogo_enabled")) return %orig;

    NSString *resourcesPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Frameworks/Module_Framework.framework/Innertube_Resources.bundle"];
    NSBundle *frameworkBundle = [NSBundle bundleWithPath:resourcesPath];

    if ([[image description] containsString:@"Resources: youtube_logo)"]) {
        image = [UIImage imageNamed:@"youtube_premium_logo" inBundle:frameworkBundle compatibleWithTraitCollection:nil];
    }

    else if ([[image description] containsString:@"Resources: youtube_logo_dark)"]) {
        image = [UIImage imageNamed:@"youtube_premium_logo_white" inBundle:frameworkBundle compatibleWithTraitCollection:nil];
    }

    %orig(image);
}
%end
