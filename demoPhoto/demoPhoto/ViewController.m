//
//  ViewController.m
//  demoPhoto
//
//  Created by TechmasterVietNam on 5/31/13.
//  Copyright (c) 2013 TechmasterVietNam. All rights reserved.
//

#import "ViewController.h"
#import "GPUImage.h"
#import "GPUImagePixellatePositionFilter.h"
#import <QuartzCore/QuartzCore.h>
#import "GPUImageFilter.h"


@interface ViewController () {
    UIImage *originalImage;
    GPUImagePicture* stillImageSource;
    UIImage* newImage;
    CGRect rectToZoomTo;
    float width;
    float height;
    int num ;
    CGPoint touchPoint;
}
@property(strong,nonatomic) UIImageView* selectedImageView;
@property (readwrite, nonatomic) UISlider* sliderRadius;
@property (readwrite, nonatomic) UISlider* sliderWidth;
@property (readwrite, nonatomic) UISlider* sliderHeight;
@property (readwrite, nonatomic) UISlider* sliderRotate;

@property (readwrite, nonatomic) CGRect RectSize;

@property(readwrite,nonatomic) GPUImageCropFilter *cropFilter;
@property(readwrite,nonatomic) GPUImagePixellateFilter* pixel;

@property(readwrite,nonatomic) GPUImageView *subView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property(readwrite,nonatomic) UIImageView* imageView;
@property(readwrite,nonatomic) UIView* rotateView;
@property(readwrite,nonatomic) UIView* rotateView1;

@end
@implementation ViewController
@synthesize cropFilter,pixel,scrollView,imageView,sliderRadius,RectSize,rotateView,subView,rectangle,circle,toolBar,sliderHeight,sliderWidth,rotateView1,sliderRotate;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGRect scrollViewFrame = self.scrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    self.scrollView.minimumZoomScale = minScale;
    
    self.scrollView.maximumZoomScale = 1.0f;
    self.scrollView.zoomScale = minScale;
    
    [self centerScrollViewContents];
}


- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    touchPoint=[gesture locationInView:self.scrollView];
    pixel.fractionalWidthOfAPixel = 0.015;
    NSLog(@"X location: %f", touchPoint.x);
    NSLog(@"Y Location: %f", touchPoint.y);
    NSLog(@"%i",num);
    
    rotateView.transform = CGAffineTransformMakeRotation(0);
    rotateView1.transform = CGAffineTransformMakeRotation(0);
    rotateView.center = touchPoint;
    rotateView1.center = CGPointMake(rotateView.frame.size.width/2, rotateView.frame.size.height/2);
    
    [stillImageSource addTarget:cropFilter];
    
    [stillImageSource processImage];
    
    [cropFilter setCropRegion:CGRectMake(0, 0, 1, 1)];

    if (scrollView.contentSize.height<scrollView.frame.size.height) {
        [subView setFrame:CGRectMake(0,(scrollView.frame.size.height-scrollView.contentSize.height)/2, scrollView.contentSize.width, scrollView.contentSize.height)];
    }else if (scrollView.contentSize.width<scrollView.frame.size.width){
        [subView setFrame:CGRectMake(scrollView.contentSize.width/2+(scrollView.frame.size.width-scrollView.contentSize.width)/2,0, scrollView.contentSize.width, scrollView.contentSize.height)];
    }else if (scrollView.contentSize.width>=scrollView.frame.size.width && scrollView.contentSize.height>=scrollView.frame.size.height){
        [subView setFrame:CGRectMake(0,0, scrollView.contentSize.width, scrollView.contentSize.height)];
    }else if (scrollView.contentSize.width<=scrollView.frame.size.width && scrollView.contentSize.height<=scrollView.frame.size.height){
        [subView setFrame:CGRectMake(scrollView.contentSize.width/2+(scrollView.frame.size.width-scrollView.contentSize.width)/2, scrollView.contentSize.height/2+(scrollView.frame.size.height-scrollView.contentSize.height)/2, scrollView.contentSize.width, scrollView.contentSize.height)];
    }
    
    [imageView setFrame:subView.frame];
    
    imageView.center = CGPointMake(rotateView1.frame.size.width/2 + (subView.center.x-rotateView.center.x), rotateView1.frame.size.height/2 + (subView.center.y-rotateView.center.y));
    
    UIImage *cropImage = [cropFilter imageFromCurrentlyProcessedOutput];
    
    GPUImagePicture* cropPicture = [[GPUImagePicture alloc] initWithImage:cropImage];
    
    [cropPicture addTarget:pixel];
    
    [cropPicture processImage];
    
    UIImage *pixelImage = [pixel imageFromCurrentlyProcessedOutput];
    
    UIGraphicsBeginImageContext(self.scrollView.contentSize);
    
    imageView.image = pixelImage;
    
    [self.scrollView addSubview:rotateView];

    UIGraphicsEndImageContext();
    
    self.selectedImageView.image = originalImage;
    
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.selectedImageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *output = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain
                                                              target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = output;
    
    UIBarButtonItem *input = [[UIBarButtonItem alloc] initWithTitle:@"Album" style:UIBarButtonItemStylePlain
                                                             target:self action:@selector(input)];
    self.navigationItem.leftBarButtonItem = input;
    
    UIButton *camera = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    
    [[camera layer] setCornerRadius:7.0f];
    
    [camera setImage:[UIImage imageNamed:@"camera.png"] forState:UIControlStateNormal];
    [camera addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = camera;
    
    RectSize = CGRectMake(0, 0,200,150);
    
    self.subView = [[GPUImageView alloc] initWithFrame:RectSize];
    self.subView.center = CGPointMake(self.subView.frame.size.width/2,self.subView.frame.size.height/2);
    
    rotateView = [[UIView alloc] initWithFrame:CGRectMake(0,0,100,100)];
    rotateView.clipsToBounds =YES;
    [rotateView.layer setMasksToBounds:YES];
    [rotateView.layer setBorderWidth:0.6];
    [rotateView.layer setCornerRadius:rotateView.frame.size.width/2];
    
    rotateView1 = [[UIView alloc] initWithFrame:rotateView.frame];

    imageView =[[UIImageView alloc] initWithFrame:self.subView.frame];
    imageView.center = CGPointMake(rotateView.frame.size.width/2, rotateView.frame.size.height/2);
    [rotateView addSubview:rotateView1];
    [rotateView1 addSubview:imageView];
    
    pixel = [[GPUImagePixellateFilter alloc]init];
    
    cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(self.subView.frame.origin.x/self.view.frame.size.width, self.subView.frame.origin.y/self.view.frame.size.height,self.subView.frame.size.width/self.view.frame.size.width, self.subView.frame.size.height/self.view.frame.size.height)];
    
    sliderRadius = [[UISlider alloc] initWithFrame:CGRectMake(20, 300, 280, 30)];
    [sliderRadius addTarget:self action:@selector(changeRadius) forControlEvents:UIControlEventValueChanged];
    
    sliderHeight = [[UISlider alloc] initWithFrame:CGRectMake(20, 300, 280, 30)];
    [sliderHeight addTarget:self action:@selector(changeHeight) forControlEvents:UIControlEventValueChanged];
    
    sliderWidth = [[UISlider alloc] initWithFrame:CGRectMake(20, 270, 280, 30)];
    [sliderWidth addTarget:self action:@selector(changeWidth) forControlEvents:UIControlEventValueChanged];
    
    sliderRotate = [[UISlider alloc] initWithFrame:CGRectMake(20, 330, 280, 30)];
    [sliderRotate addTarget:self action:@selector(changeRotate) forControlEvents:UIControlEventValueChanged];
    sliderRotate.minimumValue = 0;
    sliderRotate.maximumValue = M_PI*2;
    
    originalImage = [[UIImage alloc] init];
    num=1;
}
- (IBAction)Rectange:(id)sender {
    num = 3;
    [rotateView setFrame:CGRectMake(rotateView.frame.origin.x, rotateView.frame.origin.y, sliderWidth.value,sliderHeight.value)];

    [rotateView1 setFrame:rotateView.frame];
    rotateView1.center = CGPointMake(rotateView.frame.size.width/2, rotateView.frame.size.height/2);
    
    [imageView setFrame:subView.frame];
    
    imageView.center = CGPointMake(rotateView1.frame.size.width/2 + (subView.center.x-rotateView.center.x), rotateView1.frame.size.height/2 + (subView.center.y-rotateView.center.y));
    
    [rotateView.layer setCornerRadius:0];
    rotateView.layer.mask = nil;
    rotateView.center = scrollView.center;

    [sliderRadius removeFromSuperview];
    [self.view addSubview:sliderHeight];
    [self.view addSubview:sliderWidth];
    [self.view addSubview:sliderRotate];
}

- (IBAction)ellipse:(id)sender {
    num = 2;
    [rotateView setFrame:CGRectMake(rotateView.frame.origin.x, rotateView.frame.origin.y, sliderWidth.value,sliderHeight.value)];
    
    [rotateView1 setFrame:rotateView.frame];
    rotateView1.center = CGPointMake(rotateView.frame.size.width/2, rotateView.frame.size.height/2);
    
    [imageView setFrame:subView.frame];
    
    imageView.center = CGPointMake(rotateView1.frame.size.width/2 + (subView.center.x-rotateView.center.x), rotateView1.frame.size.height/2 + (subView.center.y-rotateView.center.y));
    
    [rotateView.layer setCornerRadius:0];
    
    [sliderRadius removeFromSuperview];
    [self.view addSubview:sliderHeight];
    [self.view addSubview:sliderWidth];
    [self.view addSubview:sliderRotate];
    
    rotateView.center = scrollView.center;
    
    CAShapeLayer *shapeMask = [CAShapeLayer layer];
    UIBezierPath *someClosedUIBezierPath = [UIBezierPath bezierPathWithOvalInRect:rotateView.bounds];
    shapeMask.path = someClosedUIBezierPath.CGPath;
    rotateView.layer.mask = shapeMask;

}

- (IBAction)Circle:(id)sender {
    num = 1;
    
    [rotateView setFrame:CGRectMake(rotateView.frame.origin.x, rotateView.frame.origin.y, sqrtf(sliderRadius.value*sliderRadius.value/2), sqrtf(sliderRadius.value*sliderRadius.value/2))];
    [rotateView1 setFrame:rotateView.frame];
    rotateView1.center = CGPointMake(rotateView.frame.size.width/2, rotateView.frame.size.height/2);
    
    [rotateView.layer setCornerRadius:rotateView.frame.size.height/2];
    
    rotateView.center = touchPoint;
    
    [imageView setFrame:subView.frame];
    
    imageView.center = CGPointMake(rotateView1.frame.size.width/2 + (subView.center.x-rotateView.center.x), rotateView1.frame.size.height/2 + (subView.center.y-rotateView.center.y));
    
    [self.view addSubview:sliderRadius];

    
}

-(void)changeRadius{
            
    [rotateView setFrame:CGRectMake(rotateView.frame.origin.x, rotateView.frame.origin.y, sqrtf(sliderRadius.value*sliderRadius.value/2), sqrtf(sliderRadius.value*sliderRadius.value/2))];
    rotateView.center = touchPoint;
    
    [rotateView1 setFrame:rotateView.frame];
    rotateView1.center = CGPointMake(rotateView.frame.size.width/2, rotateView.frame.size.height/2);
    
    [imageView setFrame:subView.frame];
    
    imageView.center = CGPointMake(rotateView1.frame.size.width/2 + (subView.center.x-rotateView.center.x), rotateView1.frame.size.height/2 + (subView.center.y-rotateView.center.y));
    
    [rotateView.layer setCornerRadius:rotateView.frame.size.width/2];
}

-(void)changeHeight{
    
    [rotateView setFrame:CGRectMake(rotateView.frame.origin.x, rotateView.frame.origin.y, rotateView.frame.size.width,sliderHeight.value)];
    rotateView.center = touchPoint;
    
    [rotateView1 setFrame:rotateView.frame];
    rotateView1.center = CGPointMake(rotateView.frame.size.width/2, rotateView.frame.size.height/2);
    
    if (num==2) {
        CAShapeLayer *shapeMask = [CAShapeLayer layer];
        UIBezierPath *someClosedUIBezierPath = [UIBezierPath bezierPathWithOvalInRect:rotateView.bounds];
        shapeMask.path = someClosedUIBezierPath.CGPath;
        rotateView.layer.mask = shapeMask;
    }
    [imageView setFrame:subView.frame];
    
    imageView.center = CGPointMake(rotateView1.frame.size.width/2 + (subView.center.x-rotateView.center.x), rotateView1.frame.size.height/2 + (subView.center.y-rotateView.center.y));
}

-(void)changeWidth{
    
    [rotateView setFrame:CGRectMake(rotateView.frame.origin.x, rotateView.frame.origin.y, sliderWidth.value,rotateView.frame.size.height)];
    rotateView.center = touchPoint;
    
    [rotateView1 setFrame:rotateView.frame];
    rotateView1.center = CGPointMake(rotateView.frame.size.width/2, rotateView.frame.size.height/2);
    
    if (num==2) {
        CAShapeLayer *shapeMask = [CAShapeLayer layer];
        UIBezierPath *someClosedUIBezierPath = [UIBezierPath bezierPathWithOvalInRect:rotateView.bounds];
        shapeMask.path = someClosedUIBezierPath.CGPath;
        rotateView.layer.mask = shapeMask;
    }
    [imageView setFrame:subView.frame];
    
    imageView.center = CGPointMake(rotateView1.frame.size.width/2 + (subView.center.x-rotateView.center.x), rotateView1.frame.size.height/2 + (subView.center.y-rotateView.center.y));
}

-(void)changeRotate{
    
    rotateView.transform = CGAffineTransformMakeRotation(sliderRotate.value);
    rotateView1.transform = CGAffineTransformMakeRotation(-sliderRotate.value);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *alertTitle;
    NSString *alertMessage;
    if(!error)
    {
        alertTitle   = @"Image Saved";
        alertMessage = @"Image saved to photo album successfully.";
    }
    else
    {
        alertTitle   = @"Error";
        alertMessage = @"Unable to save to photo album.";
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                    message:alertMessage
                                                   delegate:self
                                          cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void)input{
    
    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
    photoPicker.delegate = self;
    photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:photoPicker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)photoPicker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.selectedImageView removeFromSuperview];
    
    originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    stillImageSource = [[GPUImagePicture alloc] initWithImage:originalImage];
    
    self.selectedImageView = [[UIImageView alloc] initWithImage:originalImage];
    
    self.selectedImageView.frame = CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, originalImage.size.width, originalImage.size.height);
    
    [scrollView addSubview:self.selectedImageView];
    
    scrollView.contentSize = originalImage.size;
   
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    [scrollView addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:doubleTapRecognizer];
    
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    [self.scrollView addGestureRecognizer:twoFingerTapRecognizer];
    
    if (originalImage.size.width >= originalImage.size.height) {
        sliderHeight.maximumValue = originalImage.size.width;
        sliderWidth.maximumValue = originalImage.size.width;
        sliderRadius.maximumValue = originalImage.size.width;
        
        sliderHeight.value = originalImage.size.width*scrollView.zoomScale/4;
        sliderWidth.value = originalImage.size.width*scrollView.zoomScale/4;
        sliderRadius.value = originalImage.size.width*scrollView.zoomScale/4;

    }
    if (originalImage.size.width<= originalImage.size.height) {
        sliderHeight.maximumValue = originalImage.size.height;
        sliderWidth.maximumValue = originalImage.size.height;
        sliderRadius.maximumValue = originalImage.size.height;
        
        sliderHeight.value = originalImage.size.height*scrollView.zoomScale/4;
        sliderWidth.value = originalImage.size.height*scrollView.zoomScale/4;
        sliderRadius.value = originalImage.size.height*scrollView.zoomScale/4;
    }
    
    [self centerScrollViewContents];
    
    [self.view addSubview:self.scrollView];
    
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.selectedImageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.selectedImageView.frame = contentsFrame;
}
- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
    // 1
    CGPoint pointInView = [recognizer locationInView:self.scrollView];
    
    // 2
    CGFloat newZoomScale = self.scrollView.zoomScale * 1.5f;
    newZoomScale = MIN(newZoomScale, self.scrollView.maximumZoomScale);
    
    // 3
    CGSize scrollViewSize = self.scrollView.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 1.0f);
    CGFloat y = pointInView.y - (h / 1.0f);
    
    rectToZoomTo = CGRectMake(x, y, w, h);
    
    // 4
    [self.scrollView zoomToRect:rectToZoomTo animated:YES];
    [self centerScrollViewContents];
    
}
- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer {
    CGFloat newZoomScale = self.scrollView.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, self.scrollView.minimumZoomScale);
    [self.scrollView setZoomScale:newZoomScale animated:YES];
    [self centerScrollViewContents];

}
-(void)save{
    
    if (scrollView.contentSize.height<self.view.frame.size.height) {
        [cropFilter setCropRegion:CGRectMake(self.subView.frame.origin.x/self.scrollView.contentSize.width,(self.subView.frame.origin.y-(self.scrollView.frame.size.height-scrollView.contentSize.height)/2)/self.scrollView.contentSize.height,self.subView.frame.size.width/self.scrollView.contentSize.width, self.subView.frame.size.height/self.scrollView.contentSize.height)];
    }
    if (scrollView.contentSize.width<self.view.frame.size.width){
        [cropFilter setCropRegion:CGRectMake((self.subView.frame.origin.x-(self.scrollView.frame.size.width-scrollView.contentSize.width)/2)/self.scrollView.contentSize.width,self.subView.frame.origin.y/self.scrollView.contentSize.height,self.subView.frame.size.width/self.scrollView.contentSize.width, self.subView.frame.size.height/self.scrollView.contentSize.height)];
    }
    if (scrollView.contentSize.width>=self.view.frame.size.width && scrollView.contentSize.height>=self.view.frame.size.height){
        [cropFilter setCropRegion:CGRectMake(self.subView.frame.origin.x/self.scrollView.contentSize.width,self.subView.frame.origin.y/self.scrollView.contentSize.height,self.subView.frame.size.width/self.scrollView.contentSize.width, self.subView.frame.size.height/self.scrollView.contentSize.height)];
    }
    
    [stillImageSource addTarget:cropFilter];
    
    [stillImageSource processImage];
    
    UIImage *cropImage = [cropFilter imageFromCurrentlyProcessedOutput];
    
    GPUImagePicture* cropPicture = [[GPUImagePicture alloc] initWithImage:cropImage];
    
    [cropPicture addTarget:pixel];
    
    [cropPicture processImage];
    
    UIImage *pixelImage = [pixel imageFromCurrentlyProcessedOutput];
    
    float imageScale = sqrtf(powf(self.selectedImageView.transform.a, 2.f) + powf(self.selectedImageView.transform.c, 2.f));
    CGFloat widthScale = self.selectedImageView.bounds.size.width / self.selectedImageView.image.size.width;
    CGFloat heightScale = self.selectedImageView.bounds.size.height / self.selectedImageView.image.size.height;
    float contentScale = MIN(widthScale, heightScale);
    float effectiveScale = imageScale * contentScale;
    
    CGSize captureSize = CGSizeMake(self.selectedImageView.bounds.size.width / effectiveScale, self.selectedImageView.bounds.size.height / effectiveScale);

    UIGraphicsBeginImageContextWithOptions(captureSize, YES, 0.0);
        
   
    if (scrollView.contentSize.height<self.view.frame.size.height) {
        [rotateView setFrame:CGRectMake(rotateView.frame.origin.x / effectiveScale , (rotateView.frame.origin.y-(self.scrollView.frame.size.height-scrollView.contentSize.height)/2)/ effectiveScale, sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2)/ effectiveScale, sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2)/ effectiveScale)];
    }
    
    if (scrollView.contentSize.width<self.view.frame.size.width){
        [rotateView setFrame:CGRectMake((rotateView.frame.origin.x-(self.scrollView.frame.size.width-scrollView.contentSize.width)/2)/ effectiveScale , rotateView.frame.origin.y/ effectiveScale, sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2)/ effectiveScale, sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2)/ effectiveScale)];
    }
    
    if (scrollView.contentSize.width<self.view.frame.size.width && scrollView.contentSize.height<self.view.frame.size.height){
        [rotateView setFrame:CGRectMake((rotateView.frame.origin.x-(self.scrollView.frame.size.width-scrollView.contentSize.width)/2)/ effectiveScale , rotateView.frame.origin.y/ effectiveScale, sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2)/ effectiveScale, sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2)/ effectiveScale)];
    }
    
    if(scrollView.contentSize.height>=self.view.frame.size.height && scrollView.contentSize.width>=self.view.frame.size.width){
        [rotateView setFrame:CGRectMake(rotateView.frame.origin.x/ effectiveScale, rotateView.frame.origin.y/ effectiveScale, sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2)/ effectiveScale, sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2)/ effectiveScale)];
    }
    
    [rotateView.layer setCornerRadius:rotateView.frame.size.width/2];

    [imageView setFrame:CGRectMake(imageView.frame.origin.x/ effectiveScale, imageView.frame.origin.y/ effectiveScale, imageView.frame.size.width/ effectiveScale, imageView.frame.size.height/ effectiveScale)];
    
    imageView.center = CGPointMake(rotateView.frame.size.width/2, rotateView.frame.size.height/2);
    
    imageView.image = pixelImage;
    
    [self.selectedImageView addSubview:rotateView];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1/effectiveScale, 1/effectiveScale);
    
    [self.selectedImageView.layer renderInContext:context];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil);
    
    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
    photoPicker.delegate = self;
    photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:photoPicker animated:YES completion:NULL];
}
@end