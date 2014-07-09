
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UITableViewCell (Extend)  
+ (NSString*)cellID;
+ (NSString*)nibName;
+ (id)loadCell:(NSString *)cellId;
+ (id)dequeOrCreateInTable:(UITableView*)tableView cellId:(NSString *)cellId;

+(id)loadCell:(NSString*)nibName cellId:(NSString *)cellId;
+(id)dequeOrCreateInTable:(UITableView *)tableView cellId:(NSString *)cellId withNibName:(NSString*)nibName;
@end