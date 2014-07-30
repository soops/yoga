#import "WiseFanCommon.h"
#import "WFConfigs_FCB.h"

/************************** Flags for building this app **************************/

#define  Is_Debug_Mode                   0
/************************** App Navigation Bar tint color **************************/
#define  kNavigationBarTintColor            @"060606"
#define  kNavigationBarSegmentSelected      @"060606"
#define  kNavigationSementTintColor         @"888888"
#define  kWallpaperLibBackground            @"474646"

/************************** Facebook keys **************************/
#define Facebook_ServiceName                @"com.AO.wisefans.fcbarcelona.Facebook_ServiceName"
#define FBAccessTokenKey                    @"com.AO.wisefans.fcbarcelona.FBAccessTokenKey"
#define FBExpirationDateKey                 @"com.AO.wisefans.fcbarcelona.FBExpirationDateKey"
#define FB_Minor_AccessTokenKey             @"com.AO.wisefans.fcbarcelona.FB_Minor_AccessTokenKey"
#define FB_Minor_ExpirationDateKey          @"com.AO.wisefans.fcbarcelona.FB_Minor_ExpirationDateKey"


/************************** Twitter keys **************************/
#define Twitter_ServiceName                 @"com.AO.wisefans.fcbarcelona.Twitter_ServiceName"
#define Twitter_OAuth_Data                  @"com.AO.wisefans.fcbarcelona.Twitter_OAuth_Data"

/************************** CID keys **************************/
#define CID_ServiceName                     @"com.AO.wisefans.flamengo.cid.service"

/************************** NRN keys ********************************/
#define NRN_ServiceName                     @"com.AO.wisefans.flamengo.nrn.Service"

/************************** Notification keys **************************/
#define kRefreshFavoritesTabsNotification   @"RefreshFavoritesTabs"
#define kRefreshDetailPlayerNotification    @"RefreshDetailPlayer"
#define kRefreshPlayerNotification          @"RefreshPlayerList"
#define kHideIndicator                      @"HideIndicator"
#define kRefreshViewNoNotification          @"RefreshViewNumber"
#define kNoNewPlayerDataNotification        @"com.AO.wisefans.fcbarcelona.NoNewPlayerData"
#define kTwitterRateLimitExceeded           @"TwitterRateLimitExceeded"
#define CDN_ACCESSED_Key                    @"FCB_CDN_Accessed"
#define CDN_ACCESSED_Value                  @"TRUE"
#define kJustLoggedonNotification           @"com.AO.fcbarcelona.justLoggedOn"
#define kCreateAccountSuccessfulNotif       @"com.AO.fcbarcelona.justCreated"
#define WF_Certificate_Key                  @"com.AO.fcbarcelona.certificate"
#define WF_Certificate_Secret_Key           @"com.AO.fcbarcelona.cert_secretkey"
#define WF_Certificate_CSR_Key              @"com.AO.fcbarcelona.cert_csr"
#define WF_ITEM_ID_NOTIFICATION_KEY         @"com.AO.wisefans.pushID"

#define kTwitterPostSuccess                 @"com.AO.oracle.twitterPostSuccess"
#define kTwitterPostFailed                  @"com.AO.oracle.twitterPostFailed"
#define kFacebookPostSuccess                @"com.AO.oracle.facebookPostSuccess"
#define kFacebookPostFailed                 @"com.AO.oracle.facebookPostFailed"

/************************** Webservice keys **************************/
#define Twitter_Get_Timeline                @"https://api.twitter.com/1.1/statuses/user_timeline"
#define Facebook_Graph                      @"https://graph.facebook.com" 
//#define AO_Sponsor_Json                @"http://cdn.wisfans.com/json/oracle/sponsor.json?v=%.f"
//#define AO_DEV_Sponsor_Json            @"https://s3.amazonaws.com/wisfanprod01/json/sponsor_dev.json"
//#define AO_InApp_Sponsor_Json          @"http://cdn.wisfans.com/json/oracle/scrollingAds.json?v=%.f"
//#define kInApp_Sponsor_Lastupdated          @"com.AO.inapp.sponsor.lastUpdated"

/*************************** App Ads *********************************/
#ifdef DEBUG
    #define AO_Sponsor_Json                @"http://cdn.dev.wisfans.com/app_25/ads/splashscreen.json?v=%.f"
    #define AO_InApp_Sponsor_Json          @"http://cdn.dev.wisfans.com/app_25/ads/floating.json?v=%.f"
    #define kInApp_Sponsor_Lastupdated          @"com.AO.inapp.sponsor.lastUpdated"
#else
    #define AO_Sponsor_Json                @"http://cdn.wisfans.com/app_25/ads/splashscreen.json?v=%.f"
    #define AO_InApp_Sponsor_Json          @"http://cdn.wisfans.com/app_25/ads/floating.json?v=%.f"
    #define kInApp_Sponsor_Lastupdated          @"com.AO.inapp.sponsor.lastUpdated"
#endif

// App Config
#define RS_DEVICE_TOKEN_KEY                 Device_Token_Key
#define RS_DEVICE_TOKEN                     [[NSUserDefaults standardUserDefaults] objectForKey:RS_DEVICE_TOKEN_KEY]

#define YOUR_APP_ID                         Facebook_App_ID

// SERVER
#define TW_APP_ID                           kOAuthConsumerKey
#define TW_SECRET_KEY                       kOAuthConsumerSecret

#define MY_USER_NAME_TWITER                 @"MY_USER_NAME_TWITER"
#define MY_USER_FACEBOOK                    @"MY_USER_FACEBOOK"

#define NF_FB_DIDLOGIN                      @"NF_FB_DIDLOGIN"
#define NF_FB_DIDLOGOUT                     @"NF_FB_DIDLOGOUT"
#define NF_FB_DIDNOTLOGIN                   @"NF_FB_DIDNOTLOGIN"
#define NF_FB_DIDLOAD                       @"NF_FB_DIDLOAD"
#define NF_FB_DIDFAIL                       @"NF_FB_DIDFAIL"

#define NF_TW_DIDLOGIN                      @"NF_TW_DIDLOGIN"
#define NF_TW_DIDLOGOUT                     @"NF_TW_DIDLOGOUT"
#define NF_TW_DIDLOAD                       @"NF_TW_DIDLOAD"
#define NF_TW_DIDFAIL                       @"NF_TW_DIDFAIL"

#define NF_UPDATE_ALBUM                     @"NF_UPDATE_ALBUM"
#define ALBUM_URL                           @"http://wing.runsystem.jp/wk_prj/list_albulm.txt"
#define IMAGE_URL                           @"http://wing.runsystem.jp/wk_prj/list_photo.txt"

#define IMAGE_BY_ALBULM_ID_URL              @"http://wing.runsystem.jp/wk_prj/list_photo_album_%i.txt"


//VIDEO CELL FORMAT

#define BORDER_VIDEO_LIST_FRAME_IPHONEX       CGSizeMake(480 / 5 , 360/5)
#define BORDER_VIDEO_LIST_FRAME_IPADX         CGSizeMake(480/2.8, 360/2.8)

#define CELL_SIZE_VIDEO_IPHONE                CGSizeMake(BORDER_VIDEO_LIST_FRAME_IPHONEX.width, BORDER_VIDEO_LIST_FRAME_IPHONEX.height + 30);

#define CELL_SIZE_VIDEO_IPAD                  CGSizeMake(BORDER_VIDEO_LIST_FRAME_IPADX.width, BORDER_VIDEO_LIST_FRAME_IPADX.height + 50)

//Cellsize without title
#define CELL_SIZE_NO_TITLE_IPHONE                CGSizeMake(BORDER_VIDEO_LIST_FRAME_IPHONEX.width, BORDER_VIDEO_LIST_FRAME_IPHONEX.height + 10);

#define CELL_SIZE_NO_TITLE_IPAD                  CGSizeMake(BORDER_VIDEO_LIST_FRAME_IPADX.width, BORDER_VIDEO_LIST_FRAME_IPADX.height + 20)


#define MediaPlayerIconSizeWidth            20
#define MediaPlayerIconSizeHeight           20

#define kTagMediaFilterBtn  1111



    //Album
#define IMAGE_PLACE_HOLDER_IPAD             @"photoSquareHuge_Ipad.png"
//#define IMAGE_BORDER_IPAD           @"photoAlbumFrame_Ipad.png"
#define IMAGE_BORDER_IPAD                   @"albumstack1@3x.png"
#define IMAGE_DETAIL_BORDER                 @"albumstack1@1x.png"

#define IMAGE_PLACE_HOLDER_IPHONE           @"photoSquareHuge.png"
//#define IMAGE_BORDER_IPHONE         @"photoAlbumFrame.png"
#define IMAGE_BORDER_IPHONE                 @"albumstack1@3x.png"

//Detail
#define IMAGE_DETAIL_PLACE_HOLDER_IPAD      @"photoSquareHuge_Ipad.png"
#define IMAGE_DETAIL_BORDER_IPAD            @"ImageBorderDetail_Ipad.png"

#define IMAGE_DETAIL_PLACE_HOLDER_IPHONE    @"photoSquareHuge.png"
#define IMAGE_DETAIL_BORDER_IPHONE          @"ImageBorderDetail.png"

#define kGridCellTitleColor                 [UIColor blackColor]
#define kGridCellSelectedColor              [UIColor blueColor]

#define CACHE_ACTIVE_DURATION   600 // 10 min

#define API_HEADER_NAME_KEY                 @"X_WF_REST_API_KEY"
#define API_HEADER_NAME_APPID               @"X_WF_APPLICATION_ID"
#define API_HEADER_NAME_SES_TOKEN           @"X_WF_SESSION_TOKEN"


#define WF_CLASS_PHOTO                      @"photo"
#define WF_CLASS_VIDEO                      @"video"
#define WF_CLASS_POST                       @"post"
#define WF_CLASS_COMM                       @"comment"


#ifdef DEBUG
    #define WF_SERVER_DOMAIN                @"https://api.dev.wisfans.com/1"
    #define AO_Service                 @"https://api.dev.wisfans.com/1"
    #define StaticListFile                  @"DevFlamengoPlayers"
    #define CDN_JSON_LINK                   @"http://cdn.dev.wisfans.com/staticdata/app_25_players.json"
    #define HomeLink                        @"http://cdn.dev.wisfans.com/staticdata/app_25_timeline.json"
#else
    #define WF_SERVER_DOMAIN                @"https://api.wisfans.com/1"
    #define AO_Service                 @"https://api.wisfans.com/1"
    #define StaticListFile                  @"FlamengoPlayers"
    #define CDN_JSON_LINK                   @"http://cdn.wisfans.com/staticdata/app_25_players.json"
    #define HomeLink                        @"http://cdn.wisfans.com/staticdata/app_25_timeline.json"
#endif


#define HASLIKE_API_URL                     [NSString stringWithFormat:@"%@/classes/wflike", WF_SERVER_DOMAIN]
#define UNLIKE_API_URL                      [NSString stringWithFormat:@"%@/classes/wflike", WF_SERVER_DOMAIN]
#define LIKE_API_URL                        [NSString stringWithFormat:@"%@/classes/wflike", WF_SERVER_DOMAIN] 
#define VIEW_API_URL                        [NSString stringWithFormat:@"%@/classes/wfview", WF_SERVER_DOMAIN] 
#define LOGIN_URL                           [NSString stringWithFormat:@"%@/wlogin", WF_SERVER_DOMAIN] 
#define SIGNUP_URL                          [NSString stringWithFormat:@"%@/wusers", WF_SERVER_DOMAIN]
#define CERTIFICATE_URL                     [NSString stringWithFormat:@"%@/wRequestCertificate", WF_SERVER_DOMAIN]
//Added for reset password
#define RESETPASSWD_URL                     [NSString stringWithFormat:@"%@/requestPasswordReset", WF_SERVER_DOMAIN]
//Added for checking email
#define CHECK_EMAIL_URL                     [NSString stringWithFormat:@"%@/wFindUser?email=", WF_SERVER_DOMAIN]
//Added for checking email verified
#define CHECK_EMAIL_VERIFIED_URL            [NSString stringWithFormat:@"%@/wVerifyEmail", WF_SERVER_DOMAIN];
//Added for requesting email verification
#define REQUEST_VERIFICATION_EMAIL_URL      [NSString stringWithFormat:@"%@/wRequestVerificationEmail", WF_SERVER_DOMAIN]
//Added for linking account
#define LINGKING_ACCOUNT_URL                [NSString stringWithFormat:@"%@/wusers/",WF_SERVER_DOMAIN]

//-added for cheering post
#define CHEERING_POST_URL                   [NSString stringWithFormat:@"%@/classes/wfpost", WF_SERVER_DOMAIN]

#define kWFALBUM_URL                        [NSString stringWithFormat:@"%@/classes/wfalbum", WF_SERVER_DOMAIN]
#define kWFMEDIA_URL                        [NSString stringWithFormat:@"%@/classes/wfmedia", WF_SERVER_DOMAIN]
#define kWFALBUM_MAX                        60
#define kWFALBUM_LIMIT_IPHONE               30
#define kWFALBUM_LIMIT_IPAD                 36


#define API_URL_GET_COMMENTS                [ WF_SERVER_DOMAIN stringByAppendingString:@"/classes/wfcomment" ]
#define API_URL_POST_COMMENT                API_URL_GET_COMMENTS
#define API_URL_GET_CMT_COUNT               API_URL_GET_COMMENTS // get comment with limit = 0 & offset = 0
#define API_URL_GET_COMMENT                 [ WF_SERVER_DOMAIN stringByAppendingString:@"/classes/wfcomment/%@" ] // comment ID
#define API_URL_DEL_COMMENT                 API_URL_GET_COMMENT // same url but use DELETE method

#define kWFABOUTUS_URL                      [NSString stringWithFormat:@"%@/classes/wfaboutus", WF_SERVER_DOMAIN]
#define kWFTITLES_URL                       [NSString stringWithFormat:@"%@/classes/wftitle", WF_SERVER_DOMAIN]
#define kWFIDOL_URL                         [NSString stringWithFormat:@"%@/classes/wfprofile?category=idol", WF_SERVER_DOMAIN]

#define kWFBIOGRAPHY                        [NSString stringWithFormat:@"%@/classes/wfprofile", WF_SERVER_DOMAIN]

#define kWFBIOGRAPHY_PLAYER                 [NSString stringWithFormat:@"%@/classes/wfprofile?category=player", WF_SERVER_DOMAIN]

#define kWFBIOGRAPHY_TECHNICAL              [NSString stringWithFormat:@"%@/classes/wfprofile?category=technical", WF_SERVER_DOMAIN]

#define kTimerForViewCount                  2.0

#define CACHE_COMMENT_DIR                   [ NSHomeDirectory() stringByAppendingString:@"/Library/Caches/Comments" ]
#define CACHE_COMMENT_PATH(a)               [ NSHomeDirectory() stringByAppendingFormat:@"/Library/Caches/Comments/%@.plist", a ]


#define ALBUM_FILE                          @"albumJson.plist"
#define IMAGE_FILE                          @"imageJson.plist"

#define MEDIA_CACHE_MAXIMUM                 200

//Album
#define IMG_PATH_ALBUM_THUMB_FOLDER [ NSHomeDirectory() stringByAppendingFormat:@"/Library/Album/Thumbs" ]

#define IMG_PATH_ALBUM_THUMB( a ) [ NSHomeDirectory() stringByAppendingFormat:@"/Library/Album/Thumbs/%@", a ]


//images
#define IMG_DIR_THUMB [ NSHomeDirectory() stringByAppendingString:@"/Library/Caches/Thumbs" ]
#define IMG_DIR_FULL [ NSHomeDirectory() stringByAppendingString:@"/Library/Caches/Images" ]
#define IMG_PATH_THUMB( a ) [ NSHomeDirectory() stringByAppendingFormat:@"/Library/Caches/Thumbs/%@", a ]
#define IMG_PATH_FULL( a ) [ NSHomeDirectory() stringByAppendingFormat:@"/Library/Caches/Images/%@", a ]

#define FILE_PATH_FULL( a ) [ NSHomeDirectory() stringByAppendingFormat:@"/Library/Caches/%@", a ]

#define kItemSharingKey                     @"com.AO.fcbarcelona.ItemSharing"
#define kAlbumOrderKey                      @"com.AO.fcbarcelona.mediaOrderKey"//General key
#define kAlbumSpecificOrderKey              @"com.AO.fcbarcelona.mediaNameOrderkey"//Specific key
#define kSortMediaDismiss                   @"com.AO.fcbarcelona.popoverShouldDismiss"

#define kAlbumOrderDateAscendingValue       @"Ascending"
#define kAlbumOrderDateDescendingValue      @"Descending"
#define kAlbumOrderDateValue                @"Date"
#define kAlbumOrderNameValue                @"Name"
#define kAlbumOrderViewCountValue           @"View count"

#define kMediaDetailFilterKey               @"com.AO.fcbarcelona.FilterMode_New"
#define kMediaDetailFilterPhotoMode         @"com.AO.fcbarcelona.Photo"
#define kMediaDetailFilterVideoMode         @"com.AO.fcbarcelona.Video"
#define kMediaDetailFilterBothMode          @"com.AO.fcbarcelona.Both"
//************************************Favourite tab*************************************//
#define FavoriteTimerDuration               2
#define FavoritePlayerSynDuration           15

//************************************Flurry*********************************************//
#define VIEW_SPONSOR_SITE                   @"SplashURLOpen"
#define VIEW_SPONSOR_SCREEN                 @"SplashView"
#define kFlurryAppkey                       @"6HZG5S7848PF6NF9Q432"

/* FR Constants */
#define FacesFolderName                     @"FRTemp/Faces"
#define TrainedFacesFolderName              @"FRTemp/TrainedFaces"
#define FRTempFolderName                    @"FRTemp"
#define FaceUnsaveName                      @"Unsave_Face"
//*************************************Tapjoy******************************************
#define kTapjoyAppKey                       @"49948239-a514-4553-a455-1beb0d31ab9e"
#define kTapjoySecretKey                    @"p6PLT2RtsHbKhjgmxv3A"
#define kTapjoyPPEKey                       @"6f3666be-a854-435a-889e-03050c8e0074"

/*****************************User var**************************************************/
#define     kCampaignAccountCreatedKey      @"com.AO.fcbarcelona.campaignAccountCreatedKey"
#define     kCampaignAccountCreatedValue    @"com.AO.fcbarcelona.campaignAccountCreatedValue"
#define     kLoggedOnEmailAddress           @"com.AO.fcbarcelona.loggedEmailAddress"
#define     kCampaignCertPresentKey         @"com.AO.fcbarcelona.certPresentKey"
#define     kCampaignCertPresentValue       @"com.AO.fcbarcelona.certPresentValue"
#define     kCIDAccountEmailVerified        @"com.AO.flamengo.emailVerified"

#define     kDeviceHeight                   [[UIScreen mainScreen] bounds].size.height
#define     kDeviceWidth                    [[UIScreen mainScreen] bounds].size.width

/* keys */
#define strKeyUserName                      @"username"
#define strKeyEmail                         @"email"
#define strKeyFirstName                     @"first_name"
#define strKeyLastName                      @"last_name"

/******************************WISeFans - FLAMENGO - server app keys*********************************/
#ifdef DEBUG
    #define X_WF_APPLICATION_ID                 @"5a7231703e80e03428e334327722cacc68259ef8"
    #define X_WF_REST_API_KEY                   @"8521d272b35d66c651b89559677fb4a514aaa9de"
#else
    #define X_WF_APPLICATION_ID                 @"d53cf88b0355c4574aaafd184d70eaf6ead84c1b"
    #define X_WF_REST_API_KEY                   @"d4e2946d6e44c994c0dac63943d813d11c9a77e6"
//    #define X_WF_APPLICATION_ID                 @"20d76205ada00a9fd8d3ead41474967d3aeff16b"
//    #define X_WF_REST_API_KEY                   @"f541d200b5c68f3d49b554c126b68675f09d8bce"
#endif


/*******************************Hanlde install times*************************************/
#define kPeriodToUpdatePlayerList           1
#define kLaunchAppAlready                   @"com.AO.fcbarcelona.notNew"
#define kLastTimeGetPlayerList              @"com.AO.fcbarcelona.lastTimeGetPlayerList"

/*******************************Sort Album*************************************/

#define DATE_INCREAMENT                     1
#define DATE_DECREMENT                      2
#define NAME                                3
#define POPULARITY                          4

#define UIViewAutoresizingFlexibleMargins                 \
UIViewAutoresizingFlexibleBottomMargin    | \
UIViewAutoresizingFlexibleLeftMargin      | \
UIViewAutoresizingFlexibleRightMargin     | \
UIViewAutoresizingFlexibleTopMargin

