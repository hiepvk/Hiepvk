#import "Hiepvk.h"

# pragma mark - YouTube patches

// Fix Google Sign in by @PoomSmart and @level3tjg
%hook NSBundle
- (NSDictionary *)infoDictionary {
    NSMutableDictionary *info = %orig.mutableCopy;
    NSString *altBundleIdentifier = info[@"ALTBundleIdentifier"];
    if (altBundleIdentifier) info[@"CFBundleIdentifier"] = altBundleIdentifier;
    return info;
}
%end

// Workaround
//%hook YTDataUtils
//+ (id)spamSignalsDictionary { return nil; }
//+ (id)spamSignalsDictionaryWithoutIDFA { return //nil; }
//%end

// https://github.com/PoomSmart/YouTube-X
// Disable Ads
%hook YTIPlayerResponse
- (BOOL)isMonetized { return IS_ENABLED(@"noAds_enabled") ? NO : YES; }
%end

%hook YTDataUtils
+ (id)spamSignalsDictionary { return IS_ENABLED(@"noAds_enabled") ? nil : %orig; }
+ (id)spamSignalsDictionaryWithoutIDFA { return IS_ENABLED(@"noAds_enabled") ? nil : %orig; }
%end

%hook YTAdsInnerTubeContextDecorator
- (void)decorateContext:(id)context { if (!IS_ENABLED(@"noAds_enabled")) %orig; }
%end

%hook YTAccountScopedAdsInnerTubeContextDecorator
- (void)decorateContext:(id)context { if (!IS_ENABLED(@"noAds_enabled")) %orig; }
%end

%hook YTIElementRenderer
- (NSData *)elementData {
    if (self.hasCompatibilityOptions && self.compatibilityOptions.hasAdLoggingData && IS_ENABLED(@"noAds_enabled")) return nil;

    NSString *description = [self description];

    NSArray *ads = @[@"brand_promo", @"product_carousel", @"product_engagement_panel", @"product_item", @"text_search_ad", @"text_image_button_layout", @"carousel_headered_layout", @"carousel_footered_layout", @"square_image_layout", @"landscape_image_wide_button_layout", @"feed_ad_metadata"];
    if (IS_ENABLED(@"noAds_enabled") && [ads containsObject:description]) {
        return [NSData data];
    }

    NSArray *shortsToRemove = @[@"shorts_shelf.eml", @"shorts_video_cell.eml", @"6Shorts"];
    for (NSString *shorts in shortsToRemove) {
        if (IS_ENABLED(@"un_shorts_enabled") && [description containsString:shorts] && ![description containsString:@"history*"]) {
            return nil;
        }
    }

    return %orig;
}
%end

%hook YTSectionListViewController
- (void)loadWithModel:(YTISectionListRenderer *)model {
    if (IS_ENABLED(@"noAds_enabled")) {
        NSMutableArray <YTISectionListSupportedRenderers *> *contentsArray = model.contentsArray;
        NSIndexSet *removeIndexes = [contentsArray indexesOfObjectsPassingTest:^BOOL(YTISectionListSupportedRenderers *renderers, NSUInteger idx, BOOL *stop) {
            YTIItemSectionRenderer *sectionRenderer = renderers.itemSectionRenderer;
            YTIItemSectionSupportedRenderers *firstObject = [sectionRenderer.contentsArray firstObject];
            return firstObject.hasPromotedVideoRenderer || firstObject.hasCompactPromotedVideoRenderer || firstObject.hasPromotedVideoInlineMutedRenderer;
        }];
        [contentsArray removeObjectsAtIndexes:removeIndexes];
    } %orig;
}
%end

//PlayableInBackground
%hook YTIPlayabilityStatus

- (BOOL)isPlayableInBackground { return IS_ENABLED(@"backgroundPlayback_enabled") ? YES : NO; }

%end

%hook MLVideo

- (BOOL)playableInBackground { return IS_ENABLED(@"backgroundPlayback_enabled") ? YES : NO; }

%end

//YTNoPaidPromo
%hook YTMainAppVideoPlayerOverlayViewController

- (void)setPaidContentWithPlayerData:(id)data {}

- (void)playerOverlayProvider:(YTPlayerOverlayProvider *)provider didInsertPlayerOverlay:(YTPlayerOverlay *)overlay {
    if ([[overlay overlayIdentifier] isEqualToString:@"player_overlay_paid_content"]) return;
    %orig;
}
%end

%hook YTInlineMutedPlaybackPlayerOverlayViewController

- (void)setPaidContentWithPlayerData:(id)data {}

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
