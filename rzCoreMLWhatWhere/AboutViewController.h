//
//  AboutViewController.h
//  rzCoreMLWhatWhere
//
//  Modern about screen with gradient background
//

#import <UIKit/UIKit.h>
#import <CoreML/CoreML.h>

@interface AboutViewController : UIViewController

@property (nonatomic, strong) CAGradientLayer *backgroundGradient;
@property (weak, nonatomic) IBOutlet UILabel *aboutLabel;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (nonatomic, strong) UIView *glassCard;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *scrollableLabel;
@property (nonatomic, strong) CAGradientLayer *shimmerLayer;
@property (nonatomic, strong) CAGradientLayer *borderGradient;

- (IBAction)dismissAbout:(id)sender;

@end
