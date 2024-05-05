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

// https://github.com/PoomSmart/YouTube-X
// Disable Ads
%hook YTIPlayerResponse

- (BOOL)isMonetized { return IS_ENABLED(@"noAds_enabled") ? NO : YES; }

%end

%hook YTDataUtils

+ (id)spamSignalsDictionary { return IS_ENABLED(@"noAds_enabled") ? @{} : %orig; }
+ (id)spamSignalsDictionaryWithoutIDFA { return IS_ENABLED(@"noAds_enabled") ? @{} : %orig; }

%end

%hook YTAdsInnerTubeContextDecorator

- (void)decorateContext:(id)context { if (!IS_ENABLED(@"noAds_enabled")) %orig(nil); }

%end

%hook YTAccountScopedAdsInnerTubeContextDecorator

- (void)decorateContext:(id)context { if (!IS_ENABLED(@"noAds_enabled")) %orig(nil); }

%end

BOOL isAdString(NSString *description) {
    if (IS_ENABLED(@"noAds_enabled") || [description containsString:@"brand_promo"]
        // || [description containsString:@"statement_banner"]
        // || [description containsString:@"product_carousel"]
        || [description containsString:@"shelf_header"]
        || [description containsString:@"product_engagement_panel"]
        || [description containsString:@"product_item"]
        || [description containsString:@"text_search_ad"]
        || [description containsString:@"text_image_button_layout"]
        || [description containsString:@"carousel_headered_layout"]
        || [description containsString:@"carousel_footered_layout"]
        || [description containsString:@"full_width_square_image_layout"]
        || [description containsString:@"full_width_portrait_image_layout"]
        || [description containsString:@"square_image_layout"] // install app ad
        || [description containsString:@"landscape_image_wide_button_layout"]
        || [description containsString:@"video_display_full_buttoned_layout"]
        || [description containsString:@"home_video_with_context"]
        || [description containsString:@"feed_ad_metadata"])
        return YES;
    return NO;
}

NSData *cellDividerData;

%hook YTIElementRenderer

- (NSData *)elementData {
    NSString *description = [self description];
    if (IS_ENABLED(@"noAds_enabled") && [description containsString:@"cell_divider"]) {
        if (IS_ENABLED(@"noAds_enabled") && !cellDividerData) cellDividerData = %orig;
        return cellDividerData;
    }
    if (self.hasCompatibilityOptions && self.compatibilityOptions.hasAdLoggingData && IS_ENABLED(@"noAds_enabled")) return cellDividerData;
    // if (isAdString(description)) return cellDividerData;
    NSArray *shortsToRemove = @[@"shorts_shelf.eml", @"shorts_video_cell.eml", @"6Shorts"];
    for (NSString *shorts in shortsToRemove) {
        if (IS_ENABLED(@"un_shorts_enabled") && [description containsString:shorts] && ![description containsString:@"history*"]) {
            return nil;
        }
    }
    return %orig;
}

%end

//PlayableInBackground
%hook YTIPlayabilityStatus

- (BOOL)isPlayableInBackground { return IS_ENABLED(@"backgroundPlayback_enabled") ? YES : NO; }

%end

%hook MLVideo

- (BOOL)playableInBackground { return IS_ENABLED(@"backgroundPlayback_enabled") ? YES : NO; }

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
