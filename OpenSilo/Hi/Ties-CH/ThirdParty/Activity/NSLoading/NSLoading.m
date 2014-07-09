

#import "NSLoading.h"

#define FT_XOFFSET 0.0
#define FT_ACT_HEIGHT 40.0
#define FT_ACT_WIDTH 40.0
#define totalImages 10

@implementation NSLoading

- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
		self.backgroundColor = [UIColor clearColor];
		CGFloat xPos = ((frame.size.width/2)-FT_ACT_HEIGHT/2);
		CGFloat yPos = ((frame.size.height/2)-FT_ACT_WIDTH/2);
		
        progressImage = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(xPos, yPos, FT_ACT_WIDTH , FT_ACT_HEIGHT)];
        progressImage.hidesWhenStopped = YES;
        progressImage.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
		[self addSubview:progressImage];
        self.userInteractionEnabled = YES;
    }
    return self;
}

-(void)closeBtnAction:(id)sender{
	for(UIView *v in self.subviews)
		[v removeFromSuperview];
}
-(void)showInView:(UIView*)view{
	[self startAnimation];
	[view addSubview:self];
}

-(void)hide{
	[self stopAnimation];
	[self removeFromSuperview];
}

-(void)startAnimation{
	[progressImage startAnimating];
}

-(void)stopAnimation{
	[progressImage stopAnimating];
}

@end

