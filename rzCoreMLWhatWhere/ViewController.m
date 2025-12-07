//
//  ViewController.m
//  rzCoreMLWhatWhere
//
//  Created by Robert Zimmelman on 7/8/17.
//  Copyright © 2017 Robert Zimmelman. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>


@implementation ViewController
@synthesize myFastViTMA36Model;
@synthesize myFastViTT8Model;
@synthesize myMobileNetV2FP16Model;
@synthesize myMobileNetV2Int8Model;
@synthesize myResnet50FP16Model;
@synthesize myResnet50Int8Model;
@synthesize myImage;
@synthesize myPicker;
@synthesize myCameraPicker;
@synthesize myFastViTMA36Category;
@synthesize myFastViTT8Category;
@synthesize myMobileNetV2FP16Category;
@synthesize myMobileNetV2Int8Category;
@synthesize myResnet50FP16Category;
@synthesize myResnet50Int8Category;
@synthesize myActivityIndicator;
@synthesize myPlaceHolderText;
@synthesize myAnalyzeButton;
@synthesize myFastViTMA36Pct;
@synthesize myFastViTT8Pct;
@synthesize myMobileNetV2FP16Pct;
@synthesize myMobileNetV2Int8Pct;
@synthesize myResnet50FP16Pct;
@synthesize myResnet50Int8Pct;
@synthesize myFastViTMA36Label;
@synthesize myFastViTT8Label;
@synthesize myMobileNetV2FP16Label;
@synthesize myMobileNetV2Int8Label;
@synthesize myResnet50FP16Label;
@synthesize myResnet50Int8Label;
@synthesize backgroundGradient;
@synthesize hapticLight;
@synthesize hapticMedium;
@synthesize hapticNotification;
@synthesize resultRows;
@synthesize originalCenters;
@synthesize welcomeOverlay;
@synthesize welcomeCard;
@synthesize welcomeShimmerLayer;
@synthesize welcomeBorderGradient;
@synthesize resultsContainerView;
@synthesize resultsTableView;
@synthesize resultsData;
@synthesize mainStackView;
@synthesize isAnimatingResults;
@synthesize celebrationEmitter;
@synthesize celebrationIndex;

float myFastViTMA36PctVal;
float myFastViTT8PctVal;
float myMobileNetV2FP16PctVal;
float myMobileNetV2Int8PctVal;
float myResnet50FP16PctVal;
float myResnet50Int8PctVal;

bool hasAppliedStyling = false;
bool myWelcomeMessageWasShownOnce = false;

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    // Clear placeholder labels immediately
    [self myClearTheLabels];

    // Initialize latest 2024 CoreML models
    myFastViTMA36Model = [[FastViTMA36F16 alloc] init];
    myFastViTT8Model = [[FastViTT8F16 alloc] init];
    myMobileNetV2FP16Model = [[MobileNetV2FP16 alloc] init];
    myMobileNetV2Int8Model = [[MobileNetV2Int8LUT alloc] init];
    myResnet50FP16Model = [[Resnet50FP16 alloc] init];
    myResnet50Int8Model = [[Resnet50Int8LUT alloc] init];

    // Initialize haptic generators
    hapticLight = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    hapticMedium = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    hapticNotification = [[UINotificationFeedbackGenerator alloc] init];
    [hapticLight prepare];
    [hapticMedium prepare];
    [hapticNotification prepare];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    // Apply modern styling only once
    if (!hasAppliedStyling) {
        [self applyModernDesign];
        hasAppliedStyling = true;
    }

    // Update gradient frame on layout changes
    if (backgroundGradient) {
        backgroundGradient.frame = self.view.bounds;
    }

    if (myWelcomeMessageWasShownOnce) {
        return;
    } else {
        // Show welcome message first, analysis will run when user taps OK or returns from Help
        [self myShowWelcomeMessage];
        myWelcomeMessageWasShownOnce = true;
    }
}


- (void)myStartAnimating{
    [myActivityIndicator startAnimating];
}


- (IBAction)mySetupTheView {
    [self myClearTheLabels];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)myClearTheLabels{
    myPlaceHolderText = @" ";
    [myFastViTMA36Category setText:myPlaceHolderText];
    [myFastViTT8Category setText:myPlaceHolderText];
    [myMobileNetV2FP16Category setText:myPlaceHolderText];
    [myMobileNetV2Int8Category setText:myPlaceHolderText];
    [myResnet50FP16Category setText:myPlaceHolderText];
    [myResnet50Int8Category setText:myPlaceHolderText];
    [myFastViTMA36Pct setText:myPlaceHolderText];
    [myFastViTT8Pct setText:myPlaceHolderText];
    [myMobileNetV2FP16Pct setText:myPlaceHolderText];
    [myMobileNetV2Int8Pct setText:myPlaceHolderText];
    [myResnet50FP16Pct setText:myPlaceHolderText];
    [myResnet50Int8Pct setText:myPlaceHolderText];

    // Reset all label transforms and shadows for fresh analysis
    NSArray *allLabels = @[myFastViTMA36Label, myFastViTMA36Pct, myFastViTMA36Category,
                           myFastViTT8Label, myFastViTT8Pct, myFastViTT8Category,
                           myMobileNetV2FP16Label, myMobileNetV2FP16Pct, myMobileNetV2FP16Category,
                           myMobileNetV2Int8Label, myMobileNetV2Int8Pct, myMobileNetV2Int8Category,
                           myResnet50FP16Label, myResnet50FP16Pct, myResnet50FP16Category,
                           myResnet50Int8Label, myResnet50Int8Pct, myResnet50Int8Category];

    for (UILabel *label in allLabels) {
        if (label) {
            label.transform = CGAffineTransformIdentity;
            label.alpha = 1.0;
            label.layer.shadowOpacity = 0;
        }
    }
}

- (IBAction)unwindToThisViewController:(UIStoryboardSegue *)unwindSegue{
    [myActivityIndicator stopAnimating];
    NSLog(@"segue returned here");

    // Run analysis after returning from Help/About screen
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self myClearTheLabels];
        [self myAnalyzeButtonWasPressed:self];
    });
}


- (void)myAnalyzeTheImage{
    [self myClearTheLabels];

    // Clear previous results
    [resultsData removeAllObjects];

    // Track if any model has high confidence for celebration
    __block BOOL hasHighConfidence = NO;

    // FastViT MA36 (High Accuracy Model) - 256x256 input
    CVPixelBufferRef myFastViTMA36PixelBufferRef = [self myMakePixelBufferWithImage:myImage.image ofSize:256.0];
    FastViTMA36F16Output *myFastViTMA36Output = [myFastViTMA36Model predictionFromImage:myFastViTMA36PixelBufferRef error:nil];
    myFastViTMA36PctVal = ([[myFastViTMA36Output.classLabel_probs valueForKey:myFastViTMA36Output.classLabel] floatValue]*100.0);
    if (myFastViTMA36PctVal > 80.0) hasHighConfidence = YES;

    [resultsData addObject:@{
        @"model": @"FastViT MA36",
        @"item": myFastViTMA36Output.classLabel ?: @"Unknown",
        @"confidence": @(myFastViTMA36PctVal)
    }];

    // FastViT T8 (Fast Model) - 256x256 input
    CVPixelBufferRef myFastViTT8PixelBufferRef = [self myMakePixelBufferWithImage:myImage.image ofSize:256.0];
    FastViTT8F16Output *myFastViTT8Output = [myFastViTT8Model predictionFromImage:myFastViTT8PixelBufferRef error:nil];
    myFastViTT8PctVal = ([[myFastViTT8Output.classLabel_probs valueForKey:myFastViTT8Output.classLabel] floatValue]*100.0);
    if (myFastViTT8PctVal > 80.0) hasHighConfidence = YES;

    [resultsData addObject:@{
        @"model": @"FastViT T8",
        @"item": myFastViTT8Output.classLabel ?: @"Unknown",
        @"confidence": @(myFastViTT8PctVal)
    }];

    // MobileNetV2 FP16 - 224x224 input
    CVPixelBufferRef myMobileNetV2FP16PixelBufferRef = [self myMakePixelBufferWithImage:myImage.image ofSize:224.0];
    MobileNetV2FP16Output *myMobileNetV2FP16Output = [myMobileNetV2FP16Model predictionFromImage:myMobileNetV2FP16PixelBufferRef error:nil];
    myMobileNetV2FP16PctVal = ([[myMobileNetV2FP16Output.classLabelProbs valueForKey:myMobileNetV2FP16Output.classLabel] floatValue]*100.0);
    if (myMobileNetV2FP16PctVal > 80.0) hasHighConfidence = YES;

    [resultsData addObject:@{
        @"model": @"MobileNet FP16",
        @"item": myMobileNetV2FP16Output.classLabel ?: @"Unknown",
        @"confidence": @(myMobileNetV2FP16PctVal)
    }];

    // MobileNetV2 Int8 (Quantized, fastest) - 224x224 input
    CVPixelBufferRef myMobileNetV2Int8PixelBufferRef = [self myMakePixelBufferWithImage:myImage.image ofSize:224.0];
    MobileNetV2Int8LUTOutput *myMobileNetV2Int8Output = [myMobileNetV2Int8Model predictionFromImage:myMobileNetV2Int8PixelBufferRef error:nil];
    myMobileNetV2Int8PctVal = ([[myMobileNetV2Int8Output.classLabelProbs valueForKey:myMobileNetV2Int8Output.classLabel] floatValue]*100.0);
    if (myMobileNetV2Int8PctVal > 80.0) hasHighConfidence = YES;

    [resultsData addObject:@{
        @"model": @"MobileNet Int8",
        @"item": myMobileNetV2Int8Output.classLabel ?: @"Unknown",
        @"confidence": @(myMobileNetV2Int8PctVal)
    }];

    // Resnet50 FP16 - 224x224 input
    CVPixelBufferRef myResnet50FP16PixelBufferRef = [self myMakePixelBufferWithImage:myImage.image ofSize:224.0];
    Resnet50FP16Output *myResnet50FP16Output = [myResnet50FP16Model predictionFromImage:myResnet50FP16PixelBufferRef error:nil];
    myResnet50FP16PctVal = ([[myResnet50FP16Output.classLabelProbs valueForKey:myResnet50FP16Output.classLabel] floatValue]*100.0);
    if (myResnet50FP16PctVal > 80.0) hasHighConfidence = YES;

    [resultsData addObject:@{
        @"model": @"ResNet50 FP16",
        @"item": myResnet50FP16Output.classLabel ?: @"Unknown",
        @"confidence": @(myResnet50FP16PctVal)
    }];

    // Resnet50 Int8 (Quantized) - 224x224 input
    CVPixelBufferRef myResnet50Int8PixelBufferRef = [self myMakePixelBufferWithImage:myImage.image ofSize:224.0];
    Resnet50Int8LUTOutput *myResnet50Int8Output = [myResnet50Int8Model predictionFromImage:myResnet50Int8PixelBufferRef error:nil];
    myResnet50Int8PctVal = ([[myResnet50Int8Output.classLabelProbs valueForKey:myResnet50Int8Output.classLabel] floatValue]*100.0);
    if (myResnet50Int8PctVal > 80.0) hasHighConfidence = YES;

    [resultsData addObject:@{
        @"model": @"ResNet50 Int8",
        @"item": myResnet50Int8Output.classLabel ?: @"Unknown",
        @"confidence": @(myResnet50Int8PctVal)
    }];

    // Update table with animation (sorts by confidence)
    [self updateResultsTableWithAnimation];

    // Always celebrate with variety - different celebration each time!
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self celebrateWithVariety:hasHighConfidence];
    });
}

- (IBAction)myTakeAPhoto:(id)sender {
    [hapticMedium impactOccurred];
    [self myClearTheLabels];
    [myActivityIndicator startAnimating];
    bool myTest1 = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    myCameraPicker = [[ UIImagePickerController alloc] init];
    myCameraPicker.delegate = self;
    myCameraPicker.allowsEditing = YES;
    if (myTest1) {
        [myCameraPicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        [self presentViewController:myCameraPicker animated:YES completion:nil];
    }
    else {
        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"No Camera" message:@"This device has no camera or the camera is disabled.  Select images from the Photo Library." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *myAlertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.myCameraPicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            [self presentViewController:self.myCameraPicker animated:YES completion:nil];
        }];
        [myAlertController addAction:myAlertAction];
        [self presentViewController:myAlertController animated:YES completion:nil ];
    }
}

- (IBAction)myPickAnImage:(id)sender {
    [hapticMedium impactOccurred];
    [self myClearTheLabels];
    [myActivityIndicator startAnimating];
    myPicker = [[ UIImagePickerController alloc] init];
    [myPicker setDelegate:self];
    [myPicker setAllowsEditing:YES];
    [myPicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:myPicker animated:YES completion:nil];
}

- (IBAction)myAnalyzeButtonWasPressed:(id)sender {
    [hapticLight impactOccurred];
    [self performSelectorOnMainThread:@selector(myClearTheLabels) withObject:self waitUntilDone:true];
    [self performSelectorOnMainThread:@selector(myStartAnimating) withObject:myActivityIndicator waitUntilDone:true];

    // Start pulse animation on image during analysis
    [self pulseImageDuringAnalysis];

    NSLog(@"analysis starts");
    [self myAnalyzeTheImage];
    NSLog(@"analysis ends");
    NSLog(@"animating  %d",myActivityIndicator.isAnimating);

    // Stop pulse animation
    [self stopImagePulse];
    [myActivityIndicator stopAnimating];
}


- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    myImage.image = [ info objectForKey:UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        [self.myActivityIndicator stopAnimating];
        [self myAnalyzeButtonWasPressed:self];
    }];
}


-(void) myShowWelcomeMessage {
    // Create full-screen overlay with blur
    welcomeOverlay = [[UIView alloc] initWithFrame:self.view.bounds];
    welcomeOverlay.backgroundColor = [UIColor clearColor];
    welcomeOverlay.alpha = 0;

    // Blur background
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.frame = welcomeOverlay.bounds;
    blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [welcomeOverlay addSubview:blurView];

    [self.view addSubview:welcomeOverlay];

    // Create glassmorphic card
    CGFloat cardWidth = MIN(self.view.bounds.size.width - 40, 380);
    CGFloat cardHeight = 420;
    welcomeCard = [[UIView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - cardWidth) / 2,
                                                            (self.view.bounds.size.height - cardHeight) / 2,
                                                            cardWidth, cardHeight)];
    welcomeCard.layer.cornerRadius = 28;
    welcomeCard.clipsToBounds = YES;
    welcomeCard.alpha = 0;
    welcomeCard.transform = CGAffineTransformMakeScale(0.8, 0.8);

    [welcomeOverlay addSubview:welcomeCard];

    // Glass blur layer
    UIVisualEffectView *cardBlur = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    cardBlur.frame = welcomeCard.bounds;
    cardBlur.alpha = 0.85;
    [welcomeCard addSubview:cardBlur];

    // Gradient overlay
    CAGradientLayer *glassGradient = [CAGradientLayer layer];
    glassGradient.frame = welcomeCard.bounds;
    glassGradient.colors = @[
        (id)[UIColor colorWithRed:0.25 green:0.1 blue:0.45 alpha:0.7].CGColor,
        (id)[UIColor colorWithRed:0.12 green:0.05 blue:0.28 alpha:0.5].CGColor,
        (id)[UIColor colorWithRed:0.18 green:0.08 blue:0.38 alpha:0.6].CGColor
    ];
    glassGradient.locations = @[@0.0, @0.5, @1.0];
    glassGradient.startPoint = CGPointMake(0.0, 0.0);
    glassGradient.endPoint = CGPointMake(1.0, 1.0);
    [welcomeCard.layer addSublayer:glassGradient];

    // Animated border
    [self addWelcomeBorder];

    // Inner glow at top
    CAGradientLayer *innerGlow = [CAGradientLayer layer];
    innerGlow.frame = CGRectMake(0, 0, cardWidth, 100);
    innerGlow.colors = @[
        (id)[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.18].CGColor,
        (id)[UIColor clearColor].CGColor
    ];
    innerGlow.startPoint = CGPointMake(0.5, 0.0);
    innerGlow.endPoint = CGPointMake(0.5, 1.0);
    [welcomeCard.layer addSublayer:innerGlow];

    // Shimmer effect
    [self addWelcomeShimmer];

    // Title label with glow
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 25, cardWidth - 40, 40)];
    titleLabel.text = @"Welcome!";
    titleLabel.font = [UIFont boldSystemFontOfSize:32];
    titleLabel.textColor = [UIColor colorWithRed:0.7 green:0.9 blue:1.0 alpha:1.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.layer.shadowColor = [UIColor colorWithRed:0.3 green:0.7 blue:1.0 alpha:1.0].CGColor;
    titleLabel.layer.shadowOffset = CGSizeZero;
    titleLabel.layer.shadowRadius = 15;
    titleLabel.layer.shadowOpacity = 1.0;
    [welcomeCard addSubview:titleLabel];

    // Subtitle
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 70, cardWidth - 40, 25)];
    subtitleLabel.text = @"Local AI Brilliance";
    subtitleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    subtitleLabel.textColor = [UIColor colorWithRed:0.6 green:0.5 blue:1.0 alpha:0.9];
    subtitleLabel.textAlignment = NSTextAlignmentCenter;
    [welcomeCard addSubview:subtitleLabel];

    // Divider line
    UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(30, 105, cardWidth - 60, 1)];
    divider.backgroundColor = [UIColor colorWithRed:0.5 green:0.4 blue:0.8 alpha:0.4];
    [welcomeCard addSubview:divider];

    // Message label
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 115, cardWidth - 50, 200)];
    messageLabel.text = @"Experience the power of Apple's 2024 CoreML models running entirely on your device.\n\n"
                        @"Featuring FastViT Vision Transformers, MobileNetV2 (FP16 & Quantized), and ResNet50 variants.\n\n"
                        @"Select images from your Photo Library or capture with your camera. No images are saved or uploaded.";
    messageLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    messageLabel.textColor = [UIColor colorWithRed:0.92 green:0.94 blue:1.0 alpha:1.0];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.numberOfLines = 0;
    messageLabel.layer.shadowColor = [UIColor colorWithRed:0.4 green:0.5 blue:1.0 alpha:1.0].CGColor;
    messageLabel.layer.shadowOffset = CGSizeZero;
    messageLabel.layer.shadowRadius = 3;
    messageLabel.layer.shadowOpacity = 0.4;
    [welcomeCard addSubview:messageLabel];

    // OK Button
    UIButton *okButton = [[UIButton alloc] initWithFrame:CGRectMake((cardWidth - 160) / 2, cardHeight - 70, 160, 50)];
    okButton.layer.cornerRadius = 25;
    okButton.clipsToBounds = NO;

    // Button gradient
    CAGradientLayer *buttonGradient = [CAGradientLayer layer];
    buttonGradient.frame = okButton.bounds;
    buttonGradient.cornerRadius = 25;
    buttonGradient.colors = @[
        (id)[UIColor colorWithRed:0.45 green:0.25 blue:0.85 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.3 green:0.15 blue:0.6 alpha:1.0].CGColor
    ];
    buttonGradient.startPoint = CGPointMake(0.0, 0.0);
    buttonGradient.endPoint = CGPointMake(1.0, 1.0);
    [okButton.layer insertSublayer:buttonGradient atIndex:0];

    // Button styling
    [okButton setTitle:@"Let's Go!" forState:UIControlStateNormal];
    [okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    okButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    okButton.layer.shadowColor = [UIColor colorWithRed:0.5 green:0.3 blue:1.0 alpha:1.0].CGColor;
    okButton.layer.shadowOffset = CGSizeMake(0, 5);
    okButton.layer.shadowRadius = 15;
    okButton.layer.shadowOpacity = 0.7;
    okButton.layer.borderWidth = 1.5;
    okButton.layer.borderColor = [UIColor colorWithRed:0.6 green:0.5 blue:1.0 alpha:0.6].CGColor;

    [okButton addTarget:self action:@selector(welcomeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [okButton addTarget:self action:@selector(welcomeButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [okButton addTarget:self action:@selector(welcomeButtonTouchUp:) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchCancel];

    [welcomeCard addSubview:okButton];

    // Card outer glow
    welcomeCard.layer.masksToBounds = NO;
    welcomeCard.clipsToBounds = NO;
    welcomeCard.layer.shadowColor = [UIColor colorWithRed:0.5 green:0.3 blue:1.0 alpha:1.0].CGColor;
    welcomeCard.layer.shadowOffset = CGSizeZero;
    welcomeCard.layer.shadowRadius = 30;
    welcomeCard.layer.shadowOpacity = 0.6;

    // Animate entrance
    [UIView animateWithDuration:0.4 animations:^{
        self.welcomeOverlay.alpha = 1.0;
    }];

    [UIView animateWithDuration:0.7
                          delay:0.1
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.welcomeCard.alpha = 1.0;
        self.welcomeCard.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self startWelcomeAnimations];
    }];

    NSLog(@"showed the welcome message");
}

- (void)addWelcomeBorder {
    CAShapeLayer *borderShape = [CAShapeLayer layer];
    CGRect borderRect = CGRectInset(welcomeCard.bounds, 1, 1);
    borderShape.path = [UIBezierPath bezierPathWithRoundedRect:borderRect cornerRadius:27].CGPath;
    borderShape.fillColor = [UIColor clearColor].CGColor;
    borderShape.strokeColor = [UIColor whiteColor].CGColor;
    borderShape.lineWidth = 2.0;

    welcomeBorderGradient = [CAGradientLayer layer];
    welcomeBorderGradient.frame = welcomeCard.bounds;
    welcomeBorderGradient.colors = @[
        (id)[UIColor colorWithRed:0.5 green:0.3 blue:1.0 alpha:0.9].CGColor,
        (id)[UIColor colorWithRed:0.7 green:0.4 blue:1.0 alpha:0.6].CGColor,
        (id)[UIColor colorWithRed:0.3 green:0.6 blue:1.0 alpha:0.9].CGColor,
        (id)[UIColor colorWithRed:0.6 green:0.3 blue:0.9 alpha:0.6].CGColor,
        (id)[UIColor colorWithRed:0.5 green:0.3 blue:1.0 alpha:0.9].CGColor
    ];
    welcomeBorderGradient.startPoint = CGPointMake(0.0, 0.0);
    welcomeBorderGradient.endPoint = CGPointMake(1.0, 1.0);
    welcomeBorderGradient.mask = borderShape;

    [welcomeCard.layer addSublayer:welcomeBorderGradient];
}

- (void)addWelcomeShimmer {
    welcomeShimmerLayer = [CAGradientLayer layer];
    welcomeShimmerLayer.frame = CGRectMake(-welcomeCard.bounds.size.width, 0,
                                            welcomeCard.bounds.size.width * 2,
                                            welcomeCard.bounds.size.height);
    welcomeShimmerLayer.colors = @[
        (id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor,
        (id)[UIColor colorWithWhite:1.0 alpha:0.03].CGColor,
        (id)[UIColor colorWithWhite:1.0 alpha:0.12].CGColor,
        (id)[UIColor colorWithWhite:1.0 alpha:0.03].CGColor,
        (id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor
    ];
    welcomeShimmerLayer.locations = @[@0.0, @0.35, @0.5, @0.65, @1.0];
    welcomeShimmerLayer.startPoint = CGPointMake(0.0, 0.5);
    welcomeShimmerLayer.endPoint = CGPointMake(1.0, 0.5);

    [welcomeCard.layer addSublayer:welcomeShimmerLayer];
}

- (void)startWelcomeAnimations {
    // Floating animation
    CABasicAnimation *floatAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    floatAnimation.fromValue = @(-4);
    floatAnimation.toValue = @(4);
    floatAnimation.duration = 2.5;
    floatAnimation.autoreverses = YES;
    floatAnimation.repeatCount = HUGE_VALF;
    floatAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [welcomeCard.layer addAnimation:floatAnimation forKey:@"floating"];

    // Border color animation
    CABasicAnimation *borderAnimation = [CABasicAnimation animationWithKeyPath:@"colors"];
    borderAnimation.toValue = @[
        (id)[UIColor colorWithRed:0.3 green:0.6 blue:1.0 alpha:0.9].CGColor,
        (id)[UIColor colorWithRed:0.6 green:0.3 blue:0.9 alpha:0.6].CGColor,
        (id)[UIColor colorWithRed:0.5 green:0.3 blue:1.0 alpha:0.9].CGColor,
        (id)[UIColor colorWithRed:0.7 green:0.4 blue:1.0 alpha:0.6].CGColor,
        (id)[UIColor colorWithRed:0.3 green:0.6 blue:1.0 alpha:0.9].CGColor
    ];
    borderAnimation.duration = 3.0;
    borderAnimation.autoreverses = YES;
    borderAnimation.repeatCount = HUGE_VALF;
    [welcomeBorderGradient addAnimation:borderAnimation forKey:@"borderColorShift"];

    // Shimmer sweep
    CABasicAnimation *shimmerAnimation = [CABasicAnimation animationWithKeyPath:@"position.x"];
    shimmerAnimation.fromValue = @(-welcomeCard.bounds.size.width);
    shimmerAnimation.toValue = @(welcomeCard.bounds.size.width * 2);
    shimmerAnimation.duration = 3.5;
    shimmerAnimation.repeatCount = HUGE_VALF;
    shimmerAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [welcomeShimmerLayer addAnimation:shimmerAnimation forKey:@"shimmerSweep"];

    // Glow pulse
    CABasicAnimation *glowPulse = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    glowPulse.fromValue = @(0.4);
    glowPulse.toValue = @(0.8);
    glowPulse.duration = 2.0;
    glowPulse.autoreverses = YES;
    glowPulse.repeatCount = HUGE_VALF;
    [welcomeCard.layer addAnimation:glowPulse forKey:@"glowPulse"];
}

- (void)welcomeButtonTouchDown:(UIButton *)button {
    [hapticMedium impactOccurred];
    [UIView animateWithDuration:0.12 animations:^{
        button.transform = CGAffineTransformMakeScale(0.92, 0.92);
        button.layer.shadowOpacity = 0.4;
    }];
}

- (void)welcomeButtonTouchUp:(UIButton *)button {
    [UIView animateWithDuration:0.25
                          delay:0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0.5
                        options:0
                     animations:^{
        button.transform = CGAffineTransformIdentity;
        button.layer.shadowOpacity = 0.7;
    } completion:nil];
}

- (void)welcomeButtonPressed:(UIButton *)button {
    [hapticNotification notificationOccurred:UINotificationFeedbackTypeSuccess];

    // Animate button press
    [UIView animateWithDuration:0.12 animations:^{
        button.transform = CGAffineTransformMakeScale(0.92, 0.92);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            button.transform = CGAffineTransformIdentity;
        }];
    }];

    // Dismiss with animation
    [UIView animateWithDuration:0.4
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
        self.welcomeCard.transform = CGAffineTransformMakeScale(0.85, 0.85);
        self.welcomeCard.alpha = 0;
        self.welcomeOverlay.alpha = 0;
    } completion:^(BOOL finished) {
        [self.welcomeOverlay removeFromSuperview];
        self.welcomeOverlay = nil;
        self.welcomeCard = nil;

        [self myClearTheLabels];
        [self myAnalyzeButtonWasPressed:self];
    }];
}




- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [ picker dismissViewControllerAnimated:YES completion:nil];
    [myActivityIndicator stopAnimating];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}








-(CVPixelBufferRef) myMakePixelBufferWithImage: (UIImage *) theImage ofSize: (float)theSize {
    CIContext *myGlobalContext = [CIContext contextWithOptions:nil];
    CIImage *myHoldingImage = [[CIImage alloc] initWithImage:theImage];
    CIImage *myStartingImage = [[CIImage alloc] init];
    float myXScale = theSize / theImage.size.width;
    float myYScale = theSize / theImage.size.height;
    myStartingImage = [myHoldingImage imageByApplyingTransform:CGAffineTransformMakeScale(myXScale, myYScale)];
    [myGlobalContext createCGImage:myStartingImage fromRect:myStartingImage.extent];
    [myGlobalContext createCGImage:myHoldingImage fromRect:myHoldingImage.extent];
    CVPixelBufferRef myPixelBuffer;
    CVReturn myreturn = CVPixelBufferCreate(NULL, theSize, theSize, kCVPixelFormatType_32BGRA, nil, &myPixelBuffer);
    [myGlobalContext render:myStartingImage   toCVPixelBuffer:myPixelBuffer];
    if (myreturn) {
        NSLog(@"Error!!");
    }
    return myPixelBuffer;
}

#pragma mark - Modern UI Design

- (void)applyModernDesign {
    // Apply gradient background
    [self applyGradientBackground];

    // Style the image view with a modern card look
    [self styleImageView];

    // Hide old labels and create results table
    [self hideOldLabels];
    [self createResultsTableView];

    // Find and style buttons
    [self styleAllButtons];
}

- (void)hideOldLabels {
    // Hide all the old individual labels
    NSArray *allLabels = @[
        myFastViTMA36Label, myFastViTMA36Pct, myFastViTMA36Category,
        myFastViTT8Label, myFastViTT8Pct, myFastViTT8Category,
        myMobileNetV2FP16Label, myMobileNetV2FP16Pct, myMobileNetV2FP16Category,
        myMobileNetV2Int8Label, myMobileNetV2Int8Pct, myMobileNetV2Int8Category,
        myResnet50FP16Label, myResnet50FP16Pct, myResnet50FP16Category,
        myResnet50Int8Label, myResnet50Int8Pct, myResnet50Int8Category
    ];

    for (UILabel *label in allLabels) {
        if (label) {
            label.hidden = YES;
        }
    }
}

- (void)createResultsTableView {
    // Initialize results data array
    resultsData = [[NSMutableArray alloc] init];

    // Use the connected mainStackView outlet, or find it
    UIStackView *screenStackView = mainStackView;

    // Fallback: Find the Screen Stack View by traversing from the image
    if (!screenStackView && myImage.superview && [myImage.superview.superview isKindOfClass:[UIStackView class]]) {
        screenStackView = (UIStackView *)myImage.superview.superview;
    }

    if (!screenStackView) {
        // Fallback: find stack view in view hierarchy
        for (UIView *subview in self.view.subviews) {
            if ([subview isKindOfClass:[UIStackView class]]) {
                screenStackView = (UIStackView *)subview;
                break;
            }
        }
    }

    // Hide the About/Help buttons stack (index 1) and old Results Stack View (index 2)
    if (screenStackView) {
        NSArray *arrangedSubviews = screenStackView.arrangedSubviews;
        for (NSInteger i = 1; i < arrangedSubviews.count - 1; i++) {
            // Hide everything between the image stack and the buttons stack
            UIView *subview = arrangedSubviews[i];
            subview.hidden = YES;
        }
    }

    // Create container with glassmorphic styling
    resultsContainerView = [[UIView alloc] init];
    resultsContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    resultsContainerView.layer.cornerRadius = 20;
    resultsContainerView.clipsToBounds = YES;

    // Add to stack view if found, otherwise add to view
    if (screenStackView) {
        // Insert after the image stack view (index 1)
        [screenStackView insertArrangedSubview:resultsContainerView atIndex:1];

        // Set height constraint for the results container
        [resultsContainerView.heightAnchor constraintGreaterThanOrEqualToConstant:280].active = YES;

        // Make width match the image/stack view width
        [resultsContainerView.widthAnchor constraintEqualToAnchor:screenStackView.widthAnchor].active = YES;
    } else {
        // Fallback: add directly to view
        CGFloat containerTop = CGRectGetMaxY(myImage.frame) + 20;
        CGFloat containerHeight = self.view.bounds.size.height - containerTop - 80;
        resultsContainerView.frame = CGRectMake(15, containerTop, self.view.bounds.size.width - 30, containerHeight);
        [self.view addSubview:resultsContainerView];
    }

    // Blur background - use auto layout
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.translatesAutoresizingMaskIntoConstraints = NO;
    blurView.alpha = 0.8;
    [resultsContainerView addSubview:blurView];
    [NSLayoutConstraint activateConstraints:@[
        [blurView.topAnchor constraintEqualToAnchor:resultsContainerView.topAnchor],
        [blurView.bottomAnchor constraintEqualToAnchor:resultsContainerView.bottomAnchor],
        [blurView.leadingAnchor constraintEqualToAnchor:resultsContainerView.leadingAnchor],
        [blurView.trailingAnchor constraintEqualToAnchor:resultsContainerView.trailingAnchor]
    ]];

    // Border
    resultsContainerView.layer.borderWidth = 1.5;
    resultsContainerView.layer.borderColor = [UIColor colorWithRed:0.5 green:0.4 blue:0.9 alpha:0.5].CGColor;

    // Create header view with auto layout
    UIView *headerView = [[UIView alloc] init];
    headerView.translatesAutoresizingMaskIntoConstraints = NO;
    headerView.backgroundColor = [UIColor colorWithRed:0.2 green:0.12 blue:0.35 alpha:0.9];
    [resultsContainerView addSubview:headerView];
    [NSLayoutConstraint activateConstraints:@[
        [headerView.topAnchor constraintEqualToAnchor:resultsContainerView.topAnchor],
        [headerView.leadingAnchor constraintEqualToAnchor:resultsContainerView.leadingAnchor],
        [headerView.trailingAnchor constraintEqualToAnchor:resultsContainerView.trailingAnchor],
        [headerView.heightAnchor constraintEqualToConstant:44]
    ]];

    // Header labels using a horizontal stack view
    UIStackView *headerStack = [[UIStackView alloc] init];
    headerStack.translatesAutoresizingMaskIntoConstraints = NO;
    headerStack.axis = UILayoutConstraintAxisHorizontal;
    headerStack.distribution = UIStackViewDistributionFillProportionally;
    headerStack.alignment = UIStackViewAlignmentCenter;
    headerStack.spacing = 5;
    [headerView addSubview:headerStack];
    [NSLayoutConstraint activateConstraints:@[
        [headerStack.topAnchor constraintEqualToAnchor:headerView.topAnchor],
        [headerStack.bottomAnchor constraintEqualToAnchor:headerView.bottomAnchor],
        [headerStack.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor constant:10],
        [headerStack.trailingAnchor constraintEqualToAnchor:headerView.trailingAnchor constant:-10]
    ]];

    UILabel *modelHeader = [[UILabel alloc] init];
    modelHeader.text = @"Model";
    modelHeader.font = [UIFont boldSystemFontOfSize:14];
    modelHeader.textColor = [UIColor colorWithRed:0.6 green:0.8 blue:1.0 alpha:1.0];
    [modelHeader setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];

    UILabel *itemHeader = [[UILabel alloc] init];
    itemHeader.text = @"Item";
    itemHeader.font = [UIFont boldSystemFontOfSize:14];
    itemHeader.textColor = [UIColor colorWithRed:0.6 green:0.8 blue:1.0 alpha:1.0];
    [itemHeader setContentHuggingPriority:UILayoutPriorityDefaultLow - 1 forAxis:UILayoutConstraintAxisHorizontal];

    UILabel *confHeader = [[UILabel alloc] init];
    confHeader.text = @"Confidence";
    confHeader.font = [UIFont boldSystemFontOfSize:14];
    confHeader.textColor = [UIColor colorWithRed:0.6 green:0.8 blue:1.0 alpha:1.0];
    confHeader.textAlignment = NSTextAlignmentRight;
    [confHeader setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];

    [headerStack addArrangedSubview:modelHeader];
    [headerStack addArrangedSubview:itemHeader];
    [headerStack addArrangedSubview:confHeader];

    // Divider under header
    UIView *divider = [[UIView alloc] init];
    divider.translatesAutoresizingMaskIntoConstraints = NO;
    divider.backgroundColor = [UIColor colorWithRed:0.5 green:0.4 blue:0.9 alpha:0.5];
    [headerView addSubview:divider];
    [NSLayoutConstraint activateConstraints:@[
        [divider.bottomAnchor constraintEqualToAnchor:headerView.bottomAnchor],
        [divider.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor constant:10],
        [divider.trailingAnchor constraintEqualToAnchor:headerView.trailingAnchor constant:-10],
        [divider.heightAnchor constraintEqualToConstant:1]
    ]];

    // Create table view with auto layout
    resultsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    resultsTableView.translatesAutoresizingMaskIntoConstraints = NO;
    resultsTableView.delegate = self;
    resultsTableView.dataSource = self;
    resultsTableView.backgroundColor = [UIColor clearColor];
    resultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    resultsTableView.showsVerticalScrollIndicator = YES;
    resultsTableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    resultsTableView.rowHeight = 55;

    [resultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ResultCell"];

    [resultsContainerView addSubview:resultsTableView];
    [NSLayoutConstraint activateConstraints:@[
        [resultsTableView.topAnchor constraintEqualToAnchor:headerView.bottomAnchor],
        [resultsTableView.bottomAnchor constraintEqualToAnchor:resultsContainerView.bottomAnchor],
        [resultsTableView.leadingAnchor constraintEqualToAnchor:resultsContainerView.leadingAnchor],
        [resultsTableView.trailingAnchor constraintEqualToAnchor:resultsContainerView.trailingAnchor]
    ]];
}

- (void)applyGradientBackground {
    backgroundGradient = [CAGradientLayer layer];
    backgroundGradient.frame = self.view.bounds;

    // Deep space gradient - dark purple to deep blue
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

- (void)styleImageView {
    if (!myImage) return;

    // Rounded corners
    myImage.layer.cornerRadius = 20.0;
    myImage.clipsToBounds = YES;

    // Subtle border
    myImage.layer.borderWidth = 2.0;
    myImage.layer.borderColor = [UIColor colorWithRed:0.4 green:0.3 blue:0.8 alpha:0.5].CGColor;

    // Shadow (need to add to superview since clipsToBounds is YES)
    UIView *shadowContainer = [[UIView alloc] initWithFrame:myImage.frame];
    shadowContainer.backgroundColor = [UIColor clearColor];
    shadowContainer.layer.shadowColor = [UIColor colorWithRed:0.5 green:0.3 blue:1.0 alpha:1.0].CGColor;
    shadowContainer.layer.shadowOffset = CGSizeMake(0, 8);
    shadowContainer.layer.shadowRadius = 20;
    shadowContainer.layer.shadowOpacity = 0.4;
    shadowContainer.translatesAutoresizingMaskIntoConstraints = NO;

    if (myImage.superview) {
        [myImage.superview insertSubview:shadowContainer belowSubview:myImage];
        [NSLayoutConstraint activateConstraints:@[
            [shadowContainer.centerXAnchor constraintEqualToAnchor:myImage.centerXAnchor],
            [shadowContainer.centerYAnchor constraintEqualToAnchor:myImage.centerYAnchor],
            [shadowContainer.widthAnchor constraintEqualToAnchor:myImage.widthAnchor],
            [shadowContainer.heightAnchor constraintEqualToAnchor:myImage.heightAnchor]
        ]];
    }
}

- (void)styleLabels {
    // Style model name labels with vibrant colors
    NSArray *modelLabels = @[myFastViTMA36Label, myFastViTT8Label, myMobileNetV2FP16Label,
                             myMobileNetV2Int8Label, myResnet50FP16Label, myResnet50Int8Label];

    NSArray *vibrantColors = @[
        [UIColor colorWithRed:0.0 green:0.9 blue:0.9 alpha:1.0],   // Cyan - FastViT MA36
        [UIColor colorWithRed:0.9 green:0.4 blue:0.9 alpha:1.0],   // Pink - FastViT T8
        [UIColor colorWithRed:0.4 green:0.9 blue:0.4 alpha:1.0],   // Green - MobileNetV2 FP16
        [UIColor colorWithRed:0.9 green:0.7 blue:0.2 alpha:1.0],   // Gold - MobileNetV2 Int8
        [UIColor colorWithRed:0.4 green:0.6 blue:1.0 alpha:1.0],   // Blue - Resnet50 FP16
        [UIColor colorWithRed:1.0 green:0.5 blue:0.3 alpha:1.0]    // Orange - Resnet50 Int8
    ];

    for (NSInteger i = 0; i < modelLabels.count; i++) {
        UILabel *label = modelLabels[i];
        if (label) {
            label.textColor = vibrantColors[i];
            label.layer.shadowColor = [vibrantColors[i] CGColor];
            label.layer.shadowOffset = CGSizeZero;
            label.layer.shadowRadius = 8;
            label.layer.shadowOpacity = 0.6;
        }
    }
}

- (void)styleAllButtons {
    // Find all buttons in the view hierarchy
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

- (void)styleModernButton:(UIButton *)button {
    if (!button || button.hidden) return;

    // Modern rounded corners
    button.layer.cornerRadius = 12.0;
    button.clipsToBounds = NO;

    // Gradient background
    CAGradientLayer *buttonGradient = [CAGradientLayer layer];
    buttonGradient.frame = button.bounds;
    buttonGradient.cornerRadius = 12.0;

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

    // Text color
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithWhite:0.8 alpha:1.0] forState:UIControlStateHighlighted];

    // Add touch animations
    [button addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(buttonTouchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
}

- (void)buttonTouchDown:(UIButton *)button {
    [hapticLight impactOccurred];

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

#pragma mark - Animated Results

- (void)animateResultLabel:(UILabel *)label withDelay:(NSTimeInterval)delay {
    if (!label) return;

    // Start hidden and scaled down
    label.alpha = 0;
    label.transform = CGAffineTransformMakeScale(0.8, 0.8);

    [UIView animateWithDuration:0.5
                          delay:delay
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        label.alpha = 1.0;
        label.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)animateAllResultsAppearing {
    NSArray *allLabels = @[myFastViTMA36Label, myFastViTMA36Pct, myFastViTMA36Category,
                           myFastViTT8Label, myFastViTT8Pct, myFastViTT8Category,
                           myMobileNetV2FP16Label, myMobileNetV2FP16Pct, myMobileNetV2FP16Category,
                           myMobileNetV2Int8Label, myMobileNetV2Int8Pct, myMobileNetV2Int8Category,
                           myResnet50FP16Label, myResnet50FP16Pct, myResnet50FP16Category,
                           myResnet50Int8Label, myResnet50Int8Pct, myResnet50Int8Category];

    for (NSInteger i = 0; i < allLabels.count; i++) {
        UILabel *label = allLabels[i];
        if (label && ![label isEqual:[NSNull null]]) {
            [self animateResultLabel:label withDelay:(i / 3) * 0.15];
        }
    }
}

- (void)pulseImageDuringAnalysis {
    [UIView animateWithDuration:0.6
                          delay:0
                        options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat
                     animations:^{
        self.myImage.transform = CGAffineTransformMakeScale(1.02, 1.02);
        self.myImage.layer.borderColor = [UIColor colorWithRed:0.6 green:0.4 blue:1.0 alpha:0.8].CGColor;
    } completion:nil];
}

- (void)stopImagePulse {
    [self.myImage.layer removeAllAnimations];
    [UIView animateWithDuration:0.3 animations:^{
        self.myImage.transform = CGAffineTransformIdentity;
        self.myImage.layer.borderColor = [UIColor colorWithRed:0.4 green:0.3 blue:0.8 alpha:0.5].CGColor;
    }];
}

- (void)celebrateHighConfidence {
    [self celebrateWithVariety:YES];
}

#pragma mark - Variety Celebrations

- (void)celebrateWithVariety:(BOOL)isHighConfidence {
    // Different haptic for high vs normal confidence
    if (isHighConfidence) {
        [hapticNotification notificationOccurred:UINotificationFeedbackTypeSuccess];
    } else {
        [hapticLight impactOccurred];
    }

    // Cycle through 8 different celebration types
    NSInteger celebrationType = celebrationIndex % 8;
    celebrationIndex++;

    switch (celebrationType) {
        case 0:
            [self createConfettiCelebration];
            break;
        case 1:
            [self createStarBurstCelebration];
            break;
        case 2:
            [self createFireworksCelebration];
            break;
        case 3:
            [self createHeartsCelebration];
            break;
        case 4:
            [self createRainbowSparklesCelebration];
            break;
        case 5:
            [self createBubblesCelebration];
            break;
        case 6:
            [self createGlitterRainCelebration];
            break;
        case 7:
            [self createNeonPulseCelebration];
            break;
        default:
            [self createConfettiCelebration];
            break;
    }
}

- (void)createConfettiCelebration {
    CAEmitterLayer *emitter = [CAEmitterLayer layer];
    emitter.emitterPosition = CGPointMake(self.view.bounds.size.width / 2, -20);
    emitter.emitterShape = kCAEmitterLayerLine;
    emitter.emitterSize = CGSizeMake(self.view.bounds.size.width, 1);

    NSMutableArray *cells = [NSMutableArray array];
    NSArray *colors = @[
        [UIColor redColor],
        [UIColor blueColor],
        [UIColor greenColor],
        [UIColor yellowColor],
        [UIColor magentaColor],
        [UIColor cyanColor],
        [UIColor orangeColor]
    ];

    for (UIColor *color in colors) {
        CAEmitterCell *confetti = [CAEmitterCell emitterCell];
        confetti.birthRate = 8;
        confetti.lifetime = 4.0;
        confetti.velocity = 150;
        confetti.velocityRange = 50;
        confetti.emissionLongitude = M_PI;
        confetti.emissionRange = M_PI_4;
        confetti.spin = 3.0;
        confetti.spinRange = 6.0;
        confetti.scale = 0.08;
        confetti.scaleRange = 0.04;
        confetti.yAcceleration = 150;

        UIGraphicsBeginImageContextWithOptions(CGSizeMake(20, 20), NO, 0);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(ctx, color.CGColor);
        CGContextFillRect(ctx, CGRectMake(2, 0, 16, 20));
        confetti.contents = (id)UIGraphicsGetImageFromCurrentImageContext().CGImage;
        UIGraphicsEndImageContext();

        [cells addObject:confetti];
    }

    emitter.emitterCells = cells;
    [self.view.layer addSublayer:emitter];

    [self removeEmitterAfterDelay:emitter birthDuration:1.5 totalDuration:5.0];
}

- (void)createStarBurstCelebration {
    CAEmitterLayer *emitter = [CAEmitterLayer layer];
    emitter.emitterPosition = CGPointMake(myImage.center.x, myImage.center.y);
    emitter.emitterShape = kCAEmitterLayerPoint;

    CAEmitterCell *star = [CAEmitterCell emitterCell];
    star.birthRate = 50;
    star.lifetime = 1.5;
    star.velocity = 200;
    star.velocityRange = 80;
    star.emissionRange = M_PI * 2;
    star.scale = 0.15;
    star.scaleRange = 0.08;
    star.scaleSpeed = -0.1;
    star.alphaSpeed = -0.7;
    star.spin = 2.0;
    star.spinRange = 4.0;

    // Create star shape
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 30), NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:1.0 green:0.85 blue:0.0 alpha:1.0].CGColor);

    CGPoint center = CGPointMake(15, 15);
    CGFloat outerRadius = 14;
    CGFloat innerRadius = 6;
    NSInteger points = 5;

    CGMutablePathRef path = CGPathCreateMutable();
    for (int i = 0; i < points * 2; i++) {
        CGFloat radius = (i % 2 == 0) ? outerRadius : innerRadius;
        CGFloat angle = (M_PI * 2 * i) / (points * 2) - M_PI_2;
        CGPoint point = CGPointMake(center.x + radius * cos(angle), center.y + radius * sin(angle));
        if (i == 0) {
            CGPathMoveToPoint(path, NULL, point.x, point.y);
        } else {
            CGPathAddLineToPoint(path, NULL, point.x, point.y);
        }
    }
    CGPathCloseSubpath(path);
    CGContextAddPath(ctx, path);
    CGContextFillPath(ctx);
    CGPathRelease(path);

    star.contents = (id)UIGraphicsGetImageFromCurrentImageContext().CGImage;
    UIGraphicsEndImageContext();

    emitter.emitterCells = @[star];
    [self.view.layer addSublayer:emitter];

    [self removeEmitterAfterDelay:emitter birthDuration:0.4 totalDuration:2.0];
}

- (void)createFireworksCelebration {
    // Multiple burst points
    NSArray *burstPoints = @[
        [NSValue valueWithCGPoint:CGPointMake(self.view.bounds.size.width * 0.25, self.view.bounds.size.height * 0.3)],
        [NSValue valueWithCGPoint:CGPointMake(self.view.bounds.size.width * 0.75, self.view.bounds.size.height * 0.25)],
        [NSValue valueWithCGPoint:CGPointMake(self.view.bounds.size.width * 0.5, self.view.bounds.size.height * 0.4)]
    ];

    NSArray *burstColors = @[
        [UIColor colorWithRed:1.0 green:0.2 blue:0.4 alpha:1.0],
        [UIColor colorWithRed:0.3 green:0.8 blue:1.0 alpha:1.0],
        [UIColor colorWithRed:1.0 green:0.9 blue:0.2 alpha:1.0]
    ];

    for (int i = 0; i < burstPoints.count; i++) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * 0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self createSingleFireworkAt:[burstPoints[i] CGPointValue] withColor:burstColors[i]];
        });
    }
}

- (void)createSingleFireworkAt:(CGPoint)point withColor:(UIColor *)color {
    CAEmitterLayer *emitter = [CAEmitterLayer layer];
    emitter.emitterPosition = point;
    emitter.emitterShape = kCAEmitterLayerPoint;

    CAEmitterCell *spark = [CAEmitterCell emitterCell];
    spark.birthRate = 200;
    spark.lifetime = 1.2;
    spark.velocity = 180;
    spark.velocityRange = 60;
    spark.emissionRange = M_PI * 2;
    spark.scale = 0.06;
    spark.scaleSpeed = -0.04;
    spark.alphaSpeed = -0.8;
    spark.yAcceleration = 80;

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(12, 12), NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextFillEllipseInRect(ctx, CGRectMake(0, 0, 12, 12));
    spark.contents = (id)UIGraphicsGetImageFromCurrentImageContext().CGImage;
    UIGraphicsEndImageContext();

    emitter.emitterCells = @[spark];
    [self.view.layer addSublayer:emitter];

    [hapticMedium impactOccurred];

    [self removeEmitterAfterDelay:emitter birthDuration:0.1 totalDuration:1.5];
}

- (void)createHeartsCelebration {
    CAEmitterLayer *emitter = [CAEmitterLayer layer];
    emitter.emitterPosition = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height + 20);
    emitter.emitterShape = kCAEmitterLayerLine;
    emitter.emitterSize = CGSizeMake(self.view.bounds.size.width, 1);

    NSArray *heartColors = @[
        [UIColor colorWithRed:1.0 green:0.2 blue:0.4 alpha:1.0],
        [UIColor colorWithRed:1.0 green:0.4 blue:0.6 alpha:1.0],
        [UIColor colorWithRed:1.0 green:0.6 blue:0.7 alpha:1.0]
    ];

    NSMutableArray *cells = [NSMutableArray array];

    for (UIColor *color in heartColors) {
        CAEmitterCell *heart = [CAEmitterCell emitterCell];
        heart.birthRate = 6;
        heart.lifetime = 4.0;
        heart.velocity = -120;
        heart.velocityRange = 40;
        heart.emissionLongitude = -M_PI_2;
        heart.emissionRange = M_PI_4;
        heart.scale = 0.12;
        heart.scaleRange = 0.06;
        heart.alphaSpeed = -0.2;
        heart.spin = 0.3;
        heart.spinRange = 0.6;

        // Create heart shape
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 30), NO, 0);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(ctx, color.CGColor);

        UIBezierPath *heartPath = [UIBezierPath bezierPath];
        [heartPath moveToPoint:CGPointMake(15, 26)];
        [heartPath addCurveToPoint:CGPointMake(3, 12) controlPoint1:CGPointMake(15, 22) controlPoint2:CGPointMake(3, 18)];
        [heartPath addArcWithCenter:CGPointMake(9, 9) radius:6 startAngle:M_PI endAngle:0 clockwise:YES];
        [heartPath addArcWithCenter:CGPointMake(21, 9) radius:6 startAngle:M_PI endAngle:0 clockwise:YES];
        [heartPath addCurveToPoint:CGPointMake(15, 26) controlPoint1:CGPointMake(27, 18) controlPoint2:CGPointMake(15, 22)];
        [heartPath fill];

        heart.contents = (id)UIGraphicsGetImageFromCurrentImageContext().CGImage;
        UIGraphicsEndImageContext();

        [cells addObject:heart];
    }

    emitter.emitterCells = cells;
    [self.view.layer addSublayer:emitter];

    [self removeEmitterAfterDelay:emitter birthDuration:2.0 totalDuration:6.0];
}

- (void)createRainbowSparklesCelebration {
    CAEmitterLayer *emitter = [CAEmitterLayer layer];
    emitter.emitterPosition = CGPointMake(myImage.center.x, myImage.center.y);
    emitter.emitterShape = kCAEmitterLayerCircle;
    emitter.emitterSize = CGSizeMake(myImage.bounds.size.width, myImage.bounds.size.height);

    NSArray *rainbowColors = @[
        [UIColor redColor],
        [UIColor orangeColor],
        [UIColor yellowColor],
        [UIColor greenColor],
        [UIColor cyanColor],
        [UIColor blueColor],
        [UIColor magentaColor]
    ];

    NSMutableArray *cells = [NSMutableArray array];

    for (UIColor *color in rainbowColors) {
        CAEmitterCell *sparkle = [CAEmitterCell emitterCell];
        sparkle.birthRate = 15;
        sparkle.lifetime = 1.5;
        sparkle.velocity = 100;
        sparkle.velocityRange = 60;
        sparkle.emissionRange = M_PI * 2;
        sparkle.scale = 0.08;
        sparkle.scaleRange = 0.04;
        sparkle.scaleSpeed = -0.05;
        sparkle.alphaSpeed = -0.7;

        UIGraphicsBeginImageContextWithOptions(CGSizeMake(20, 20), NO, 0);
        CGContextRef ctx = UIGraphicsGetCurrentContext();

        // Glowing circle effect
        CGContextSetShadowWithColor(ctx, CGSizeZero, 8, color.CGColor);
        CGContextSetFillColorWithColor(ctx, color.CGColor);
        CGContextFillEllipseInRect(ctx, CGRectMake(4, 4, 12, 12));

        sparkle.contents = (id)UIGraphicsGetImageFromCurrentImageContext().CGImage;
        UIGraphicsEndImageContext();

        [cells addObject:sparkle];
    }

    emitter.emitterCells = cells;
    [self.view.layer addSublayer:emitter];

    [self removeEmitterAfterDelay:emitter birthDuration:0.6 totalDuration:2.5];
}

- (void)createBubblesCelebration {
    CAEmitterLayer *emitter = [CAEmitterLayer layer];
    emitter.emitterPosition = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height + 30);
    emitter.emitterShape = kCAEmitterLayerLine;
    emitter.emitterSize = CGSizeMake(self.view.bounds.size.width * 0.8, 1);

    CAEmitterCell *bubble = [CAEmitterCell emitterCell];
    bubble.birthRate = 12;
    bubble.lifetime = 5.0;
    bubble.velocity = -80;
    bubble.velocityRange = 30;
    bubble.emissionLongitude = -M_PI_2;
    bubble.emissionRange = M_PI_4 / 2;
    bubble.scale = 0.15;
    bubble.scaleRange = 0.1;
    bubble.alphaSpeed = -0.15;
    bubble.xAcceleration = 5;

    // Create bubble with gradient
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(40, 40), NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    // Outer ring
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:1.0 alpha:0.6].CGColor);
    CGContextSetLineWidth(ctx, 2);
    CGContextStrokeEllipseInRect(ctx, CGRectMake(2, 2, 36, 36));

    // Inner highlight
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:1.0 alpha:0.3].CGColor);
    CGContextFillEllipseInRect(ctx, CGRectMake(8, 6, 12, 10));

    bubble.contents = (id)UIGraphicsGetImageFromCurrentImageContext().CGImage;
    UIGraphicsEndImageContext();

    emitter.emitterCells = @[bubble];
    [self.view.layer addSublayer:emitter];

    [self removeEmitterAfterDelay:emitter birthDuration:2.5 totalDuration:7.0];
}

- (void)createGlitterRainCelebration {
    CAEmitterLayer *emitter = [CAEmitterLayer layer];
    emitter.emitterPosition = CGPointMake(self.view.bounds.size.width / 2, -10);
    emitter.emitterShape = kCAEmitterLayerLine;
    emitter.emitterSize = CGSizeMake(self.view.bounds.size.width, 1);

    NSArray *glitterColors = @[
        [UIColor colorWithRed:1.0 green:0.85 blue:0.4 alpha:1.0],
        [UIColor colorWithRed:0.9 green:0.9 blue:1.0 alpha:1.0],
        [UIColor colorWithRed:0.7 green:0.9 blue:1.0 alpha:1.0]
    ];

    NSMutableArray *cells = [NSMutableArray array];

    for (UIColor *color in glitterColors) {
        CAEmitterCell *glitter = [CAEmitterCell emitterCell];
        glitter.birthRate = 25;
        glitter.lifetime = 3.5;
        glitter.velocity = 120;
        glitter.velocityRange = 40;
        glitter.emissionLongitude = M_PI;
        glitter.emissionRange = M_PI_4 / 3;
        glitter.scale = 0.04;
        glitter.scaleRange = 0.02;
        glitter.alphaSpeed = -0.3;
        glitter.spin = 5.0;
        glitter.spinRange = 10.0;
        glitter.yAcceleration = 50;

        UIGraphicsBeginImageContextWithOptions(CGSizeMake(10, 10), NO, 0);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(ctx, color.CGColor);

        // Diamond shape
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, 5, 0);
        CGPathAddLineToPoint(path, NULL, 10, 5);
        CGPathAddLineToPoint(path, NULL, 5, 10);
        CGPathAddLineToPoint(path, NULL, 0, 5);
        CGPathCloseSubpath(path);
        CGContextAddPath(ctx, path);
        CGContextFillPath(ctx);
        CGPathRelease(path);

        glitter.contents = (id)UIGraphicsGetImageFromCurrentImageContext().CGImage;
        UIGraphicsEndImageContext();

        [cells addObject:glitter];
    }

    emitter.emitterCells = cells;
    [self.view.layer addSublayer:emitter];

    [self removeEmitterAfterDelay:emitter birthDuration:1.5 totalDuration:5.0];
}

- (void)createNeonPulseCelebration {
    // Create pulsing rings around the image
    NSArray *neonColors = @[
        [UIColor colorWithRed:0.0 green:1.0 blue:0.8 alpha:1.0],
        [UIColor colorWithRed:1.0 green:0.0 blue:0.8 alpha:1.0],
        [UIColor colorWithRed:0.4 green:0.4 blue:1.0 alpha:1.0]
    ];

    for (int i = 0; i < neonColors.count; i++) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * 0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self createNeonRingWithColor:neonColors[i] delay:i * 0.2];
        });
    }

    // Also add some particles
    CAEmitterLayer *emitter = [CAEmitterLayer layer];
    emitter.emitterPosition = CGPointMake(myImage.center.x, myImage.center.y);
    emitter.emitterShape = kCAEmitterLayerCircle;
    emitter.emitterSize = CGSizeMake(myImage.bounds.size.width * 0.8, myImage.bounds.size.height * 0.8);

    CAEmitterCell *neonParticle = [CAEmitterCell emitterCell];
    neonParticle.birthRate = 20;
    neonParticle.lifetime = 1.2;
    neonParticle.velocity = 60;
    neonParticle.velocityRange = 30;
    neonParticle.emissionRange = M_PI * 2;
    neonParticle.scale = 0.06;
    neonParticle.scaleSpeed = -0.04;
    neonParticle.alphaSpeed = -0.8;

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(16, 16), NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetShadowWithColor(ctx, CGSizeZero, 6, [UIColor cyanColor].CGColor);
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextFillEllipseInRect(ctx, CGRectMake(4, 4, 8, 8));
    neonParticle.contents = (id)UIGraphicsGetImageFromCurrentImageContext().CGImage;
    UIGraphicsEndImageContext();

    emitter.emitterCells = @[neonParticle];
    [self.view.layer addSublayer:emitter];

    [self removeEmitterAfterDelay:emitter birthDuration:0.5 totalDuration:2.0];
}

- (void)createNeonRingWithColor:(UIColor *)color delay:(CGFloat)delay {
    UIView *ringView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    ringView.center = myImage.center;
    ringView.backgroundColor = [UIColor clearColor];
    ringView.layer.borderColor = color.CGColor;
    ringView.layer.borderWidth = 3;
    ringView.layer.cornerRadius = 10;
    ringView.alpha = 1.0;
    ringView.layer.shadowColor = color.CGColor;
    ringView.layer.shadowRadius = 10;
    ringView.layer.shadowOpacity = 0.8;
    ringView.layer.shadowOffset = CGSizeZero;

    [self.view addSubview:ringView];

    [UIView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        ringView.transform = CGAffineTransformMakeScale(15, 15);
        ringView.alpha = 0;
    } completion:^(BOOL finished) {
        [ringView removeFromSuperview];
    }];
}

- (void)removeEmitterAfterDelay:(CAEmitterLayer *)emitter birthDuration:(CGFloat)birthDuration totalDuration:(CGFloat)totalDuration {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(birthDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        emitter.birthRate = 0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((totalDuration - birthDuration) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [emitter removeFromSuperlayer];
        });
    });
}

#pragma mark - Enhanced Color Methods

- (UIColor *)colorForConfidence:(float)confidence {
    if (confidence < 30.0) {
        // Red with glow effect
        return [UIColor colorWithRed:1.0 green:0.3 blue:0.3 alpha:1.0];
    } else if (confidence > 80.0) {
        // Vibrant green
        return [UIColor colorWithRed:0.2 green:1.0 blue:0.4 alpha:1.0];
    } else {
        // Gradient from orange to yellow based on confidence
        float normalized = (confidence - 30.0) / 50.0;
        return [UIColor colorWithRed:1.0 green:0.6 + (normalized * 0.2) blue:0.1 + (normalized * 0.2) alpha:1.0];
    }
}

- (void)applyColorWithGlow:(UIColor *)color toLabel:(UILabel *)label {
    label.textColor = color;
    label.layer.shadowColor = color.CGColor;
    label.layer.shadowOffset = CGSizeZero;
    label.layer.shadowRadius = 6;
    label.layer.shadowOpacity = 0.8;
}

#pragma mark - Sorting Animation

- (void)showResultsBeforeSorting {
    // Make all labels visible immediately (no animation yet)
    NSArray *allLabels = @[myFastViTMA36Label, myFastViTMA36Pct, myFastViTMA36Category,
                           myFastViTT8Label, myFastViTT8Pct, myFastViTT8Category,
                           myMobileNetV2FP16Label, myMobileNetV2FP16Pct, myMobileNetV2FP16Category,
                           myMobileNetV2Int8Label, myMobileNetV2Int8Pct, myMobileNetV2Int8Category,
                           myResnet50FP16Label, myResnet50FP16Pct, myResnet50FP16Category,
                           myResnet50Int8Label, myResnet50Int8Pct, myResnet50Int8Category];

    for (UILabel *label in allLabels) {
        if (label) {
            label.alpha = 1.0;
            label.transform = CGAffineTransformIdentity;
        }
    }
}

- (void)animateSortingByConfidence {
    // Create array of results with their data
    NSMutableArray *results = [NSMutableArray array];

    // FastViT MA36 (High Accuracy)
    [results addObject:@{
        @"name": @"FastViT MA36:",
        @"confidence": @(myFastViTMA36PctVal),
        @"category": myFastViTMA36Category.text ?: @"",
        @"nameLabel": myFastViTMA36Label,
        @"pctLabel": myFastViTMA36Pct,
        @"categoryLabel": myFastViTMA36Category
    }];

    // FastViT T8 (Fast)
    [results addObject:@{
        @"name": @"FastViT T8:",
        @"confidence": @(myFastViTT8PctVal),
        @"category": myFastViTT8Category.text ?: @"",
        @"nameLabel": myFastViTT8Label,
        @"pctLabel": myFastViTT8Pct,
        @"categoryLabel": myFastViTT8Category
    }];

    // MobileNetV2 FP16
    [results addObject:@{
        @"name": @"MobileNetV2 FP16:",
        @"confidence": @(myMobileNetV2FP16PctVal),
        @"category": myMobileNetV2FP16Category.text ?: @"",
        @"nameLabel": myMobileNetV2FP16Label,
        @"pctLabel": myMobileNetV2FP16Pct,
        @"categoryLabel": myMobileNetV2FP16Category
    }];

    // MobileNetV2 Int8
    [results addObject:@{
        @"name": @"MobileNetV2 Int8:",
        @"confidence": @(myMobileNetV2Int8PctVal),
        @"category": myMobileNetV2Int8Category.text ?: @"",
        @"nameLabel": myMobileNetV2Int8Label,
        @"pctLabel": myMobileNetV2Int8Pct,
        @"categoryLabel": myMobileNetV2Int8Category
    }];

    // Resnet50 FP16
    [results addObject:@{
        @"name": @"ResNet50 FP16:",
        @"confidence": @(myResnet50FP16PctVal),
        @"category": myResnet50FP16Category.text ?: @"",
        @"nameLabel": myResnet50FP16Label,
        @"pctLabel": myResnet50FP16Pct,
        @"categoryLabel": myResnet50FP16Category
    }];

    // Resnet50 Int8
    [results addObject:@{
        @"name": @"ResNet50 Int8:",
        @"confidence": @(myResnet50Int8PctVal),
        @"category": myResnet50Int8Category.text ?: @"",
        @"nameLabel": myResnet50Int8Label,
        @"pctLabel": myResnet50Int8Pct,
        @"categoryLabel": myResnet50Int8Category
    }];

    // Sort by confidence descending
    NSArray *sortedResults = [results sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *a, NSDictionary *b) {
        return [b[@"confidence"] compare:a[@"confidence"]];
    }];

    // Store original Y positions of each row
    NSMutableArray *originalYPositions = [NSMutableArray array];
    for (NSDictionary *result in results) {
        UILabel *nameLabel = result[@"nameLabel"];
        [originalYPositions addObject:@(nameLabel.center.y)];
    }

    // Calculate target Y positions based on sorted order
    NSMutableArray *targetYPositions = [NSMutableArray array];
    for (NSInteger i = 0; i < sortedResults.count; i++) {
        [targetYPositions addObject:originalYPositions[i]];
    }

    // Haptic feedback for sorting start
    [hapticMedium impactOccurred];

    // Phase 1: Scale down and fade all labels slightly
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
        for (NSDictionary *result in results) {
            UILabel *nameLabel = result[@"nameLabel"];
            UILabel *pctLabel = result[@"pctLabel"];
            UILabel *categoryLabel = result[@"categoryLabel"];

            nameLabel.transform = CGAffineTransformMakeScale(0.8, 0.8);
            pctLabel.transform = CGAffineTransformMakeScale(0.8, 0.8);
            categoryLabel.transform = CGAffineTransformMakeScale(0.8, 0.8);

            nameLabel.alpha = 0.5;
            pctLabel.alpha = 0.5;
            categoryLabel.alpha = 0.5;
        }
    } completion:^(BOOL finished) {
        // Phase 2: Move labels to their new sorted positions
        [self animateLabelsToSortedPositions:sortedResults
                          originalPositions:originalYPositions
                            targetPositions:targetYPositions];
    }];
}

- (void)animateLabelsToSortedPositions:(NSArray *)sortedResults
                     originalPositions:(NSArray *)originalYPositions
                       targetPositions:(NSArray *)targetYPositions {

    // Calculate the Y offset each row needs to move
    for (NSInteger i = 0; i < sortedResults.count; i++) {
        NSDictionary *result = sortedResults[i];
        UILabel *nameLabel = result[@"nameLabel"];
        UILabel *pctLabel = result[@"pctLabel"];
        UILabel *categoryLabel = result[@"categoryLabel"];

        // Find original index of this result
        CGFloat originalY = nameLabel.center.y;
        CGFloat targetY = [targetYPositions[i] floatValue];
        CGFloat deltaY = targetY - originalY;

        // Staggered animation - higher confidence animates first
        NSTimeInterval delay = i * 0.1;

        [UIView animateWithDuration:0.5
                              delay:delay
             usingSpringWithDamping:0.7
              initialSpringVelocity:0.5
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
            // Move to new position
            nameLabel.transform = CGAffineTransformMakeTranslation(0, deltaY);
            pctLabel.transform = CGAffineTransformMakeTranslation(0, deltaY);
            categoryLabel.transform = CGAffineTransformMakeTranslation(0, deltaY);

            // Restore full opacity
            nameLabel.alpha = 1.0;
            pctLabel.alpha = 1.0;
            categoryLabel.alpha = 1.0;
        } completion:^(BOOL finished) {
            // Add special effects for top result
            if (i == 0) {
                [self highlightWinningResult:result];
            }
        }];
    }

    // Light haptic for each movement
    for (NSInteger i = 0; i < sortedResults.count; i++) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((i * 0.1) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self->hapticLight impactOccurred];
        });
    }
}

- (void)highlightWinningResult:(NSDictionary *)result {
    UILabel *nameLabel = result[@"nameLabel"];
    UILabel *pctLabel = result[@"pctLabel"];
    UILabel *categoryLabel = result[@"categoryLabel"];
    float confidence = [result[@"confidence"] floatValue];

    // Gold color for the winner
    UIColor *goldColor = [UIColor colorWithRed:1.0 green:0.84 blue:0.0 alpha:1.0];

    // Pulse animation for the winning row
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAutoreverse
                     animations:^{
        nameLabel.transform = CGAffineTransformScale(nameLabel.transform, 1.15, 1.15);
        pctLabel.transform = CGAffineTransformScale(pctLabel.transform, 1.15, 1.15);
        categoryLabel.transform = CGAffineTransformScale(categoryLabel.transform, 1.15, 1.15);
    } completion:^(BOOL finished) {
        // Apply golden glow to winner
        nameLabel.layer.shadowColor = goldColor.CGColor;
        nameLabel.layer.shadowRadius = 12;
        nameLabel.layer.shadowOpacity = 1.0;

        pctLabel.layer.shadowColor = goldColor.CGColor;
        pctLabel.layer.shadowRadius = 12;
        pctLabel.layer.shadowOpacity = 1.0;

        categoryLabel.layer.shadowColor = goldColor.CGColor;
        categoryLabel.layer.shadowRadius = 12;
        categoryLabel.layer.shadowOpacity = 1.0;
    }];

    // Add a trophy/crown emoji next to the winner if high confidence
    if (confidence > 50.0) {
        [self addTrophyEffectNearLabel:nameLabel];
    }

    // Success haptic
    [hapticNotification notificationOccurred:UINotificationFeedbackTypeSuccess];
}

- (void)addTrophyEffectNearLabel:(UILabel *)label {
    // Create a small trophy/star burst effect
    CAEmitterLayer *emitter = [CAEmitterLayer layer];
    emitter.emitterPosition = CGPointMake(label.frame.origin.x - 20, label.center.y);
    emitter.emitterShape = kCAEmitterLayerPoint;
    emitter.emitterSize = CGSizeMake(1, 1);

    CAEmitterCell *star = [CAEmitterCell emitterCell];
    star.birthRate = 8;
    star.lifetime = 1.5;
    star.velocity = 50;
    star.velocityRange = 20;
    star.emissionRange = M_PI * 2;
    star.scale = 0.15;
    star.scaleRange = 0.05;
    star.alphaSpeed = -0.7;
    star.spin = M_PI;
    star.spinRange = M_PI;

    // Create a star shape
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 30), NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    // Gold gradient star
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:1.0 green:0.84 blue:0.0 alpha:1.0].CGColor);

    // Draw a simple star
    CGContextMoveToPoint(ctx, 15, 0);
    CGContextAddLineToPoint(ctx, 18, 10);
    CGContextAddLineToPoint(ctx, 30, 12);
    CGContextAddLineToPoint(ctx, 21, 19);
    CGContextAddLineToPoint(ctx, 24, 30);
    CGContextAddLineToPoint(ctx, 15, 24);
    CGContextAddLineToPoint(ctx, 6, 30);
    CGContextAddLineToPoint(ctx, 9, 19);
    CGContextAddLineToPoint(ctx, 0, 12);
    CGContextAddLineToPoint(ctx, 12, 10);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);

    UIImage *starImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    star.contents = (id)starImage.CGImage;

    emitter.emitterCells = @[star];
    [self.view.layer addSublayer:emitter];

    // Stop emitting after a moment, then remove
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        emitter.birthRate = 0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [emitter removeFromSuperlayer];
        });
    });
}

#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return resultsData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResultCell" forIndexPath:indexPath];

    // Clear existing subviews
    for (UIView *subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }

    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    NSDictionary *result = resultsData[indexPath.row];
    NSString *modelName = result[@"model"];
    NSString *item = result[@"item"];
    float confidence = [result[@"confidence"] floatValue];

    CGFloat cellWidth = tableView.bounds.size.width;
    CGFloat colWidth1 = cellWidth * 0.30;
    CGFloat colWidth2 = cellWidth * 0.42;
    CGFloat colWidth3 = cellWidth * 0.28;

    // Alternating row background
    if (indexPath.row % 2 == 0) {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(5, 2, cellWidth - 10, 51)];
        bgView.backgroundColor = [UIColor colorWithRed:0.15 green:0.1 blue:0.25 alpha:0.4];
        bgView.layer.cornerRadius = 8;
        [cell.contentView addSubview:bgView];
    }

    // Get color for confidence
    UIColor *confColor = [self colorForConfidence:confidence];

    // Model name label
    UILabel *modelLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, colWidth1 - 10, 45)];
    modelLabel.text = modelName;
    modelLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    modelLabel.textColor = [UIColor colorWithRed:0.8 green:0.85 blue:1.0 alpha:1.0];
    modelLabel.numberOfLines = 2;
    modelLabel.adjustsFontSizeToFitWidth = YES;
    modelLabel.minimumScaleFactor = 0.7;
    [cell.contentView addSubview:modelLabel];

    // Item label
    UILabel *itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(colWidth1, 5, colWidth2 - 5, 45)];
    itemLabel.text = item;
    itemLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
    itemLabel.textColor = confColor;
    itemLabel.numberOfLines = 2;
    itemLabel.adjustsFontSizeToFitWidth = YES;
    itemLabel.minimumScaleFactor = 0.7;
    itemLabel.layer.shadowColor = confColor.CGColor;
    itemLabel.layer.shadowOffset = CGSizeZero;
    itemLabel.layer.shadowRadius = 4;
    itemLabel.layer.shadowOpacity = 0.6;
    [cell.contentView addSubview:itemLabel];

    // Confidence label
    UILabel *confLabel = [[UILabel alloc] initWithFrame:CGRectMake(colWidth1 + colWidth2, 5, colWidth3 - 15, 45)];
    confLabel.text = [NSString stringWithFormat:@"%.0f%%", confidence];
    confLabel.font = [UIFont boldSystemFontOfSize:16];
    confLabel.textColor = confColor;
    confLabel.textAlignment = NSTextAlignmentRight;
    confLabel.layer.shadowColor = confColor.CGColor;
    confLabel.layer.shadowOffset = CGSizeZero;
    confLabel.layer.shadowRadius = 5;
    confLabel.layer.shadowOpacity = 0.8;
    [cell.contentView addSubview:confLabel];

    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [hapticLight impactOccurred];
}

- (void)updateResultsTableWithAnimation {
    // Sort results by confidence (highest first)
    [resultsData sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        float conf1 = [obj1[@"confidence"] floatValue];
        float conf2 = [obj2[@"confidence"] floatValue];
        if (conf1 > conf2) return NSOrderedAscending;
        if (conf1 < conf2) return NSOrderedDescending;
        return NSOrderedSame;
    }];

    isAnimatingResults = YES;

    // Add shimmer to results container
    [self addResultsShimmer];

    // Reload table data
    [self.resultsTableView reloadData];

    // Animate each row with staggered spring animation
    [self animateRowsWithDelight];

    // Check for celebration conditions
    [self checkForCelebration];
}

#pragma mark - Delightful Animation Effects

- (void)animateRowsWithDelight {
    NSInteger rowCount = [resultsTableView numberOfRowsInSection:0];

    for (NSInteger i = 0; i < rowCount; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [resultsTableView cellForRowAtIndexPath:indexPath];

        if (!cell) continue;

        // Start position: off-screen right with scale
        cell.transform = CGAffineTransformConcat(
            CGAffineTransformMakeTranslation(300, 0),
            CGAffineTransformMakeScale(0.8, 0.8)
        );
        cell.alpha = 0;

        // Staggered spring animation
        NSTimeInterval delay = i * 0.12;

        [UIView animateWithDuration:0.6
                              delay:delay
             usingSpringWithDamping:0.7
              initialSpringVelocity:0.5
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
            cell.transform = CGAffineTransformIdentity;
            cell.alpha = 1.0;
        } completion:^(BOOL finished) {
            // Add subtle bounce on completion
            if (i == 0) {
                [self animateWinnerCell:cell];
            }

            // Haptic for each row
            [self->hapticLight impactOccurred];

            if (i == rowCount - 1) {
                self->isAnimatingResults = NO;
            }
        }];
    }
}

- (void)animateWinnerCell:(UITableViewCell *)cell {
    // Golden glow pulse for winner
    CABasicAnimation *glowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    glowAnimation.fromValue = @(0.3);
    glowAnimation.toValue = @(1.0);
    glowAnimation.duration = 0.5;
    glowAnimation.autoreverses = YES;
    glowAnimation.repeatCount = 3;

    cell.layer.shadowColor = [UIColor colorWithRed:1.0 green:0.84 blue:0.0 alpha:1.0].CGColor;
    cell.layer.shadowOffset = CGSizeZero;
    cell.layer.shadowRadius = 15;
    cell.layer.shadowOpacity = 0.8;
    [cell.layer addAnimation:glowAnimation forKey:@"winnerGlow"];

    // Scale pop
    [UIView animateWithDuration:0.2 delay:0.3 options:0 animations:^{
        cell.transform = CGAffineTransformMakeScale(1.05, 1.05);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3
                              delay:0
             usingSpringWithDamping:0.5
              initialSpringVelocity:0.8
                            options:0
                         animations:^{
            cell.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];

    // Add crown emoji
    [self addCrownToCell:cell];
}

- (void)addCrownToCell:(UITableViewCell *)cell {
    UILabel *crown = [[UILabel alloc] init];
    crown.text = @"👑";
    crown.font = [UIFont systemFontOfSize:20];
    crown.translatesAutoresizingMaskIntoConstraints = NO;
    crown.alpha = 0;
    crown.transform = CGAffineTransformMakeScale(0.1, 0.1);

    [cell.contentView addSubview:crown];
    [NSLayoutConstraint activateConstraints:@[
        [crown.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-5],
        [crown.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:2]
    ]];

    [UIView animateWithDuration:0.5
                          delay:0.5
         usingSpringWithDamping:0.5
          initialSpringVelocity:1.0
                        options:0
                     animations:^{
        crown.alpha = 1.0;
        crown.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        // Gentle floating animation
        [UIView animateWithDuration:1.0
                              delay:0
                            options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
                         animations:^{
            crown.transform = CGAffineTransformMakeTranslation(0, -3);
        } completion:nil];
    }];
}

- (void)addResultsShimmer {
    // Remove existing shimmer
    for (CALayer *layer in resultsContainerView.layer.sublayers.copy) {
        if ([layer.name isEqualToString:@"resultsShimmer"]) {
            [layer removeFromSuperlayer];
        }
    }

    CAGradientLayer *shimmer = [CAGradientLayer layer];
    shimmer.name = @"resultsShimmer";
    shimmer.frame = CGRectMake(-resultsContainerView.bounds.size.width, 0,
                                resultsContainerView.bounds.size.width * 2,
                                resultsContainerView.bounds.size.height);
    shimmer.colors = @[
        (id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor,
        (id)[UIColor colorWithWhite:1.0 alpha:0.1].CGColor,
        (id)[UIColor colorWithWhite:1.0 alpha:0.3].CGColor,
        (id)[UIColor colorWithWhite:1.0 alpha:0.1].CGColor,
        (id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor
    ];
    shimmer.locations = @[@0.0, @0.35, @0.5, @0.65, @1.0];
    shimmer.startPoint = CGPointMake(0.0, 0.5);
    shimmer.endPoint = CGPointMake(1.0, 0.5);

    [resultsContainerView.layer addSublayer:shimmer];

    CABasicAnimation *shimmerAnim = [CABasicAnimation animationWithKeyPath:@"position.x"];
    shimmerAnim.fromValue = @(-resultsContainerView.bounds.size.width);
    shimmerAnim.toValue = @(resultsContainerView.bounds.size.width * 2);
    shimmerAnim.duration = 1.5;
    shimmerAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [shimmer addAnimation:shimmerAnim forKey:@"shimmerSweep"];

    // Remove shimmer after animation
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [shimmer removeFromSuperlayer];
    });
}

- (void)checkForCelebration {
    if (resultsData.count == 0) return;

    // Get top result
    NSDictionary *topResult = resultsData[0];
    float topConfidence = [topResult[@"confidence"] floatValue];
    NSString *topItem = topResult[@"item"];

    // Check if models agree (at least 4 models with same top prediction)
    NSInteger agreementCount = 0;
    for (NSDictionary *result in resultsData) {
        if ([result[@"item"] isEqualToString:topItem]) {
            agreementCount++;
        }
    }

    // Celebration conditions
    BOOL highConfidence = topConfidence >= 90.0;
    BOOL modelsAgree = agreementCount >= 4;

    if (highConfidence || modelsAgree) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self launchCelebration:highConfidence && modelsAgree];
        });
    }
}

- (void)launchCelebration:(BOOL)majorCelebration {
    [hapticNotification notificationOccurred:UINotificationFeedbackTypeSuccess];

    // Create confetti emitter
    celebrationEmitter = [CAEmitterLayer layer];
    celebrationEmitter.emitterPosition = CGPointMake(self.view.bounds.size.width / 2, -20);
    celebrationEmitter.emitterSize = CGSizeMake(self.view.bounds.size.width, 1);
    celebrationEmitter.emitterShape = kCAEmitterLayerLine;

    NSMutableArray *cells = [NSMutableArray array];

    // Confetti colors
    NSArray *colors = @[
        [UIColor colorWithRed:1.0 green:0.84 blue:0.0 alpha:1.0],  // Gold
        [UIColor colorWithRed:0.3 green:0.85 blue:0.4 alpha:1.0],  // Green
        [UIColor colorWithRed:0.4 green:0.6 blue:1.0 alpha:1.0],   // Blue
        [UIColor colorWithRed:1.0 green:0.4 blue:0.6 alpha:1.0],   // Pink
        [UIColor colorWithRed:0.6 green:0.4 blue:1.0 alpha:1.0],   // Purple
        [UIColor colorWithRed:0.0 green:0.9 blue:0.9 alpha:1.0]    // Cyan
    ];

    for (UIColor *color in colors) {
        CAEmitterCell *confetti = [CAEmitterCell emitterCell];
        confetti.birthRate = majorCelebration ? 25 : 12;
        confetti.lifetime = 4.0;
        confetti.velocity = 200;
        confetti.velocityRange = 50;
        confetti.emissionLongitude = M_PI;  // Down
        confetti.emissionRange = M_PI / 4;
        confetti.spin = 3.0;
        confetti.spinRange = 6.0;
        confetti.scale = 0.08;
        confetti.scaleRange = 0.04;
        confetti.yAcceleration = 150;

        // Create confetti shape
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(20, 20), NO, 0);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(ctx, color.CGColor);

        // Random shape: square or circle
        if (arc4random_uniform(2) == 0) {
            CGContextFillRect(ctx, CGRectMake(2, 2, 16, 16));
        } else {
            CGContextFillEllipseInRect(ctx, CGRectMake(2, 2, 16, 16));
        }

        UIImage *confettiImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        confetti.contents = (id)confettiImage.CGImage;
        [cells addObject:confetti];
    }

    // Add sparkle particles for major celebrations
    if (majorCelebration) {
        CAEmitterCell *sparkle = [CAEmitterCell emitterCell];
        sparkle.birthRate = 15;
        sparkle.lifetime = 2.0;
        sparkle.velocity = 100;
        sparkle.velocityRange = 50;
        sparkle.emissionLongitude = M_PI;
        sparkle.emissionRange = M_PI / 3;
        sparkle.scale = 0.05;
        sparkle.scaleRange = 0.03;
        sparkle.alphaSpeed = -0.5;
        sparkle.color = [UIColor colorWithRed:1.0 green:1.0 blue:0.8 alpha:1.0].CGColor;

        // Star shape
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 30), NO, 0);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
        CGContextFillEllipseInRect(ctx, CGRectMake(5, 5, 20, 20));
        UIImage *starImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        sparkle.contents = (id)starImage.CGImage;
        [cells addObject:sparkle];
    }

    celebrationEmitter.emitterCells = cells;
    [self.view.layer addSublayer:celebrationEmitter];

    // Celebration haptic pattern
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self->hapticMedium impactOccurred];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self->hapticLight impactOccurred];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self->hapticMedium impactOccurred];
    });

    // Stop confetti after delay
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->celebrationEmitter.birthRate = 0;

        // Remove after particles fade
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self->celebrationEmitter removeFromSuperlayer];
            self->celebrationEmitter = nil;
        });
    });

    // Pulse the results container
    [self pulseResultsContainer];
}

- (void)pulseResultsContainer {
    CABasicAnimation *borderPulse = [CABasicAnimation animationWithKeyPath:@"borderColor"];
    borderPulse.fromValue = (id)[UIColor colorWithRed:0.5 green:0.4 blue:0.9 alpha:0.5].CGColor;
    borderPulse.toValue = (id)[UIColor colorWithRed:1.0 green:0.84 blue:0.0 alpha:1.0].CGColor;
    borderPulse.duration = 0.3;
    borderPulse.autoreverses = YES;
    borderPulse.repeatCount = 3;
    [resultsContainerView.layer addAnimation:borderPulse forKey:@"borderPulse"];

    CABasicAnimation *scalePulse = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scalePulse.fromValue = @(1.0);
    scalePulse.toValue = @(1.02);
    scalePulse.duration = 0.2;
    scalePulse.autoreverses = YES;
    scalePulse.repeatCount = 2;
    scalePulse.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [resultsContainerView.layer addAnimation:scalePulse forKey:@"scalePulse"];
}

- (void)addConfidenceCountUpAnimation:(UILabel *)label toValue:(float)targetValue {
    // Animate the number counting up
    __block float currentValue = 0;
    float increment = targetValue / 20.0;

    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.03 repeats:YES block:^(NSTimer *timer) {
        currentValue += increment;
        if (currentValue >= targetValue) {
            currentValue = targetValue;
            [timer invalidate];
        }
        label.text = [NSString stringWithFormat:@"%.0f%%", currentValue];
    }];

    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

@end
