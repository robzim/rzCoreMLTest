//
//  HelpViewController.h
//  rzCoreMLWhatWhere
//
//  Modern help screen with gradient background
//

#import <UIKit/UIKit.h>

@interface HelpViewController : UIViewController

@property (nonatomic, strong) CAGradientLayer *backgroundGradient;
@property (weak, nonatomic) IBOutlet UILabel *helpLabel;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UIButton *learnMoreButton;
@property (nonatomic, strong) UIView *glassCard;
@property (nonatomic, strong) CAGradientLayer *shimmerLayer;
@property (nonatomic, strong) CAGradientLayer *borderGradient;

- (IBAction)dismissHelp:(id)sender;

@end
