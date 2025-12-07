//
//  SplashViewController.h
//  rzCoreMLWhatWhere
//
//  Modern splash screen with gradient background and animated elements
//

#import <UIKit/UIKit.h>

@interface SplashViewController : UIViewController

@property (nonatomic, strong) CAGradientLayer *backgroundGradient;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;

- (IBAction)startButtonPressed:(id)sender;

@end
