//
//  HelpViewController.m
//  rzCoreMLWhatWhere
//
//  Modern help screen with gradient background
//

#import "HelpViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation HelpViewController

@synthesize backgroundGradient;
@synthesize helpLabel;
@synthesize okButton;
@synthesize learnMoreButton;
@synthesize glassCard;
@synthesize shimmerLayer;
@synthesize borderGradient;

static bool hasAppliedHelpStyling = false;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    hasAppliedHelpStyling = false;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    if (!hasAppliedHelpStyling) {
        [self applyModernDesign];
        hasAppliedHelpStyling = true;
    }

    if (backgroundGradient) {
        backgroundGradient.frame = self.view.bounds;
    }

    // Update button gradient frames on every layout pass
    [self updateButtonGradientFrames];

    // Update card layer frames
    [self updateCardLayerFrames];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self animateEntrance];
}

#pragma mark - Actions

- (IBAction)dismissHelp:(id)sender {
    UIImpactFeedbackGenerator *haptic = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    [haptic impactOccurred];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Modern Design

- (void)applyModernDesign {
    [self applyGradientBackground];
    [self styleHelpLabel];
    [self styleAllButtons];
    [self addSubtleGlow];
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

- (void)styleHelpLabel {
    if (!helpLabel) return;

    // Create ultra-modern glassmorphic card
    glassCard = [[UIView alloc] init];
    glassCard.translatesAutoresizingMaskIntoConstraints = NO;
    glassCard.layer.cornerRadius = 24;
    glassCard.clipsToBounds = YES;

    [helpLabel.superview insertSubview:glassCard belowSubview:helpLabel];

    [NSLayoutConstraint activateConstraints:@[
        [glassCard.topAnchor constraintEqualToAnchor:helpLabel.topAnchor constant:-20],
        [glassCard.bottomAnchor constraintEqualToAnchor:helpLabel.bottomAnchor constant:20],
        [glassCard.leadingAnchor constraintEqualToAnchor:helpLabel.leadingAnchor constant:-20],
        [glassCard.trailingAnchor constraintEqualToAnchor:helpLabel.trailingAnchor constant:20]
    ]];

    // Glassmorphism blur effect
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.frame = glassCard.bounds;
    blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    blurView.alpha = 0.7;
    [glassCard addSubview:blurView];

    // Gradient overlay for depth
    CAGradientLayer *glassGradient = [CAGradientLayer layer];
    glassGradient.frame = glassCard.bounds;
    glassGradient.colors = @[
        (id)[UIColor colorWithRed:0.2 green:0.1 blue:0.4 alpha:0.6].CGColor,
        (id)[UIColor colorWithRed:0.1 green:0.05 blue:0.25 alpha:0.4].CGColor,
        (id)[UIColor colorWithRed:0.15 green:0.08 blue:0.35 alpha:0.5].CGColor
    ];
    glassGradient.locations = @[@0.0, @0.5, @1.0];
    glassGradient.startPoint = CGPointMake(0.0, 0.0);
    glassGradient.endPoint = CGPointMake(1.0, 1.0);
    [glassCard.layer addSublayer:glassGradient];

    // Animated rainbow border
    [self addAnimatedBorderToCard];

    // Inner glow highlight at top
    CAGradientLayer *innerGlow = [CAGradientLayer layer];
    innerGlow.frame = CGRectMake(0, 0, glassCard.bounds.size.width, 60);
    innerGlow.colors = @[
        (id)[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.15].CGColor,
        (id)[UIColor clearColor].CGColor
    ];
    innerGlow.startPoint = CGPointMake(0.5, 0.0);
    innerGlow.endPoint = CGPointMake(0.5, 1.0);
    [glassCard.layer addSublayer:innerGlow];

    // Outer glow shadow
    glassCard.layer.masksToBounds = NO;
    glassCard.clipsToBounds = NO;

    // Style the text with neon glow
    UIColor *textColor = [UIColor colorWithRed:0.9 green:0.95 blue:1.0 alpha:1.0];
    helpLabel.textColor = textColor;
    helpLabel.layer.shadowColor = [UIColor colorWithRed:0.4 green:0.6 blue:1.0 alpha:1.0].CGColor;
    helpLabel.layer.shadowOffset = CGSizeZero;
    helpLabel.layer.shadowRadius = 8;
    helpLabel.layer.shadowOpacity = 0.8;

    // Add shimmer effect layer
    [self addShimmerEffect];
}

- (void)addAnimatedBorderToCard {
    if (!glassCard) return;

    // Create a shape layer for the border
    CAShapeLayer *borderShape = [CAShapeLayer layer];
    CGRect borderRect = CGRectInset(glassCard.bounds, 1, 1);
    borderShape.path = [UIBezierPath bezierPathWithRoundedRect:borderRect cornerRadius:23].CGPath;
    borderShape.fillColor = [UIColor clearColor].CGColor;
    borderShape.strokeColor = [UIColor whiteColor].CGColor;
    borderShape.lineWidth = 2.0;

    // Animated gradient for the border
    borderGradient = [CAGradientLayer layer];
    borderGradient.frame = glassCard.bounds;
    borderGradient.colors = @[
        (id)[UIColor colorWithRed:0.4 green:0.2 blue:1.0 alpha:0.8].CGColor,
        (id)[UIColor colorWithRed:0.6 green:0.3 blue:1.0 alpha:0.6].CGColor,
        (id)[UIColor colorWithRed:0.3 green:0.6 blue:1.0 alpha:0.8].CGColor,
        (id)[UIColor colorWithRed:0.5 green:0.2 blue:0.9 alpha:0.6].CGColor,
        (id)[UIColor colorWithRed:0.4 green:0.2 blue:1.0 alpha:0.8].CGColor
    ];
    borderGradient.startPoint = CGPointMake(0.0, 0.0);
    borderGradient.endPoint = CGPointMake(1.0, 1.0);
    borderGradient.mask = borderShape;

    [glassCard.layer addSublayer:borderGradient];
}

- (void)addShimmerEffect {
    if (!glassCard) return;

    shimmerLayer = [CAGradientLayer layer];
    shimmerLayer.frame = CGRectMake(-glassCard.bounds.size.width, 0,
                                     glassCard.bounds.size.width * 2,
                                     glassCard.bounds.size.height);
    shimmerLayer.colors = @[
        (id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor,
        (id)[UIColor colorWithWhite:1.0 alpha:0.03].CGColor,
        (id)[UIColor colorWithWhite:1.0 alpha:0.1].CGColor,
        (id)[UIColor colorWithWhite:1.0 alpha:0.03].CGColor,
        (id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor
    ];
    shimmerLayer.locations = @[@0.0, @0.35, @0.5, @0.65, @1.0];
    shimmerLayer.startPoint = CGPointMake(0.0, 0.5);
    shimmerLayer.endPoint = CGPointMake(1.0, 0.5);

    [glassCard.layer addSublayer:shimmerLayer];
}

- (void)startCardAnimations {
    // Floating animation
    CABasicAnimation *floatAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    floatAnimation.fromValue = @(-3);
    floatAnimation.toValue = @(3);
    floatAnimation.duration = 2.5;
    floatAnimation.autoreverses = YES;
    floatAnimation.repeatCount = HUGE_VALF;
    floatAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [glassCard.layer addAnimation:floatAnimation forKey:@"floating"];

    // Border gradient rotation animation
    CABasicAnimation *borderAnimation = [CABasicAnimation animationWithKeyPath:@"colors"];
    borderAnimation.toValue = @[
        (id)[UIColor colorWithRed:0.3 green:0.6 blue:1.0 alpha:0.8].CGColor,
        (id)[UIColor colorWithRed:0.5 green:0.2 blue:0.9 alpha:0.6].CGColor,
        (id)[UIColor colorWithRed:0.4 green:0.2 blue:1.0 alpha:0.8].CGColor,
        (id)[UIColor colorWithRed:0.6 green:0.3 blue:1.0 alpha:0.6].CGColor,
        (id)[UIColor colorWithRed:0.3 green:0.6 blue:1.0 alpha:0.8].CGColor
    ];
    borderAnimation.duration = 3.0;
    borderAnimation.autoreverses = YES;
    borderAnimation.repeatCount = HUGE_VALF;
    [borderGradient addAnimation:borderAnimation forKey:@"borderColorShift"];

    // Shimmer sweep animation
    CABasicAnimation *shimmerAnimation = [CABasicAnimation animationWithKeyPath:@"position.x"];
    shimmerAnimation.fromValue = @(-glassCard.bounds.size.width);
    shimmerAnimation.toValue = @(glassCard.bounds.size.width * 2);
    shimmerAnimation.duration = 4.0;
    shimmerAnimation.repeatCount = HUGE_VALF;
    shimmerAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [shimmerLayer addAnimation:shimmerAnimation forKey:@"shimmerSweep"];

    // Subtle pulse glow on card
    CABasicAnimation *glowPulse = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    glowPulse.fromValue = @(0.3);
    glowPulse.toValue = @(0.7);
    glowPulse.duration = 2.0;
    glowPulse.autoreverses = YES;
    glowPulse.repeatCount = HUGE_VALF;
    glowPulse.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

    glassCard.layer.shadowColor = [UIColor colorWithRed:0.4 green:0.3 blue:1.0 alpha:1.0].CGColor;
    glassCard.layer.shadowOffset = CGSizeZero;
    glassCard.layer.shadowRadius = 20;
    glassCard.layer.shadowOpacity = 0.5;
    [glassCard.layer addAnimation:glowPulse forKey:@"glowPulse"];
}

- (void)styleAllButtons {
    [self styleButtonsInView:self.view];
}

- (void)styleButtonsInView:(UIView *)view {
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            [self styleModernButton:(UIButton *)subview];
        }
        [self styleButtonsInView:subview];
    }
}

- (void)updateButtonGradientFrames {
    [self updateButtonGradientFramesInView:self.view];
}

- (void)updateButtonGradientFramesInView:(UIView *)view {
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            for (CALayer *layer in button.layer.sublayers) {
                if ([layer.name isEqualToString:@"buttonGradient"]) {
                    layer.frame = button.bounds;
                    break;
                }
            }
        }
        [self updateButtonGradientFramesInView:subview];
    }
}

- (void)styleModernButton:(UIButton *)button {
    if (!button) return;

    // Modern rounded corners
    button.layer.cornerRadius = 15.0;
    button.clipsToBounds = NO;

    // Gradient background
    CAGradientLayer *buttonGradient = [CAGradientLayer layer];
    buttonGradient.name = @"buttonGradient";
    buttonGradient.frame = button.bounds;
    buttonGradient.cornerRadius = 15.0;

    UIColor *gradientStart = [UIColor colorWithRed:0.3 green:0.2 blue:0.6 alpha:1.0];
    UIColor *gradientEnd = [UIColor colorWithRed:0.2 green:0.1 blue:0.4 alpha:1.0];
    buttonGradient.colors = @[(id)gradientStart.CGColor, (id)gradientEnd.CGColor];
    buttonGradient.startPoint = CGPointMake(0.0, 0.0);
    buttonGradient.endPoint = CGPointMake(1.0, 1.0);

    // Remove existing gradient layers
    NSArray *sublayers = [button.layer.sublayers copy];
    for (CALayer *layer in sublayers) {
        if ([layer isKindOfClass:[CAGradientLayer class]]) {
            [layer removeFromSuperlayer];
        }
    }

    [button.layer insertSublayer:buttonGradient atIndex:0];

    // Shadow
    button.layer.shadowColor = [UIColor colorWithRed:0.4 green:0.2 blue:0.8 alpha:1.0].CGColor;
    button.layer.shadowOffset = CGSizeMake(0, 4);
    button.layer.shadowRadius = 10;
    button.layer.shadowOpacity = 0.5;

    // Border glow
    button.layer.borderWidth = 1.0;
    button.layer.borderColor = [UIColor colorWithRed:0.5 green:0.4 blue:0.9 alpha:0.6].CGColor;

    // Text styling - centered and larger
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithWhite:0.8 alpha:1.0] forState:UIControlStateHighlighted];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:22];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;

    // Add touch animations
    [button addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(buttonTouchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
}

- (void)addSubtleGlow {
    // Add a subtle glow effect at the top
    CAGradientLayer *glowLayer = [CAGradientLayer layer];
    glowLayer.frame = CGRectMake(0, 0, self.view.bounds.size.width, 200);
    glowLayer.colors = @[(id)[UIColor colorWithRed:0.3 green:0.2 blue:0.6 alpha:0.3].CGColor,
                         (id)[UIColor clearColor].CGColor];
    glowLayer.startPoint = CGPointMake(0.5, 0.0);
    glowLayer.endPoint = CGPointMake(0.5, 1.0);

    [self.view.layer insertSublayer:glowLayer atIndex:1];
}

#pragma mark - Animations

- (void)animateEntrance {
    // Animate glass card with dramatic entrance
    if (glassCard) {
        glassCard.alpha = 0;
        glassCard.transform = CGAffineTransformMakeScale(0.8, 0.8);

        [UIView animateWithDuration:0.8
                              delay:0.1
             usingSpringWithDamping:0.7
              initialSpringVelocity:0.5
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
            self.glassCard.alpha = 1.0;
            self.glassCard.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            // Start continuous animations after entrance
            [self startCardAnimations];
            [self updateCardLayerFrames];
        }];
    }

    // Animate help label with fade in
    if (helpLabel) {
        helpLabel.alpha = 0;
        helpLabel.transform = CGAffineTransformMakeTranslation(0, 30);

        [UIView animateWithDuration:0.6
                              delay:0.3
             usingSpringWithDamping:0.8
              initialSpringVelocity:0.5
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
            self.helpLabel.alpha = 1.0;
            self.helpLabel.transform = CGAffineTransformIdentity;
        } completion:nil];
    }
}

- (void)updateCardLayerFrames {
    if (!glassCard) return;

    // Update all sublayer frames to match card bounds
    for (CALayer *layer in glassCard.layer.sublayers) {
        if ([layer isKindOfClass:[CAGradientLayer class]] && layer != shimmerLayer) {
            layer.frame = glassCard.bounds;
        }
    }

    // Update border shape
    if (borderGradient && borderGradient.mask) {
        CAShapeLayer *borderShape = (CAShapeLayer *)borderGradient.mask;
        CGRect borderRect = CGRectInset(glassCard.bounds, 1, 1);
        borderShape.path = [UIBezierPath bezierPathWithRoundedRect:borderRect cornerRadius:23].CGPath;
        borderGradient.frame = glassCard.bounds;
    }

    // Update shimmer layer
    if (shimmerLayer) {
        shimmerLayer.frame = CGRectMake(-glassCard.bounds.size.width, 0,
                                         glassCard.bounds.size.width * 2,
                                         glassCard.bounds.size.height);
    }
}

- (void)buttonTouchDown:(UIButton *)button {
    UIImpactFeedbackGenerator *haptic = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    [haptic impactOccurred];

    [UIView animateWithDuration:0.15
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        button.transform = CGAffineTransformMakeScale(0.95, 0.95);
        button.layer.shadowOpacity = 0.3;
        button.alpha = 0.9;
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
        button.layer.shadowOpacity = 0.5;
        button.alpha = 1.0;
    } completion:nil];
}

@end
