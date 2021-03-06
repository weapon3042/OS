

#import <Foundation/Foundation.h>

@interface UIView (Toast)

// each makeToast method creates a view and displays it as toast
- (void)makeToast:(NSString *)message;
- (void)makeToast:(NSString *)message backgroundColor:(UIColor *)bgColor;
- (void)makeToast:(NSString *)message duration:(CGFloat)interval position:(id)position backgroundColor:(UIColor *)bgColor;
- (void)makeToast:(NSString *)message duration:(CGFloat)interval position:(id)position title:(NSString *)title backgroundColor:(UIColor *)bgColor;
- (void)makeToast:(NSString *)message duration:(CGFloat)interval position:(id)position title:(NSString *)title image:(UIImage *)image backgroundColor:(UIColor *)bgColor;
- (void)makeToast:(NSString *)message duration:(CGFloat)interval position:(id)position image:(UIImage *)image backgroundColor:(UIColor *)bgColor;

// displays toast with an activity spinner
- (void)makeToastActivity;
- (void)makeToastActivity:(id)position;
- (void)hideToastActivity;

// the showToast methods display any view as toast
- (void)showToast:(UIView *)toast;
- (void)showToast:(UIView *)toast duration:(CGFloat)interval position:(id)point;

@end
