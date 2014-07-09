

#include "UITableViewCell+NIB.h"


@implementation UITableViewCell (Extend)

+ (id)loadCell:(NSString *)cellId {
	NSArray* objects = [[NSBundle mainBundle] loadNibNamed:[self nibName] owner:self options:nil];
	
	for (id object in objects) {
		if ([object isKindOfClass:self]) {
			UITableViewCell *cell = object;
			[cell setValue:cellId forKey:@"_reuseIdentifier"];
			return cell;
		}
	}
	
	[NSException raise:@"WrongNibFormat" format:@"Nib for '%@' must contain one TableViewCell, and its class must be '%@'", [self nibName], [self class]];	
	
	return nil;
}

+(id)loadCell:(NSString*)nibName cellId:(NSString *)cellId{
	NSArray* objects = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
	
	for (id object in objects) {
		if ([object isKindOfClass:self]) {
			UITableViewCell *cell = object;
			[cell setValue:cellId forKey:@"_reuseIdentifier"];
			return cell;
		}
	}
	[NSException raise:@"WrongNibFormat" format:@"Nib for '%@' must contain one TableViewCell, and its class must be '%@'",nibName, [self class]];	
	return nil;
}


+ (NSString*)cellID { return [self description]; }


+ (NSString*)nibName { return [self description]; }


+ (id)dequeOrCreateInTable:(UITableView*)tableView cellId:(NSString *)cellId {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    return cell ? cell : [self loadCell:cellId];
	//return [self loadCell];
}
+(id)dequeOrCreateInTable:(UITableView *)tableView cellId:(NSString *)cellId withNibName:(NSString*)nibName {
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
	return cell ? cell : [self loadCell:nibName cellId:cellId];
}
@end
