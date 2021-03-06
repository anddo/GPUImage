#import "PhotoViewController.h"

@interface PhotoViewController ()

@end

@implementation PhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView 
{
	CGRect mainScreenFrame = [[UIScreen mainScreen] bounds];
	    
    // Yes, I know I'm a caveman for doing all this by hand
	GPUImageView *primaryView = [[GPUImageView alloc] initWithFrame:mainScreenFrame];
	primaryView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    filterSettingsSlider = [[UISlider alloc] initWithFrame:CGRectMake(25.0, mainScreenFrame.size.height - 50.0, mainScreenFrame.size.width - 50.0, 40.0)];
    [filterSettingsSlider addTarget:self action:@selector(updateSliderValue:) forControlEvents:UIControlEventValueChanged];
	filterSettingsSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    filterSettingsSlider.minimumValue = 0.0;
    filterSettingsSlider.maximumValue = 0.3;
    filterSettingsSlider.value = 0.05;
    
    [primaryView addSubview:filterSettingsSlider];
    
    photoCaptureButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    photoCaptureButton.frame = CGRectMake(round(mainScreenFrame.size.width / 2.0 - 150.0 / 2.0), mainScreenFrame.size.height - 90.0, 150.0, 40.0);
    [photoCaptureButton setTitle:@"Capture Photo" forState:UIControlStateNormal];
	photoCaptureButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [photoCaptureButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    
    [primaryView addSubview:photoCaptureButton];
    
	self.view = primaryView;	
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    stillCamera = [[GPUImageStillCamera alloc] init];
    filter = [[GPUImagePixellateFilter alloc] init];
//    filter = [[GPUImageSketchFilter alloc] init];
    GPUImageRotationFilter *rotationFilter = [[GPUImageRotationFilter alloc] initWithRotation:kGPUImageRotateRight];
    
    [stillCamera addTarget:rotationFilter];
    [rotationFilter addTarget:filter];
    GPUImageView *filterView = (GPUImageView *)self.view;
    [filter addTarget:filterView];
    
    [stillCamera startCameraCapture];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)updateSliderValue:(id)sender
{
    [(GPUImagePixellateFilter *)filter setFractionalWidthOfAPixel:[(UISlider *)sender value]];
    //    [(GPUImageSketchFilter *)filter setIntensity:1.0];
}

- (IBAction)takePhoto:(id)sender;
{
    NSLog(@"Took photo");
    
    [filter removeTarget:(GPUImageView *)self.view];
    
    [stillCamera capturePhotoProcessedUpToFilter:filter withCompletionHandler:^(UIImage *processedImage, NSError *error){
        NSData *dataForPNGFile = UIImagePNGRepresentation(processedImage);
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSError *error2 = nil;
        if (![dataForPNGFile writeToFile:[documentsDirectory stringByAppendingPathComponent:@"FilteredPhoto.png"] options:NSAtomicWrite error:&error2])
        {
            return;
        }
        
        
        [filter addTarget:(GPUImageView *)self.view];
    }];
}

@end
