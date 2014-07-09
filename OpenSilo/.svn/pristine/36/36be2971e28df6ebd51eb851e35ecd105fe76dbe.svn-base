
#define API_HOME @"http://198.100.174.22/jianyue/"
#define WeChatAppKey @"96503d2980ed218ec36e3c725138d741"

#define TimeStamp [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000]

#define BlackLayerOpacity 0.05

#define IS_IPAD() (UI_USER_INTER®FACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE ( [[[UIDevice currentDevice] model] isEqualToString:@"iPhone"] )
#define IS_IPOD   ( [[[UIDevice currentDevice ] model] isEqualToString:@"iPod touch"] )
#define IS_HEIGHT_GTE_568 [[UIScreen mainScreen ] bounds].size.height >= 568.0f
#define IS_IPHONE_5 ( IS_IPHONE && IS_HEIGHT_GTE_568 )
#define IS_SIMULATOR ([[[UIDevice currentDevice] model] rangeOfString:@"Simulator"].location != NSNotFound)

#define appDelegate ((TCHAppDelegate *)[[UIApplication sharedApplication] delegate])

#ifdef __IPHONE_6_0
#define ALIGN_LEFT NSTextAlignmentLeft
#else
#define ALIGN_LEFT UITextAlignmentLeft
#endif

#ifdef __IPHONE_6_0
#define ALIGN_CENTER NSTextAlignmentCenter
#else
#define ALIGN_CENTER UITextAlignmentCenter
#endif

#ifdef __IPHONE_6_0
#define ALIGN_RIGHT NSTextAlignmentRight
#else
#define ALIGN_RIGHT UITextAlignmentRight
#endif

#ifdef __IPHONE_6_0
# define LINE_BREAK_WORD_WRAP NSLineBreakByWordWrapping
#else
# define LINE_BREAK_WORD_WRAP UILineBreakModeWordWrap
#endif

#define FontRegular @"Avenir-Roman"
#define FontHeavy @"Avenir-Heavy"

#define SETFont(label,fontName,fontSize)\
label.font = [UIFont fontWithName:fontName size:fontSize];

#define GreenColor [UIColor colorWithRed:54.0/255.0 green:128.0/255.0 blue:8.0/255.0 alpha:1.0]
#define RedColor [UIColor redColor]
#define ThemeColor [UIColor colorWithRed:27/255.0 green:188/255.0 blue:155/255.0 alpha:1.000]

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)