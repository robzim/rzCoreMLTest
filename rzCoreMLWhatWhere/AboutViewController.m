//
//  AboutViewController.m
//  rzCoreMLWhatWhere
//
//  Modern about screen with gradient background and model metadata
//

#import "AboutViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "FastViTMA36F16.h"
#import "FastViTT8F16.h"
#import "MobileNetV2FP16.h"
#import "MobileNetV2Int8LUT.h"
#import "Resnet50FP16.h"
#import "Resnet50Int8LUT.h"

@implementation AboutViewController

@synthesize backgroundGradient;
@synthesize aboutLabel;
@synthesize okButton;
@synthesize glassCard;
@synthesize scrollView;
@synthesize scrollableLabel;
@synthesize shimmerLayer;
@synthesize borderGradient;

static bool hasAppliedAboutStyling = false;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    hasAppliedAboutStyling = false;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    if (!hasAppliedAboutStyling) {
        [self applyModernDesign];
        hasAppliedAboutStyling = true;
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

- (IBAction)dismissAbout:(id)sender {
    UIImpactFeedbackGenerator *haptic = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    [haptic impactOccurred];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Model Metadata

- (NSString *)getModelDescriptions {
    NSMutableString *descriptions = [NSMutableString string];

    [descriptions appendString:@"About Local AI Brilliance\n\n"];
    [descriptions appendString:@"This app demonstrates the power of Apple's CoreML framework, running sophisticated AI models entirely on your device.\n\n"];
    [descriptions appendString:@"━━━━━━━━━━━━━━━━━━━━━━\n\n"];

    // FastViT MA36
    @try {
        FastViTMA36F16 *fastVitMA36 = [[FastViTMA36F16 alloc] init];
        MLModelDescription *desc = fastVitMA36.model.modelDescription;
        [descriptions appendString:@"FastViT-MA36 (FP16)\n"];
        [descriptions appendFormat:@"%@\n\n", desc.metadata[MLModelDescriptionKey] ?: @"High-accuracy vision transformer optimized for mobile devices with hybrid architecture."];
    } @catch (NSException *e) {
        [descriptions appendString:@"FastViT-MA36 (FP16)\nHigh-accuracy vision transformer optimized for mobile devices.\n\n"];
    }

    // FastViT T8
    @try {
        FastViTT8F16 *fastVitT8 = [[FastViTT8F16 alloc] init];
        MLModelDescription *desc = fastVitT8.model.modelDescription;
        [descriptions appendString:@"FastViT-T8 (FP16)\n"];
        [descriptions appendFormat:@"%@\n\n", desc.metadata[MLModelDescriptionKey] ?: @"Lightweight vision transformer for ultra-fast inference on mobile."];
    } @catch (NSException *e) {
        [descriptions appendString:@"FastViT-T8 (FP16)\nLightweight vision transformer for ultra-fast inference.\n\n"];
    }

    // MobileNetV2 FP16
    @try {
        MobileNetV2FP16 *mobileNetFP16 = [[MobileNetV2FP16 alloc] init];
        MLModelDescription *desc = mobileNetFP16.model.modelDescription;
        [descriptions appendString:@"MobileNetV2 (FP16)\n"];
        [descriptions appendFormat:@"%@\n\n", desc.metadata[MLModelDescriptionKey] ?: @"Efficient convolutional neural network designed for mobile vision applications."];
    } @catch (NSException *e) {
        [descriptions appendString:@"MobileNetV2 (FP16)\nEfficient CNN designed for mobile vision applications.\n\n"];
    }

    // MobileNetV2 Int8
    @try {
        MobileNetV2Int8LUT *mobileNetInt8 = [[MobileNetV2Int8LUT alloc] init];
        MLModelDescription *desc = mobileNetInt8.model.modelDescription;
        [descriptions appendString:@"MobileNetV2 (Int8 LUT)\n"];
        [descriptions appendFormat:@"%@\n\n", desc.metadata[MLModelDescriptionKey] ?: @"Quantized MobileNetV2 with lookup table optimization for minimal memory usage."];
    } @catch (NSException *e) {
        [descriptions appendString:@"MobileNetV2 (Int8 LUT)\nQuantized model with lookup table optimization.\n\n"];
    }

    // ResNet50 FP16
    @try {
        Resnet50FP16 *resnet50FP16 = [[Resnet50FP16 alloc] init];
        MLModelDescription *desc = resnet50FP16.model.modelDescription;
        [descriptions appendString:@"ResNet-50 (FP16)\n"];
        [descriptions appendFormat:@"%@\n\n", desc.metadata[MLModelDescriptionKey] ?: @"Deep residual network with 50 layers, excellent for image classification tasks."];
    } @catch (NSException *e) {
        [descriptions appendString:@"ResNet-50 (FP16)\nDeep residual network with 50 layers.\n\n"];
    }

    // ResNet50 Int8
    @try {
        Resnet50Int8LUT *resnet50Int8 = [[Resnet50Int8LUT alloc] init];
        MLModelDescription *desc = resnet50Int8.model.modelDescription;
        [descriptions appendString:@"ResNet-50 (Int8 LUT)\n"];
        [descriptions appendFormat:@"%@\n\n", desc.metadata[MLModelDescriptionKey] ?: @"Quantized ResNet-50 optimized for speed and reduced memory footprint."];
    } @catch (NSException *e) {
        [descriptions appendString:@"ResNet-50 (Int8 LUT)\nQuantized ResNet-50 for speed optimization.\n\n"];
    }

    [descriptions appendString:@"━━━━━━━━━━━━━━━━━━━━━━\n\n"];
    [descriptions appendString:@"All models run 100% locally on your device. No internet connection required. Your photos never leave your device.\n\n"];
    [descriptions appendString:@"Developed with CoreML and the Neural Engine for maximum performance."];

    return descriptions;
}

#pragma mark - Modern Design

- (void)applyModernDesign {
    [self applyGradientBackground];
    [self styleAboutLabel];
    [self styleAllButtons];
    [self addAIBrainAnimation];
}

- (void)applyGradientBackground {
    backgroundGradient = [CAGradientLayer layer];
    backgroundGradient.frame = self.view.bounds;

    // Slightly different gradient - more purple tones for About
    UIColor *topColor = [UIColor colorWithRed:0.08 green:0.02 blue:0.18 alpha:1.0];
    UIColor *middleColor = [UIColor colorWithRed:0.1 green:0.05 blue:0.22 alpha:1.0];
    UIColor *bottomColor = [UIColor colorWithRed:0.03 green:0.02 blue:0.1 alpha:1.0];

    backgroundGradient.colors = @[(id)topColor.CGColor,
                                   (id)middleColor.CGColor,
                                   (id)bottomColor.CGColor];
    backgroundGradient.locations = @[@0.0, @0.5, @1.0];
    backgroundGradient.startPoint = CGPointMake(0.0, 0.0);
    backgroundGradient.endPoint = CGPointMake(1.0, 1.0);

    [self.view.layer insertSublayer:backgroundGradient atIndex:0];
}

- (void)styleAboutLabel {
    // Hide the original label - we'll use our own scrollable content
    if (aboutLabel) {
        aboutLabel.hidden = YES;
    }

    // Create ultra-modern glassmorphic card
    glassCard = [[UIView alloc] init];
    glassCard.translatesAutoresizingMaskIntoConstraints = NO;
    glassCard.layer.cornerRadius = 24;
    glassCard.clipsToBounds = YES;

    [self.view addSubview:glassCard];

    // Position the card
    [NSLayoutConstraint activateConstraints:@[
        [glassCard.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [glassCard.bottomAnchor constraintEqualToAnchor:okButton.topAnchor constant:-20],
        [glassCard.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [glassCard.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20]
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
    glassGradient.name = @"glassGradient";
    [glassCard.layer addSublayer:glassGradient];

    // Animated border
    [self addAnimatedBorderToCard];

    // Inner glow highlight at top
    CAGradientLayer *innerGlow = [CAGradientLayer layer];
    innerGlow.frame = CGRectMake(0, 0, glassCard.bounds.size.width, 80);
    innerGlow.colors = @[
        (id)[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.12].CGColor,
        (id)[UIColor clearColor].CGColor
    ];
    innerGlow.startPoint = CGPointMake(0.5, 0.0);
    innerGlow.endPoint = CGPointMake(0.5, 1.0);
    innerGlow.name = @"innerGlow";
    [glassCard.layer addSublayer:innerGlow];

    // Add shimmer effect
    [self addShimmerEffect];

    // Create scroll view for content
    scrollView = [[UIScrollView alloc] init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    scrollView.showsVerticalScrollIndicator = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    scrollView.bounces = YES;
    scrollView.alwaysBounceVertical = YES;
    [glassCard addSubview:scrollView];

    [NSLayoutConstraint activateConstraints:@[
        [scrollView.topAnchor constraintEqualToAnchor:glassCard.topAnchor constant:20],
        [scrollView.bottomAnchor constraintEqualToAnchor:glassCard.bottomAnchor constant:-20],
        [scrollView.leadingAnchor constraintEqualToAnchor:glassCard.leadingAnchor constant:20],
        [scrollView.trailingAnchor constraintEqualToAnchor:glassCard.trailingAnchor constant:-20]
    ]];

    // Create scrollable label with model descriptions
    scrollableLabel = [[UILabel alloc] init];
    scrollableLabel.translatesAutoresizingMaskIntoConstraints = NO;
    scrollableLabel.numberOfLines = 0;
    scrollableLabel.textAlignment = NSTextAlignmentLeft;

    // Style the text with neon glow
    UIColor *textColor = [UIColor colorWithRed:0.9 green:0.95 blue:1.0 alpha:1.0];
    scrollableLabel.textColor = textColor;
    scrollableLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    scrollableLabel.layer.shadowColor = [UIColor colorWithRed:0.4 green:0.6 blue:1.0 alpha:1.0].CGColor;
    scrollableLabel.layer.shadowOffset = CGSizeZero;
    scrollableLabel.layer.shadowRadius = 4;
    scrollableLabel.layer.shadowOpacity = 0.5;

    // Set the model descriptions text
    scrollableLabel.text = [self getModelDescriptions];

    [scrollView addSubview:scrollableLabel];

    [NSLayoutConstraint activateConstraints:@[
        [scrollableLabel.topAnchor constraintEqualToAnchor:scrollView.topAnchor],
        [scrollableLabel.bottomAnchor constraintEqualToAnchor:scrollView.bottomAnchor],
        [scrollableLabel.leadingAnchor constraintEqualToAnchor:scrollView.leadingAnchor],
        [scrollableLabel.widthAnchor constraintEqualToAnchor:scrollView.widthAnchor]
    ]];

    // Outer glow shadow on card
    glassCard.layer.masksToBounds = NO;
    glassCard.clipsToBounds = NO;
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
        (id)[UIColor colorWithRed:0.5 green:0.2 blue:1.0 alpha:0.8].CGColor,
        (id)[UIColor colorWithRed:0.7 green:0.3 blue:1.0 alpha:0.6].CGColor,
        (id)[UIColor colorWithRed:0.3 green:0.7 blue:1.0 alpha:0.8].CGColor,
        (id)[UIColor colorWithRed:0.6 green:0.2 blue:0.9 alpha:0.6].CGColor,
        (id)[UIColor colorWithRed:0.5 green:0.2 blue:1.0 alpha:0.8].CGColor
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
        (id)[UIColor colorWithWhite:1.0 alpha:0.02].CGColor,
        (id)[UIColor colorWithWhite:1.0 alpha:0.08].CGColor,
        (id)[UIColor colorWithWhite:1.0 alpha:0.02].CGColor,
        (id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor
    ];
    shimmerLayer.locations = @[@0.0, @0.35, @0.5, @0.65, @1.0];
    shimmerLayer.startPoint = CGPointMake(0.0, 0.5);
    shimmerLayer.endPoint = CGPointMake(1.0, 0.5);

    [glassCard.layer addSublayer:shimmerLayer];
}

- (void)updateCardLayerFrames {
    if (!glassCard) return;

    // Update all sublayer frames to match card bounds
    for (CALayer *layer in glassCard.layer.sublayers) {
        if ([layer isKindOfClass:[CAGradientLayer class]] && layer != shimmerLayer) {
            if ([layer.name isEqualToString:@"innerGlow"]) {
                layer.frame = CGRectMake(0, 0, glassCard.bounds.size.width, 80);
            } else {
                layer.frame = glassCard.bounds;
            }
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

- (void)startCardAnimations {
    // Border gradient color animation
    CABasicAnimation *borderAnimation = [CABasicAnimation animationWithKeyPath:@"colors"];
    borderAnimation.toValue = @[
        (id)[UIColor colorWithRed:0.3 green:0.7 blue:1.0 alpha:0.8].CGColor,
        (id)[UIColor colorWithRed:0.6 green:0.2 blue:0.9 alpha:0.6].CGColor,
        (id)[UIColor colorWithRed:0.5 green:0.2 blue:1.0 alpha:0.8].CGColor,
        (id)[UIColor colorWithRed:0.7 green:0.3 blue:1.0 alpha:0.6].CGColor,
        (id)[UIColor colorWithRed:0.3 green:0.7 blue:1.0 alpha:0.8].CGColor
    ];
    borderAnimation.duration = 3.0;
    borderAnimation.autoreverses = YES;
    borderAnimation.repeatCount = HUGE_VALF;
    [borderGradient addAnimation:borderAnimation forKey:@"borderColorShift"];

    // Shimmer sweep animation
    CABasicAnimation *shimmerAnimation = [CABasicAnimation animationWithKeyPath:@"position.x"];
    shimmerAnimation.fromValue = @(-glassCard.bounds.size.width);
    shimmerAnimation.toValue = @(glassCard.bounds.size.width * 2);
    shimmerAnimation.duration = 5.0;
    shimmerAnimation.repeatCount = HUGE_VALF;
    shimmerAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [shimmerLayer addAnimation:shimmerAnimation forKey:@"shimmerSweep"];

    // Subtle pulse glow on card
    CABasicAnimation *glowPulse = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    glowPulse.fromValue = @(0.3);
    glowPulse.toValue = @(0.6);
    glowPulse.duration = 2.5;
    glowPulse.autoreverses = YES;
    glowPulse.repeatCount = HUGE_VALF;
    glowPulse.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

    glassCard.layer.shadowColor = [UIColor colorWithRed:0.5 green:0.3 blue:1.0 alpha:1.0].CGColor;
    glassCard.layer.shadowOffset = CGSizeZero;
    glassCard.layer.shadowRadius = 25;
    glassCard.layer.shadowOpacity = 0.4;
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

    UIColor *gradientStart = [UIColor colorWithRed:0.35 green:0.2 blue:0.65 alpha:1.0];
    UIColor *gradientEnd = [UIColor colorWithRed:0.2 green:0.1 blue:0.45 alpha:1.0];
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
    button.layer.shadowColor = [UIColor colorWithRed:0.5 green:0.3 blue:0.9 alpha:1.0].CGColor;
    button.layer.shadowOffset = CGSizeMake(0, 4);
    button.layer.shadowRadius = 10;
    button.layer.shadowOpacity = 0.5;

    // Border glow
    button.layer.borderWidth = 1.0;
    button.layer.borderColor = [UIColor colorWithRed:0.6 green:0.4 blue:1.0 alpha:0.6].CGColor;

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

- (void)addAIBrainAnimation {
    // Add floating neural network dots
    CAEmitterLayer *emitter = [CAEmitterLayer layer];
    emitter.emitterPosition = CGPointMake(self.view.bounds.size.width / 2, 80);
    emitter.emitterShape = kCAEmitterLayerCircle;
    emitter.emitterSize = CGSizeMake(150, 150);

    CAEmitterCell *neuron = [CAEmitterCell emitterCell];
    neuron.birthRate = 2;
    neuron.lifetime = 8.0;
    neuron.velocity = 15;
    neuron.velocityRange = 10;
    neuron.emissionRange = M_PI * 2;
    neuron.scale = 0.08;
    neuron.scaleRange = 0.04;
    neuron.alphaSpeed = -0.1;

    // Create a glowing neuron circle
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(20, 20), NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0.6 green:0.4 blue:1.0 alpha:0.7].CGColor);
    CGContextFillEllipseInRect(ctx, CGRectMake(0, 0, 20, 20));
    UIImage *neuronImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    neuron.contents = (id)neuronImage.CGImage;

    emitter.emitterCells = @[neuron];
    [self.view.layer insertSublayer:emitter atIndex:1];
}

#pragma mark - Animations

- (void)animateEntrance {
    // Animate glass card with dramatic entrance
    if (glassCard) {
        glassCard.alpha = 0;
        glassCard.transform = CGAffineTransformMakeScale(0.85, 0.85);

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

    // Flash the scroll indicator to show content is scrollable
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.scrollView flashScrollIndicators];
    });
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
