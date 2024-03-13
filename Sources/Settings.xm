// Settings.xm
#import "../Tweaks/YouTubeHeader/YTSettingsViewController.h"
#import "../Tweaks/YouTubeHeader/YTSearchableSettingsViewController.h"
#import "../Tweaks/YouTubeHeader/YTSettingsSectionItem.h"
#import "../Tweaks/YouTubeHeader/YTSettingsSectionItemManager.h"
#import "../Tweaks/YouTubeHeader/YTUIUtils.h"
#import "../Tweaks/YouTubeHeader/YTSettingsPickerViewController.h"
#import "Hiepvk.h"

#define VERSION_STRING [[NSString stringWithFormat:@"%@", @(OS_STRINGIFY(TWEAK_VERSION))] stringByReplacingOccurrencesOfString:@"\"" withString:@""]
#define SHOW_RELAUNCH_YT_SNACKBAR [[%c(GOOHUDManagerInternal) sharedInstance] showMessageMainThread:[%c(YTHUDMessage) messageWithText:LOC(@"RESTART_YOUTUBE")]]

#define SECTION_HEADER(s) [sectionItems addObject:[%c(YTSettingsSectionItem) itemWithTitle:@"\t" titleDescription:[s uppercaseString] accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger sectionItemIndex) { return NO; }]]

#define SWITCH_ITEM(t, d, k) [sectionItems addObject:[YTSettingsSectionItemClass switchItemWithTitle:t titleDescription:d accessibilityIdentifier:nil switchOn:IS_ENABLED(k) switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {[[NSUserDefaults standardUserDefaults] setBool:enabled forKey:k];return YES;} settingItemId:0]]

#define SWITCH_ITEM2(t, d, k) [sectionItems addObject:[YTSettingsSectionItemClass switchItemWithTitle:t titleDescription:d accessibilityIdentifier:nil switchOn:IS_ENABLED(k) switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {[[NSUserDefaults standardUserDefaults] setBool:enabled forKey:k];SHOW_RELAUNCH_YT_SNACKBAR;return YES;} settingItemId:0]]

static const NSInteger HiepvkSection = 500;

@interface YTSettingsSectionItemManager (Hiepvk)
- (void)updateTweakSectionWithEntry:(id)entry;
@end

extern NSBundle *HiepvkBundle();

// Settings
%hook YTAppSettingsPresentationData
+ (NSArray *)settingsCategoryOrder {
    NSArray *order = %orig;
    NSMutableArray *mutableOrder = [order mutableCopy];
    NSUInteger insertIndex = [order indexOfObject:@(1)];
    if (insertIndex != NSNotFound)
        [mutableOrder insertObject:@(HiepvkSection) atIndex:insertIndex + 1];
    return mutableOrder;
}
%end

%hook YTSettingsSectionController
- (void)setSelectedItem:(NSUInteger)selectedItem {
    if (selectedItem != NSNotFound) %orig;
}
%end

%hook YTSettingsSectionItemManager
%new(v@:@)
- (void)updateTweakSectionWithEntry:(id)entry {
    NSMutableArray *sectionItems = [NSMutableArray array];
    NSBundle *tweakBundle = HiepvkBundle();
    Class YTSettingsSectionItemClass = %c(YTSettingsSectionItem);
    YTSettingsViewController *settingsViewController = [self valueForKey:@"_settingsViewControllerDelegate"];

    # pragma mark - About
    // SECTION_HEADER(LOC(@"ABOUT"));

    YTSettingsSectionItem *version = [%c(YTSettingsSectionItem)
        itemWithTitle:LOC(@"VERSION")
        titleDescription:nil
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            return VERSION_STRING;
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://hiepvk.github.io"]];
        }
    ];
    [sectionItems addObject:version];

    YTSettingsSectionItem *exitYT = [%c(YTSettingsSectionItem)
        itemWithTitle:LOC(@"QUIT_YOUTUBE")
        titleDescription:nil
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            // https://stackoverflow.com/a/17802404/19227228
            [[UIApplication sharedApplication] performSelector:@selector(suspend)];
            [NSThread sleepForTimeInterval:0.5];
            exit(0);
        }
    ];
    [sectionItems addObject:exitYT];

    //Hide
    SWITCH_ITEM2(LOC(@"NO_ADS"), LOC(@"NO_ADS_DESC"), @"noAds_enabled");
    SWITCH_ITEM(LOC(@"PLAY_BACK"), LOC(@"PLAY_BACK_DESC"), @"backgroundPlayback_enabled");

    SWITCH_ITEM2(LOC(@"NO_YT_LOGO"), LOC(@"NO_YT_LOGO_DESC"), @"noYTLogo_enabled");
    SWITCH_ITEM2(LOC(@"PRE_YT_LOGO"), LOC(@"PRE_YT_LOGO_DESC"), @"premiumYTLogo_enabled");

    SWITCH_ITEM2(LOC(@"HIDE_HOVER_CARD"), LOC(@"HIDE_HOVER_CARD_DESC"), @"hideHoverCards_enabled");
    SWITCH_ITEM(LOC(@"UN_SHORTS"), LOC(@"UN_SHORTS_DESC"), @"un_shorts_enabled");
    SWITCH_ITEM2(LOC(@"HIDE_SUPER_THANKS"), LOC(@"HIDE_SUPER_THANKS_DESC"), @"hideBuySuperThanks_enabled");
    SWITCH_ITEM2(LOC(@"HIDE_SUBCRIPTIONS"), LOC(@"HIDE_SUBCRIPTIONS_DESC"), @"hideSubcriptions_enabled");
    SWITCH_ITEM2(LOC(@"DISABLE_RESUME_TO_SHORTS"), LOC(@"DISABLE_RESUME_TO_SHORTS_DESC"), @"disableResumeToShorts");


    if ([settingsViewController respondsToSelector:@selector(setSectionItems:forCategory:title:icon:titleDescription:headerHidden:)])
        [settingsViewController setSectionItems:sectionItems forCategory:HiepvkSection title:@"Hiepvk" icon:nil titleDescription:LOC(@"TITLE DESCRIPTION") headerHidden:YES];
    else
        [settingsViewController setSectionItems:sectionItems forCategory:HiepvkSection title:@"Hiepvk" titleDescription:LOC(@"TITLE DESCRIPTION") headerHidden:YES];
}

- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == HiepvkSection) {
        [self updateTweakSectionWithEntry:entry];
        return;
    }
    %orig;
}
%end
