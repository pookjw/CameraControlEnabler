#import "CCEControlViewController.h"
#import <objc/message.h>
#import <objc/runtime.h>
#import <mach/mach_time.h>

__attribute__((objc_direct_members))
@interface CCEControlViewController ()
@property (retain, nonatomic, readonly) UIStackView *verticalStackView;
@property (retain, nonatomic, readonly) UIStackView *horizontalStackView;
@property (retain, nonatomic, readonly) UIButton *leftButton;
@property (retain, nonatomic, readonly) UIButton *rightButton;
@property (retain, nonatomic, readonly) UIButton *pressButton;
@property (nonatomic, readonly) id captureButtonSuppressionManager;
@end

@implementation CCEControlViewController
@synthesize verticalStackView = _verticalStackView;
@synthesize horizontalStackView = _horizontalStackView;
@synthesize leftButton = _leftButton;
@synthesize rightButton = _rightButton;
@synthesize pressButton = _pressButton;

- (void)dealloc {
    [_verticalStackView release];
    [_horizontalStackView release];
    [_leftButton release];
    [_rightButton release];
    [_pressButton release];
    [super dealloc];
}

- (void)loadView {
    UIView *view = [objc_lookUpClass("SBFTouchPassThroughView") new];
    self.view = view;
    [view release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *view = self.view;
    
    UIStackView *verticalStackView = self.verticalStackView;
    verticalStackView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [view addSubview:verticalStackView];
    [NSLayoutConstraint activateConstraints:@[
        [verticalStackView.centerXAnchor constraintEqualToAnchor:view.safeAreaLayoutGuide.centerXAnchor],
        [verticalStackView.centerYAnchor constraintEqualToAnchor:view.safeAreaLayoutGuide.centerYAnchor]
    ]];
}

- (UIStackView *)verticalStackView {
    if (auto verticalStackView = _verticalStackView) return verticalStackView;
    
    UIStackView *verticalStackView = [[UIStackView alloc] initWithArrangedSubviews:@[
        self.horizontalStackView,
        // self.pressButton
    ]];
    
    verticalStackView.axis = UILayoutConstraintAxisVertical;
    verticalStackView.distribution = UIStackViewDistributionFillProportionally;
    verticalStackView.alignment = UIStackViewAlignmentFill;
    verticalStackView.spacing = 8.;
    
    _verticalStackView = [verticalStackView retain];
    return [verticalStackView autorelease];
}

- (UIStackView *)horizontalStackView {
    if (auto horizontalStackView = _horizontalStackView) return horizontalStackView;
    
    UIStackView *horizontalStackView = [[UIStackView alloc] initWithArrangedSubviews:@[
        self.leftButton,
        self.rightButton
    ]];
    
    horizontalStackView.axis = UILayoutConstraintAxisHorizontal;
    horizontalStackView.distribution = UIStackViewDistributionFillProportionally;
    horizontalStackView.alignment = UIStackViewAlignmentFill;
    horizontalStackView.spacing = 8.;
    
    _horizontalStackView = [horizontalStackView retain];
    return [horizontalStackView autorelease];
}

- (UIButton *)leftButton {
    if (auto leftButton = _leftButton) return leftButton;
    
    UIButtonConfiguration *configuration = [UIButtonConfiguration tintedButtonConfiguration];
    configuration.image = [UIImage systemImageNamed:@"minus"];
    
    UIButton *leftButton = [UIButton buttonWithConfiguration:configuration primaryAction:nil];
    [leftButton addTarget:self action:@selector(didTriggerLeftButton:) forControlEvents:UIControlEventPrimaryActionTriggered];
    
    _leftButton = [leftButton retain];
    return leftButton;
}

- (UIButton *)rightButton {
    if (auto rightButton = _rightButton) return rightButton;
    
    UIButtonConfiguration *configuration = [UIButtonConfiguration tintedButtonConfiguration];
    configuration.image = [UIImage systemImageNamed:@"plus"];
    
    UIButton *rightButton = [UIButton buttonWithConfiguration:configuration primaryAction:nil];
    [rightButton addTarget:self action:@selector(didTriggerRightButton:) forControlEvents:UIControlEventPrimaryActionTriggered];
    
    _rightButton = [rightButton retain];
    return rightButton;
}

- (UIButton *)pressButton {
    if (auto pressButton = _pressButton) return pressButton;
    
    UIButtonConfiguration *configuration = [UIButtonConfiguration tintedButtonConfiguration];
    configuration.image = [UIImage systemImageNamed:@"circle.fill"];
    
    UIButton *pressButton = [UIButton buttonWithConfiguration:configuration primaryAction:nil];
    [pressButton addTarget:self action:@selector(didTriggerPressButton:) forControlEvents:UIControlEventPrimaryActionTriggered];
    
    _pressButton = [pressButton retain];
    return pressButton;
}

- (id)captureButtonSuppressionManager {
    id _captureButtonSuppressionManager;
    assert(object_getInstanceVariable([UIApplication sharedApplication], "_captureButtonSuppressionManager", reinterpret_cast<void **>(&_captureButtonSuppressionManager)) != nullptr);
    return _captureButtonSuppressionManager;
}

- (void)didTriggerLeftButton:(UIButton *)sender {
    __kindof UIApplication *application = [UIApplication sharedApplication];
    id captureHardwareButton = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(application, sel_registerName("captureHardwareButton"));
    reinterpret_cast<void (*)(id, SEL, id)>(objc_msgSend)(captureHardwareButton, sel_registerName("performActionsForButtonDown:"), nil);
    // uint64_t timestamp = mach_absolute_time();
    // reinterpret_cast<void (*)(id, SEL, uint64_t)>(objc_msgSend)(captureHardwareButton, sel_registerName("_handleButtonDownAtTimestamp:"), timestamp);
}

- (void)didTriggerRightButton:(UIButton *)sender {
    __kindof UIApplication *application = [UIApplication sharedApplication];
    id captureHardwareButton = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(application, sel_registerName("captureHardwareButton"));
    reinterpret_cast<void (*)(id, SEL, id)>(objc_msgSend)(captureHardwareButton, sel_registerName("performActionsForButtonUp:"), nil);
}

- (void)didTriggerPressButton:(UIButton *)sender {
    __kindof UIApplication *application = [UIApplication sharedApplication];
    id captureHardwareButton = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(application, sel_registerName("captureHardwareButton"));
    reinterpret_cast<void (*)(id, SEL, id)>(objc_msgSend)(captureHardwareButton, sel_registerName("performActionsFoperformActionsForButtonLongPressrButtonDown:"), nil);
}

@end