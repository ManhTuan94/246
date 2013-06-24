//
//  ViewController.m
//  demoPhoto
//
//  Created by TechmasterVietNam on 5/31/13.
//  Copyright (c) 2013 TechmasterVietNam. All rights reserved.
//

#import "elipse.h"
#import "GPUImage.h"
#import "GPUImagePixellatePositionFilter.h"
#import <QuartzCore/QuartzCore.h>
#import "GPUImageFilter.h"



@interface elipse () {
    UIImage *originalImage;
    GPUImagePicture* stillImageSource;
    UIImage* newImage;
    CGRect rectToZoomTo;
    float width;
    float height;
}
@property(strong,nonatomic) UIImageView* selectedImageView;
@property (readwrite, nonatomic) UISlider* sliderRadius;
@property (readwrite, nonatomic) CGRect RectSize;

@property(readwrite,nonatomic) GPUImageCropFilter *cropFilter;
@property(readwrite,nonatomic) GPUImagePixellateFilter* pixel;

@property(readwrite,nonatomic) GPUImageView *subView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property(readwrite,nonatomic) UIImageView* imageView;
@property(readwrite,nonatomic) UIView* rotateView;

@end

@implementation elipse
@synthesize cropFilter,pixel,scrollView,imageView,sliderRadius,RectSize,rotateView,subView,rectangle,circle,toolBar;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 4
    CGRect scrollViewFrame = self.scrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    self.scrollView.minimumZoomScale = minScale;
    
    // 5
    self.scrollView.maximumZoomScale = 1.0f;
    self.scrollView.zoomScale = minScale;
    
    // 6
    [self centerScrollViewContents];
}

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    CGPoint touchPoint=[gesture locationInView:self.scrollView];
    
    NSLog(@"X location: %f", touchPoint.x);
    NSLog(@"Y Location: %f", touchPoint.y);
    
    [subView setFrame:CGRectMake(subView.frame.origin.x, subView.frame.origin.y, sliderRadius.value*scrollView.zoomScale, sliderRadius.value*scrollView.zoomScale)];
    subView.center = touchPoint;
    
    [imageView setFrame:subView.frame];
    
    [rotateView setFrame:CGRectMake(rotateView.frame.origin.x, rotateView.frame.origin.y, sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2), sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2))];
    rotateView.center = subView.center;
    
    imageView.center = CGPointMake(rotateView.frame.size.width/2, rotateView.frame.size.height/2);
    
    [rotateView.layer setCornerRadius:rotateView.frame.size.width/2];
    
    if (touchPoint.x<(self.subView.frame.size.width/2)) {
        self.subView.center = CGPointMake(self.subView.frame.size.width/2, touchPoint.y);
    }
    if (touchPoint.y<(self.subView.frame.size.height/2)) {
        self.subView.center = CGPointMake(touchPoint.x,self.subView.frame.size.height/2);
    }
    if (touchPoint.y<(self.subView.frame.size.height/2) && touchPoint.x<(self.subView.frame.size.width/2)) {
        self.subView.center = CGPointMake(self.subView.frame.size.width/2,self.subView.frame.size.height/2);
    }
    //    if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
    
    //    }
    [stillImageSource addTarget:cropFilter];
    
    [stillImageSource processImage];
    
    
    if (scrollView.contentSize.height<self.view.frame.size.height) {
        
        if (touchPoint.x<=self.subView.frame.size.width/2 && touchPoint.y<=(self.subView.frame.size.height/2+(self.scrollView.frame.size.height-self.scrollView.contentSize.height)/2) && touchPoint.y>=(self.scrollView.frame.size.height-self.scrollView.contentSize.height)/2){
            
            self.subView.center = CGPointMake(self.subView.frame.size.width/2,self.subView.frame.size.height/2+(self.scrollView.frame.size.height-self.scrollView.contentSize.height)/2);
            rotateView.center = subView.center;
            
            [cropFilter setCropRegion:CGRectMake(self.subView.frame.origin.x/self.scrollView.contentSize.width,(self.subView.frame.origin.y-(self.scrollView.frame.size.height-scrollView.contentSize.height)/2)/self.scrollView.contentSize.height,self.subView.frame.size.width/self.scrollView.contentSize.width, self.subView.frame.size.height/self.scrollView.contentSize.height)];
            
            [rotateView setFrame:CGRectMake(rotateView.frame.origin.x-(self.subView.frame.size.width/2-rotateView.frame.size.width/2), rotateView.frame.origin.y-(self.subView.frame.size.height/2-rotateView.frame.size.height/2), sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2), sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2))];
            
            imageView.center = CGPointMake(rotateView.frame.size.width/2+ subView.center.x-rotateView.center.x, rotateView.frame.size.height/2 + subView.center.y-rotateView.center.y);
        }else if (touchPoint.x<self.subView.frame.size.width/2) {
            self.subView.center = CGPointMake(self.subView.frame.size.width/2,touchPoint.y);
            rotateView.center = subView.center;
            
            [cropFilter setCropRegion:CGRectMake(self.subView.frame.origin.x/self.scrollView.contentSize.width,(self.subView.frame.origin.y-(self.scrollView.frame.size.height-scrollView.contentSize.height)/2)/self.scrollView.contentSize.height,self.subView.frame.size.width/self.scrollView.contentSize.width, self.subView.frame.size.height/self.scrollView.contentSize.height)];
            
            [rotateView setFrame:CGRectMake(rotateView.frame.origin.x-(self.subView.frame.size.width/2-rotateView.frame.size.width/2), rotateView.frame.origin.y, sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2), sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2))];
            
            imageView.center = CGPointMake(rotateView.frame.size.width/2+ subView.center.x-rotateView.center.x, rotateView.frame.size.height/2);
        }else if (touchPoint.y<(self.subView.frame.size.height/2+(self.scrollView.frame.size.height-self.scrollView.contentSize.height)/2) && touchPoint.y>(self.scrollView.frame.size.height-self.scrollView.contentSize.height)/2) {
            self.subView.center = CGPointMake(touchPoint.x,self.subView.frame.size.height/2+(self.scrollView.frame.size.height-self.scrollView.contentSize.height)/2);
            rotateView.center = subView.center;
            
            [cropFilter setCropRegion:CGRectMake(self.subView.frame.origin.x/self.scrollView.contentSize.width,(self.subView.frame.origin.y-(self.scrollView.frame.size.height-scrollView.contentSize.height)/2)/self.scrollView.contentSize.height,self.subView.frame.size.width/self.scrollView.contentSize.width, self.subView.frame.size.height/self.scrollView.contentSize.height)];
            
            [rotateView setFrame:CGRectMake(rotateView.frame.origin.x, rotateView.frame.origin.y-(self.subView.frame.size.height/2-rotateView.frame.size.height/2), sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2), sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2))];
            
            imageView.center = CGPointMake(rotateView.frame.size.width/2, rotateView.frame.size.height/2 + subView.center.y-rotateView.center.y);
        }else if (touchPoint.x>=self.subView.frame.size.width/2  && touchPoint.y>=(self.subView.frame.size.height/2+(self.scrollView.frame.size.height-self.scrollView.contentSize.height)/2)) {
            [cropFilter setCropRegion:CGRectMake(self.subView.frame.origin.x/self.scrollView.contentSize.width,(self.subView.frame.origin.y-(self.scrollView.frame.size.height-scrollView.contentSize.height)/2)/self.scrollView.contentSize.height,self.subView.frame.size.width/self.scrollView.contentSize.width, self.subView.frame.size.height/self.scrollView.contentSize.height)];
        }
    }else if (scrollView.contentSize.width<self.view.frame.size.width){
        
        if (touchPoint.x <= (self.subView.frame.size.width/2+(self.scrollView.frame.size.width-scrollView.contentSize.width)/2) && touchPoint.x >= (self.scrollView.frame.size.width-scrollView.contentSize.width)/2 && touchPoint.y <= (self.subView.frame.size.height/2)){
            self.subView.center = CGPointMake(self.subView.frame.size.width/2+(self.scrollView.frame.size.width-scrollView.contentSize.width)/2,self.subView.frame.size.height/2);
            
            rotateView.center = subView.center;
            
            [cropFilter setCropRegion:CGRectMake(((self.scrollView.frame.size.width-scrollView.contentSize.width)/2)/self.scrollView.contentSize.width,self.subView.frame.origin.y/self.scrollView.contentSize.height,self.subView.frame.size.width/self.scrollView.contentSize.width, self.subView.frame.size.height/self.scrollView.contentSize.height)];
            
            [rotateView setFrame:CGRectMake(rotateView.frame.origin.x-(self.subView.frame.size.width/2-rotateView.frame.size.width/2), rotateView.frame.origin.y-(self.subView.frame.size.height/2-rotateView.frame.size.height/2), sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2), sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2))];
            
            imageView.center = CGPointMake(rotateView.frame.size.width/2+ subView.center.x-rotateView.center.x, rotateView.frame.size.height/2 + subView.center.y-rotateView.center.y);
        }else if (touchPoint.x<(self.subView.frame.size.width/2+(self.scrollView.frame.size.width-scrollView.contentSize.width)/2) && touchPoint.x>= (self.scrollView.frame.size.width-scrollView.contentSize.width)/2) {
            self.subView.center = CGPointMake(self.subView.frame.size.width/2+(self.scrollView.frame.size.width-scrollView.contentSize.width)/2 , touchPoint.y);
            rotateView.center = subView.center;
            [cropFilter setCropRegion:CGRectMake((self.subView.frame.origin.x-(self.scrollView.frame.size.width-scrollView.contentSize.width)/2)/self.scrollView.contentSize.width,self.subView.frame.origin.y/self.scrollView.contentSize.height,self.subView.frame.size.width/self.scrollView.contentSize.width, self.subView.frame.size.height/self.scrollView.contentSize.height)];
            
            [rotateView setFrame:CGRectMake(rotateView.frame.origin.x-(self.subView.frame.size.width/2-rotateView.frame.size.width/2), rotateView.frame.origin.y, sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2), sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2))];
            imageView.center = CGPointMake(rotateView.frame.size.width/2+ subView.center.x-rotateView.center.x, rotateView.frame.size.height/2);
        }else if (touchPoint.y<(self.subView.frame.size.height/2)) {
            self.subView.center = CGPointMake(touchPoint.x,self.subView.frame.size.height/2);
            rotateView.center = subView.center;
            [cropFilter setCropRegion:CGRectMake((self.subView.frame.origin.x-(self.scrollView.frame.size.width-scrollView.contentSize.width)/2)/self.scrollView.contentSize.width,self.subView.frame.origin.y/self.scrollView.contentSize.height,self.subView.frame.size.width/self.scrollView.contentSize.width, self.subView.frame.size.height/self.scrollView.contentSize.height)];
            
            [rotateView setFrame:CGRectMake(rotateView.frame.origin.x, rotateView.frame.origin.y-(self.subView.frame.size.height/2-rotateView.frame.size.height/2), sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2), sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2))];
            imageView.center = CGPointMake(rotateView.frame.size.width/2, rotateView.frame.size.height/2 + subView.center.y-rotateView.center.y);
        }else if (touchPoint.x>=(self.subView.frame.size.width/2+(self.scrollView.frame.size.width-scrollView.contentSize.width)/2)  && touchPoint.y>=(self.subView.frame.size.height/2)) {
            [cropFilter setCropRegion:CGRectMake((self.subView.frame.origin.x-(self.scrollView.frame.size.width-scrollView.contentSize.width)/2)/self.scrollView.contentSize.width,self.subView.frame.origin.y/self.scrollView.contentSize.height,self.subView.frame.size.width/self.scrollView.contentSize.width, self.subView.frame.size.height/self.scrollView.contentSize.height)];
        }
    }else if (scrollView.contentSize.width>=self.view.frame.size.width && scrollView.contentSize.height>=self.view.frame.size.height){
        
        if (touchPoint.x <= self.subView.frame.size.width/2 && touchPoint.y <= self.subView.frame.size.height/2){
            
            NSLog(@"day roi");
            
            self.subView.center = CGPointMake(self.subView.frame.size.width/2,self.subView.frame.size.height/2);
            
            rotateView.center = subView.center;
            
            [cropFilter setCropRegion:CGRectMake(self.subView.frame.origin.x/self.scrollView.contentSize.width,self.subView.frame.origin.y/self.scrollView.contentSize.height,self.subView.frame.size.width/self.scrollView.contentSize.width, self.subView.frame.size.height/self.scrollView.contentSize.height)];
            
            [rotateView setFrame:CGRectMake(rotateView.frame.origin.x-(self.subView.frame.size.width/2-rotateView.frame.size.width/2), rotateView.frame.origin.y-(self.subView.frame.size.height/2-rotateView.frame.size.height/2), sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2), sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2))];
            
            imageView.center = CGPointMake(rotateView.frame.size.width/2+ subView.center.x-rotateView.center.x, rotateView.frame.size.height/2 + subView.center.y-rotateView.center.y);
        }else if (touchPoint.x<self.subView.frame.size.width/2) {
            self.subView.center = CGPointMake(self.subView.frame.size.width/2, touchPoint.y);
            rotateView.center = subView.center;
            
            NSLog(@"x");
            
            [cropFilter setCropRegion:CGRectMake(self.subView.frame.origin.x/self.scrollView.contentSize.width,self.subView.frame.origin.y/self.scrollView.contentSize.height,self.subView.frame.size.width/self.scrollView.contentSize.width, self.subView.frame.size.height/self.scrollView.contentSize.height)];
            
            [rotateView setFrame:CGRectMake(rotateView.frame.origin.x-(self.subView.frame.size.width/2-rotateView.frame.size.width/2), rotateView.frame.origin.y, sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2), sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2))];
            imageView.center = CGPointMake(rotateView.frame.size.width/2+ subView.center.x-rotateView.center.x, rotateView.frame.size.height/2);
        }else if (touchPoint.y<self.subView.frame.size.height/2) {
            self.subView.center = CGPointMake(touchPoint.x,self.subView.frame.size.height/2);
            rotateView.center = subView.center;
            NSLog(@"y");
            
            [cropFilter setCropRegion:CGRectMake(self.subView.frame.origin.x/self.scrollView.contentSize.width,self.subView.frame.origin.y/self.scrollView.contentSize.height,self.subView.frame.size.width/self.scrollView.contentSize.width, self.subView.frame.size.height/self.scrollView.contentSize.height)];
            
            [rotateView setFrame:CGRectMake(rotateView.frame.origin.x, rotateView.frame.origin.y-(self.subView.frame.size.height/2-rotateView.frame.size.height/2), sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2), sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2))];
            imageView.center = CGPointMake(rotateView.frame.size.width/2, rotateView.frame.size.height/2 + subView.center.y-rotateView.center.y);
        }else if (touchPoint.x>self.subView.frame.size.width/2  && touchPoint.y>self.subView.frame.size.height/2) {
            [cropFilter setCropRegion:CGRectMake(self.subView.frame.origin.x/self.scrollView.contentSize.width,self.subView.frame.origin.y/self.scrollView.contentSize.height,self.subView.frame.size.width/self.scrollView.contentSize.width, self.subView.frame.size.height/self.scrollView.contentSize.height)];
        }
        //        [cropFilter setCropRegion:CGRectMake(self.subView.frame.origin.x/self.scrollView.contentSize.width,self.subView.frame.origin.y/self.scrollView.contentSize.height,self.subView.frame.size.width/self.scrollView.contentSize.width, self.subView.frame.size.height/self.scrollView.contentSize.height)];
    }
    
    
    
    
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
    // Return the view that you want to zoom
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
    
    RectSize = CGRectMake(0, 0,200,200);
    
    self.subView = [[GPUImageView alloc] initWithFrame:RectSize];
    self.subView.center = CGPointMake(self.subView.frame.size.width/2,self.subView.frame.size.height/2);
    
    rotateView = [[UIView alloc] initWithFrame:CGRectMake(0,0,100,100)];
    rotateView.clipsToBounds =YES;
    [rotateView.layer setMasksToBounds:YES];
    [rotateView.layer setBorderWidth:0.6];
    [rotateView.layer setCornerRadius:rotateView.frame.size.width/2];
    
    imageView =[[UIImageView alloc] initWithFrame:self.subView.frame];
    imageView.center = CGPointMake(rotateView.frame.size.width/2, rotateView.frame.size.height/2);
    
    [rotateView addSubview:imageView];
    
    pixel = [[GPUImagePixellateFilter alloc]init];
    
    cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(self.subView.frame.origin.x/self.view.frame.size.width, self.subView.frame.origin.y/self.view.frame.size.height,self.subView.frame.size.width/self.view.frame.size.width, self.subView.frame.size.height/self.view.frame.size.height)];
    
    sliderRadius = [[UISlider alloc] initWithFrame:CGRectMake(20, 330, 280, 30)];
    sliderRadius.minimumValue=100;
    sliderRadius.maximumValue=320;
    sliderRadius.value = 210;
    [sliderRadius addTarget:self action:@selector(changeRadius) forControlEvents:UIControlEventValueChanged];
    
    originalImage = [[UIImage alloc] init];
    
}


- (IBAction)rectangle:(id)sender {
    [rotateView.layer setCornerRadius:0];
    [sliderRadius removeFromSuperview];

}
- (IBAction)circle:(id)sender {
    
    [subView setFrame:CGRectMake(subView.frame.origin.x, subView.frame.origin.y, sliderRadius.value, sliderRadius.value)];
    subView.center = rotateView.center;
    
    [imageView setFrame:subView.frame];
    
    
    [rotateView setFrame:CGRectMake(rotateView.frame.origin.x, rotateView.frame.origin.y, sqrtf(sliderRadius.value*sliderRadius.value/2), sqrtf(sliderRadius.value*sliderRadius.value/2))];
    [rotateView.layer setCornerRadius:rotateView.frame.size.height/2];
    
    rotateView.center = subView.center;
    
    imageView.center = CGPointMake(rotateView.frame.size.width/2, rotateView.frame.size.height/2);
    
    [self.view addSubview:sliderRadius];
    

}


-(void)changeRadius{
    
    [subView setFrame:CGRectMake(subView.frame.origin.x, subView.frame.origin.y, sliderRadius.value, sliderRadius.value)];
    subView.center = rotateView.center;
    
    [imageView setFrame:subView.frame];
    
    [rotateView setFrame:CGRectMake(rotateView.frame.origin.x, rotateView.frame.origin.y, sqrtf(sliderRadius.value*sliderRadius.value/2), sqrtf(sliderRadius.value*sliderRadius.value/2))];
    rotateView.center = subView.center;
    
    imageView.center = CGPointMake(rotateView.frame.size.width/2, rotateView.frame.size.height/2);
    
    [rotateView.layer setCornerRadius:rotateView.frame.size.width/2];
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
    
    //    self.selectedImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [scrollView addSubview:self.selectedImageView];
    
    scrollView.contentSize = originalImage.size;
    
    //    scrollView.maximumZoomScale = 5.0f;
    
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