# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**What? Where? (rzCoreMLWhatWhere)** is an iOS app demonstrating Apple's CoreML framework for image classification. It runs six different ML models simultaneously on a selected image and displays each model's prediction with confidence percentages.

- **Bundle ID**: org.zimmelman.whatwhere
- **Display Name**: Local AI Brilliance!
- **Target iOS Version**: iOS 12.0+ (Debug target: iOS 16.6)
- **Language**: Objective-C
- **Current Version**: 0.6 (Build 14)

## Build Commands

```bash
# Build for debug
xcodebuild -project rzCoreMLWhatWhere.xcodeproj -scheme rzCoreMLWhatWhere -configuration Debug

# Build for release
xcodebuild -project rzCoreMLWhatWhere.xcodeproj -scheme rzCoreMLWhatWhere -configuration Release

# Clean build
xcodebuild -project rzCoreMLWhatWhere.xcodeproj -scheme rzCoreMLWhatWhere clean

# List available simulators
xcrun simctl list devices
```

## Architecture

### Core Structure
This is a **UIKit storyboard-based iOS app** written in Objective-C with a single-view architecture. All main functionality is in `ViewController.m`.

### ML Models Included
Six CoreML models are bundled for image classification:

| Model | Input Size | Type |
|-------|-----------|------|
| Inceptionv3 | 299x299 | Object classification |
| SqueezeNet | 227x227 | Object classification |
| GoogLeNetPlaces | 224x224 | Scene/place classification |
| VGG16 | 224x224 | Object classification |
| Resnet50 | 224x224 | Object classification |
| MobileNet | 224x224 | Object classification |

### Key Components

**ViewController.m** - Main controller containing:
- Model initialization in `viewWillAppear:` (ViewController.m:55-62)
- Image analysis in `myAnalyzeTheImage` (ViewController.m:125-284)
- Pixel buffer creation in `myMakePixelBufferWithImage:ofSize:` (ViewController.m:382-398)
- Image selection via Photo Library and Camera

**Processing Flow**:
1. User selects image from Photo Library or Camera
2. `myAnalyzeTheImage` creates appropriately-sized pixel buffers for each model
3. Each model runs prediction and returns classification + confidence
4. Results display with color-coded confidence (red < 30%, yellow 30-80%, green > 80%)

### Image to Pixel Buffer Conversion
The `myMakePixelBufferWithImage:ofSize:` method (ViewController.m:382) handles critical image preprocessing:
- Creates `CIContext` for Core Image operations
- Scales image to model's required input dimensions using `CGAffineTransformMakeScale`
- Creates `CVPixelBuffer` with `kCVPixelFormatType_32BGRA` format
- Renders scaled image into pixel buffer

### UI Structure
- Main.storyboard contains the single-view interface
- UIImageView for displaying selected image
- Six sets of labels (model name, confidence %, classification result)
- Buttons for Camera, Photo Library, and Analyze
- UIActivityIndicatorView for loading state

## Important Notes

### Model Input Requirements
Each model requires a specific input size. Incorrect sizing will cause prediction failures:
- Inceptionv3: 299x299
- SqueezeNet: 227x227
- All others: 224x224

### Required Permissions
- `NSCameraUsageDescription` - Camera access
- `NSPhotoLibraryUsageDescription` - Photo library access

### Threading
Analysis runs on the main thread. The activity indicator uses `performSelectorOnMainThread:withObject:waitUntilDone:` to ensure UI updates occur properly.
