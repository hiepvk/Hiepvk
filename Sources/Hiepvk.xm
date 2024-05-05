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


// https://github.com/PoomSmart/YouTube-X
// Disable Ads
%group gnoAds
%hook YTIPlayerResponse

- (BOOL)isMonetized { return NO; }

%end

%hook YTDataUtils

+ (id)spamSignalsDictionary { return @{}; }
+ (id)spamSignalsDictionaryWithoutIDFA { return @{}; }

%end

%hook YTAdsInnerTubeContextDecorator

- (void)decorateContext:(id)context { %orig(nil); }

%end

%hook YTAccountScopedAdsInnerTubeContextDecorator

- (void)decorateContext:(id)context { %orig(nil); }

%end

BOOL isAdString(NSString *description) {
    if ([description containsString:@"brand_promo"]
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

%hook YTInnerTubeCollectionViewController

- (void)loadWithModel:(YTISectionListRenderer *)model {
    if ([model isKindOfClass:%c(YTISectionListRenderer)]) {
        NSMutableArray <YTISectionListSupportedRenderers *> *contentsArray = model.contentsArray;
        NSIndexSet *removeIndexes = [contentsArray indexesOfObjectsPassingTest:^BOOL(YTISectionListSupportedRenderers *renderers, NSUInteger idx, BOOL *stop) {
            if (![renderers isKindOfClass:%c(YTISectionListSupportedRenderers)])
                return NO;
            YTIItemSectionRenderer *sectionRenderer = renderers.itemSectionRenderer;
            YTIItemSectionSupportedRenderers *firstObject = [sectionRenderer.contentsArray firstObject];
            YTIElementRenderer *elementRenderer = firstObject.elementRenderer;
            NSString *description = [elementRenderer description];
            return isAdString(description)
                || [description containsString:@"product_carousel"]
                || [description containsString:@"post_shelf"]
                || [description containsString:@"statement_banner"];
        }];
        [contentsArray removeObjectsAtIndexes:removeIndexes];
    }
    %orig;
}

%end
%end

NSData *cellDividerData;

%hook YTIElementRenderer

- (NSData *)elementData {
    NSString *description = [self description];
    if ([description containsString:@"cell_divider"]) {
        if (!cellDividerData) cellDividerData = %orig;
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

//ex
%ctor {
    %init;

    if (IS_ENABLED(@"noAds_enabled")) {
        %init(gnoAds);
    }

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
