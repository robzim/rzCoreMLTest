//
//  SplashViewController.m
//  rzCoreMLWhatWhere
//
//  Modern splash screen with gradient background and animated elements
//

#import "SplashViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation SplashViewController

@synthesize backgroundGradient;
@synthesize welcomeLabel;
@synthesize startButton;
@synthesize loadingIndicator;
@synthesize loadingLabel;

static bool hasAppliedSplashStyling = false;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    if (!hasAppliedSplashStyling) {
        [self applyModernDesign];
        hasAppliedSplashStyling = true;
    }

    if (backgroundGradient) {
        backgroundGradient.frame = self.view.bounds;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self animateEntrance];
}

#pragma mark - Modern Design

- (void)applyModernDesign {
    [self applyGradientBackground];
    [self styleWelcomeLabel];
    [self styleStartButton];
    [self addFloatingParticles];
}

- (void)applyGradientBackground {
    backgroundGradient = [CAGradientLayer layer];
    backgroundGradient.frame = self.view.bounds;

    // Deep space gradient matching main view
    UIColor *topColor = [UIColor colorWithRed:0.05 green:0.02 blue:0.15 alpha:1.0];
    UIColor *middleColor = [UIColor colorWithRed:0.08 green:0.05 blue:0.20 alpha:1.0];
    UIColor *bottomColor = [UIColor colorWithRed:0.02 green:0.02 blue:0.08 alpha:1.0];

    backgroundGradient.colors = @[(id)topColor.CGColor,
                                   (id)middleColor.CGColor,
                                   (id)bottomColor.CGColor];
    backgroundGradient.locations = @[@0.0, @0.5, @1.0];
    backgroundGradient.startPoint = CGPointMake(0.0, 0.0);
    backgroundGradient.endPoint = CGPointMake(1.0, 1.0);

    [self.view.layer insertSublayer:backgroundGradient atIndex:0];
}

- (void)styleWelcomeLabel {
    if (!welcomeLabel) return;

    // Vibrant cyan color with glow
    UIColor *textColor = [UIColor colorWithRed:0.0 green:0.9 blue:0.95 alpha:1.0];
    welcomeLabel.textColor = textColor;
    welcomeLabel.layer.shadowColor = textColor.CGColor;
    welcomeLabel.layer.shadowOffset = CGSizeZero;
    welcomeLabel.layer.shadowRadius = 15;
    welcomeLabel.layer.shadowOpacity = 0.8;

    // Update text to be more engaging
    welcomeLabel.text = @"Welcome to Local AI Brilliance!\n\nExperience the power of Apple's Machine Learning right on your device.\n\nAnalyze photos with 6 different AI models - all running locally, no internet needed!\n\nReady to see AI in action?";
}

- (void)styleStartButton {
    if (!startButton) return;

    // Check if iPad (regular width class)
    BOOL isIPad = (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular &&
                   self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular);

    // Scale values based on device
    CGFloat cornerRadius = isIPad ? 40.0 : 25.0;
    CGFloat fontSize = isIPad ? 36.0 : 20.0;
    CGFloat borderWidth = isIPad ? 3.0 : 2.0;
    CGFloat shadowRadius = isIPad ? 25.0 : 15.0;

    // Modern rounded corners
    startButton.layer.cornerRadius = cornerRadius;
    startButton.clipsToBounds = NO;

    // Remove any existing gradient layers first
    NSArray *sublayers = [startButton.layer.sublayers copy];
    for (CALayer *layer in sublayers) {
        if ([layer isKindOfClass:[CAGradientLayer class]]) {
            [layer removeFromSuperlayer];
        }
    }

    // Gradient background
    CAGradientLayer *buttonGradient = [CAGradientLayer layer];
    buttonGradient.frame = startButton.bounds;
    buttonGradient.cornerRadius = cornerRadius;

    UIColor *gradientStart = [UIColor colorWithRed:0.4 green:0.2 blue:0.8 alpha:1.0];
    UIColor *gradientEnd = [UIColor colorWithRed:0.2 green:0.1 blue:0.5 alpha:1.0];
    buttonGradient.colors = @[(id)gradientStart.CGColor, (id)gradientEnd.CGColor];
    buttonGradient.startPoint = CGPointMake(0.0, 0.0);
    buttonGradient.endPoint = CGPointMake(1.0, 1.0);

    [startButton.layer insertSublayer:buttonGradient atIndex:0];

    // Glowing shadow
    startButton.layer.shadowColor = [UIColor colorWithRed:0.5 green:0.3 blue:1.0 alpha:1.0].CGColor;
    startButton.layer.shadowOffset = CGSizeMake(0, isIPad ? 10 : 6);
    startButton.layer.shadowRadius = shadowRadius;
    startButton.layer.shadowOpacity = 0.7;

    // Border glow
    startButton.layer.borderWidth = borderWidth;
    startButton.layer.borderColor = [UIColor colorWithRed:0.6 green:0.4 blue:1.0 alpha:0.8].CGColor;

    // Text styling
    [startButton setTitle:@"Let's Go!" forState:UIControlStateNormal];
    [startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    startButton.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];

    // Touch animations
    [startButton addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [startButton addTarget:self action:@selector(buttonTouchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
}

- (void)addFloatingParticles {
    CAEmitterLayer *emitter = [CAEmitterLayer layer];
    emitter.emitterPosition = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height);
    emitter.emitterShape = kCAEmitterLayerLine;
    emitter.emitterSize = CGSizeMake(self.view.bounds.size.width, 1);

    CAEmitterCell *particle = [CAEmitterCell emitterCell];
    particle.birthRate = 3;
    particle.lifetime = 15.0;
    particle.velocity = 30;
    particle.velocityRange = 20;
    particle.emissionLongitude = -M_PI_2;
    particle.emissionRange = M_PI_4;
    particle.scale = 0.05;
    particle.scaleRange = 0.03;
    particle.alphaSpeed = -0.05;

    // Create a soft glowing circle
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 30), NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0.5 green:0.4 blue:1.0 alpha:0.6].CGColor);
    CGContextFillEllipseInRect(ctx, CGRectMake(0, 0, 30, 30));
    UIImage *particleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    particle.contents = (id)particleImage.CGImage;

    emitter.emitterCells = @[particle];
    [self.view.layer insertSublayer:emitter atIndex:1];
}

#pragma mark - Animations

- (void)animateEntrance {
    // Animate welcome label
    if (welcomeLabel) {
        welcomeLabel.alpha = 0;
        welcomeLabel.transform = CGAffineTransformMakeTranslation(0, 30);

        [UIView animateWithDuration:0.8
                              delay:0.2
             usingSpringWithDamping:0.8
              initialSpringVelocity:0.5
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
            self.welcomeLabel.alpha = 1.0;
            self.welcomeLabel.transform = CGAffineTransformIdentity;
        } completion:nil];
    }

    // Animate button with pulse
    if (startButton) {
        startButton.alpha = 0;
        startButton.transform = CGAffineTransformMakeScale(0.8, 0.8);

        [UIView animateWithDuration:0.6
                              delay:0.6
             usingSpringWithDamping:0.6
              initialSpringVelocity:0.8
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
            self.startButton.alpha = 1.0;
            self.startButton.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [self startButtonPulseAnimation];
        }];
    }
}

- (void)startButtonPulseAnimation {
    [UIView animateWithDuration:1.5
                          delay:0
                        options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
        self.startButton.layer.shadowOpacity = 0.9;
        self.startButton.layer.shadowRadius = 25;
    } completion:nil];
}

- (void)buttonTouchDown:(UIButton *)button {
    UIImpactFeedbackGenerator *haptic = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    [haptic impactOccurred];

    [UIView animateWithDuration:0.15
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        button.transform = CGAffineTransformMakeScale(0.95, 0.95);
        button.layer.shadowOpacity = 0.3;
    } completion:nil];
}

- (void)buttonTouchUp:(UIButton *)button {
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        button.transform = CGAffineTransformIdentity;
        button.layer.shadowOpacity = 0.6;
    } completion:nil];
}

#pragma mark - Button Action

- (IBAction)startButtonPressed:(id)sender {
    // Show loading state
    [self showLoadingState];

    // Perform segue after a brief delay to allow UI to update
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"showMainView" sender:self];
    });
}

- (void)showLoadingState {
    // Hide the start button
    [UIView animateWithDuration:0.2 animations:^{
        self.startButton.alpha = 0;
    }];

    // Show and start the activity indicator
    if (loadingIndicator) {
        loadingIndicator.hidden = NO;
        [loadingIndicator startAnimating];
    }

    // Show loading label
    if (loadingLabel) {
        loadingLabel.hidden = NO;
        loadingLabel.alpha = 0;
        [UIView animateWithDuration:0.3 animations:^{
            self.loadingLabel.alpha = 1.0;
        }];
    }

    // Update welcome label text
    if (welcomeLabel) {
        [UIView animateWithDuration:0.3 animations:^{
            self.welcomeLabel.text = @"Loading AI Models...\n\nThis may take a moment on first launch.";
        }];
    }
}

@end
