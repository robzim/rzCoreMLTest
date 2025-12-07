//
//  ViewController.h
//  rzCoreMLWhatWhere
//
//  Created by Robert Zimmelman on 7/8/17.
//  Copyright © 2017 Robert Zimmelman. All rights reserved.
//

// Latest CoreML Models (2024)
#import "FastViTMA36F16.h"
#import "FastViTT8F16.h"
#import "MobileNetV2FP16.h"
#import "MobileNetV2Int8LUT.h"
#import "Resnet50FP16.h"
#import "Resnet50Int8LUT.h"


@import UIKit;
@import ImageIO;
@import AudioToolbox;
@import Vision;

@interface ViewController : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITableViewDataSource,UITableViewDelegate>

// Gradient and styling layers
@property (nonatomic, strong) CAGradientLayer *backgroundGradient;
@property (nonatomic, strong) UIImpactFeedbackGenerator *hapticLight;
@property (nonatomic, strong) UIImpactFeedbackGenerator *hapticMedium;
@property (nonatomic, strong) UINotificationFeedbackGenerator *hapticNotification;

// Welcome overlay
@property (nonatomic, strong) UIView *welcomeOverlay;
@property (nonatomic, strong) UIView *welcomeCard;
@property (nonatomic, strong) CAGradientLayer *welcomeShimmerLayer;
@property (nonatomic, strong) CAGradientLayer *welcomeBorderGradient;

// Results table view
@property (nonatomic, strong) UIView *resultsContainerView;
@property (nonatomic, strong) UITableView *resultsTableView;
@property (nonatomic, strong) NSMutableArray *resultsData;  // Array of dictionaries with model, item, confidence
@property (nonatomic, assign) BOOL isAnimatingResults;
@property (nonatomic, strong) CAEmitterLayer *celebrationEmitter;
@property (nonatomic, assign) NSInteger celebrationIndex;

// Card views for results
@property (nonatomic, strong) NSArray *resultCardViews;

// Arrays for managing result rows (for sorting animation)
@property (nonatomic, strong) NSMutableArray *resultRows;  // Array of label triplets
@property (nonatomic, strong) NSMutableArray *originalCenters;  // Original Y positions

// Buttons for styling
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *libraryButton;
@property (weak, nonatomic) IBOutlet UIButton *aboutButton;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;

// New 2024 CoreML Models
@property FastViTMA36F16 *myFastViTMA36Model;
@property FastViTT8F16 *myFastViTT8Model;
@property MobileNetV2FP16 *myMobileNetV2FP16Model;
@property MobileNetV2Int8LUT *myMobileNetV2Int8Model;
@property Resnet50FP16 *myResnet50FP16Model;
@property Resnet50Int8LUT *myResnet50Int8Model;

@property (weak, nonatomic) IBOutlet UIButton *myAnalyzeButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *myActivityIndicator;

@property (weak, nonatomic) IBOutlet UIImageView *myImage;
@property (weak, nonatomic) IBOutlet UIStackView *mainStackView;

// Labels for model categories (renamed for new models)
@property (weak, nonatomic) IBOutlet UILabel *myFastViTMA36Category;
@property (weak, nonatomic) IBOutlet UILabel *myFastViTT8Category;
@property (weak, nonatomic) IBOutlet UILabel *myMobileNetV2FP16Category;
@property (weak, nonatomic) IBOutlet UILabel *myMobileNetV2Int8Category;
@property (weak, nonatomic) IBOutlet UILabel *myResnet50FP16Category;
@property (weak, nonatomic) IBOutlet UILabel *myResnet50Int8Category;

// Labels for confidence percentages
@property (weak, nonatomic) IBOutlet UILabel *myFastViTMA36Pct;
@property (weak, nonatomic) IBOutlet UILabel *myFastViTT8Pct;
@property (weak, nonatomic) IBOutlet UILabel *myMobileNetV2FP16Pct;
@property (weak, nonatomic) IBOutlet UILabel *myMobileNetV2Int8Pct;
@property (weak, nonatomic) IBOutlet UILabel *myResnet50FP16Pct;
@property (weak, nonatomic) IBOutlet UILabel *myResnet50Int8Pct;

// Labels for model names
@property (weak, nonatomic) IBOutlet UILabel *myFastViTMA36Label;
@property (weak, nonatomic) IBOutlet UILabel *myFastViTT8Label;
@property (weak, nonatomic) IBOutlet UILabel *myMobileNetV2FP16Label;
@property (weak, nonatomic) IBOutlet UILabel *myMobileNetV2Int8Label;
@property (weak, nonatomic) IBOutlet UILabel *myResnet50FP16Label;
@property (weak, nonatomic) IBOutlet UILabel *myResnet50Int8Label;



@property (strong,nonatomic) UIImagePickerController *myPicker;
@property (strong,nonatomic) UIImagePickerController *myCameraPicker;
@property NSString *myPlaceHolderText;

- (IBAction)myTakeAPhoto:(id)sender;

- (IBAction)myPickAnImage:(id)sender;

- (IBAction)myAnalyzeButtonWasPressed:(id)sender;


@end

