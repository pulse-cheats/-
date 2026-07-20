#import <UIKit/UIKit.h>
#import <substrate.h>
#import <vector>
#import <string>
#import <map>

// --- DARKDEV MATH & TYPES ---
struct Vec3 { float x, y, z; };
struct Color { float r, g, b, a; };

// --- CLIENT STATE ENGINE ---
// Εδώ ορίζουμε τις ρυθμίσεις για κάθε module ξεχωριστά
namespace DarkDev {
    // Combat
    bool killaura = false; float killauraRange = 6.0f; int killauraAPS = 10;
    bool velocity = false; float velocityHorizontal = 0.0f; float velocityVertical = 0.0f;
    bool triggerbot = false;
    bool aimassist = false;
    bool autototem = true;
    bool criticals = false;

    // Movement
    bool fly = false; int flyMode = 0; float flySpeed = 1.0f;
    bool speed = false; float speedValue = 1.0f;
    bool bunnyhop = false;
    bool spider = false;
    bool step = false;
    
    // Visuals
    bool esp = false; bool espBoxes = true; bool espTracers = true;
    bool spawners = false; bool chests = false; bool pistons = false;
    bool fullbright = false;
    
    // Player
    bool autoeat = false;
    bool fastplace = false;
    bool instabreak = false;
    bool scaffold = false;
}

// --- GUI COMPONENTS (CRYPTO STYLE) ---
@interface DarkDevGUI : UIView
@property (nonatomic, strong) UIView *sideBar;
@property (nonatomic, strong) UIScrollView *contentArea;
@property (nonatomic, assign) int currentTab; // 0:Combat, 1:Move, 2:Visual, 3:Player
@end

@implementation DarkDevGUI

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.05 alpha:0.95];
        self.layer.cornerRadius = 10;
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor redColor].CGColor;
        self.clipsToBounds = YES;
        self.currentTab = 0;

        // Sidebar
        self.sideBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, frame.size.height)];
        self.sideBar.backgroundColor = [UIColor colorWithWhite:0.02 alpha:1];
        [self addSubview:self.sideBar];

        [self addTabButton:@"COMBAT" index:0 y:20];
        [self addTabButton:@"MOVE" index:1 y:70];
        [self addTabButton:@"VISUAL" index:2 y:120];
        [self addTabButton:@"PLAYER" index:3 y:170];

        // Content
        self.contentArea = [[UIScrollView alloc] initWithFrame:CGRectMake(85, 10, frame.size.width - 95, frame.size.height - 20)];
        [self addSubview:self.contentArea];
        
        [self refreshTab];
    }
    return self;
}

- (void)addTabButton:(NSString *)title index:(int)idx y:(CGFloat)y {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(5, y, 70, 40);
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    btn.tag = idx;
    [btn addTarget:self action:@selector(tabSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [self.sideBar addSubview:btn];
}

- (void)tabSwitch:(UIButton *)sender {
    self.currentTab = (int)sender.tag;
    [self refreshTab];
}

- (void)refreshTab {
    for (UIView *v in self.contentArea.subviews) [v removeFromSuperview];
    
    CGFloat y = 10;
    if (self.currentTab == 0) { // Combat Tab
        [self addToggle:@"KillAura" var:&DarkDev::killaura y:&y];
        [self addSlider:@"Range" var:&DarkDev::killauraRange min:3 max:10 y:&y];
        [self addToggle:@"Velocity (Anti-KB)" var:&DarkDev::velocity y:&y];
        [self addToggle:@"Auto Totem" var:&DarkDev::autototem y:&y];
        [self addToggle:@"Criticals" var:&DarkDev::criticals y:&y];
    } else if (self.currentTab == 1) { // Movement Tab
        [self addToggle:@"Flight" var:&DarkDev::fly y:&y];
        [self addToggle:@"Speed / Bhop" var:&DarkDev::speed y:&y];
        [self addToggle:@"Spider" var:&DarkDev::spider y:&y];
    } else if (self.currentTab == 2) { // Visual Tab
        [self addToggle:@"Player ESP" var:&DarkDev::esp y:&y];
        [self addToggle:@"Spawner Tracers" var:&DarkDev::spawners y:&y];
        [self addToggle:@"Chest Tracers" var:&DarkDev::chests y:&y];
        [self addToggle:@"FullBright" var:&DarkDev::fullbright y:&y];
    }
    self.contentArea.contentSize = CGSizeMake(self.contentArea.frame.size.width, y + 20);
}

- (void)addToggle:(NSString *)name var:(bool *)v y:(CGFloat *)yPos {
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, *yPos, 120, 30)];
    l.text = name; l.textColor = [UIColor whiteColor]; l.font = [UIFont systemFontOfSize:14];
    [self.contentArea addSubview:l];
    
    UISwitch *s = [[UISwitch alloc] initWithFrame:CGRectMake(self.contentArea.frame.size.width - 55, *yPos, 40, 30)];
    s.on = *v; s.onTintColor = [UIColor redColor]; s.transform = CGAffineTransformMakeScale(0.8, 0.8);
    [s addTarget:self action:@selector(onToggle:) forControlEvents:UIControlEventValueChanged];
    objc_setAssociatedObject(s, "ptr", [NSValue valueWithPointer:v], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.contentArea addSubview:s];
    *yPos += 40;
}

- (void)addSlider:(NSString *)name var:(float *)v min:(float)mi max:(float)ma y:(CGFloat *)yPos {
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, *yPos, 150, 20)];
    l.text = [NSString stringWithFormat:@"%@: %.1f", name, *v];
    l.textColor = [UIColor lightGrayColor]; l.font = [UIFont systemFontOfSize:10];
    [self.contentArea addSubview:l];
    
    UISlider *sl = [[UISlider alloc] initWithFrame:CGRectMake(0, *yPos + 15, self.contentArea.frame.size.width - 10, 20)];
    sl.minimumValue = mi; sl.maximumValue = ma; sl.value = *v; sl.tintColor = [UIColor redColor];
    [sl addTarget:self action:@selector(onSlide:) forControlEvents:UIControlEventValueChanged];
    objc_setAssociatedObject(sl, "ptr", [NSValue valueWithPointer:v], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(sl, "lbl", l, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(sl, "name", name, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.contentArea addSubview:sl];
    *yPos += 45;
}

- (void)onToggle:(UISwitch *)s { bool *v = (bool *)[[objc_getAssociatedObject(s, "ptr") pointerValue] pointerValue]; *v = s.on; }
- (void)onSlide:(UISlider *)s { 
    float *v = (float *)[[objc_getAssociatedObject(s, "ptr") pointerValue] pointerValue]; *v = s.value; 
    UILabel *l = objc_getAssociatedObject(s, "lbl"); NSString *n = objc_getAssociatedObject(s, "name");
    l.text = [NSString stringWithFormat:@"%@: %.1f", n, *v];
}
@end

static DarkDevGUI *mainGUI;
static UIButton *floatingBtn;

// --- HOOKS ENGINE (THE BRAIN) ---

%hook LocalPlayer
- (void)tick {
    %orig;
    
    // 1. KillAura Logic
    if (DarkDev::killaura) {
        void* level = [self getLevel];
        auto entities = [level getEntities];
        for (auto& entity : entities) {
            if (entity != self && [self distanceTo:entity] < DarkDev::killauraRange) {
                if (DarkDev::criticals && [self getFallDistance] == 0.0f) [self setMotionY:0.12f];
                [self attack:entity];
                [self swing];
            }
        }
    }
    
    // 12. AutoEat
    if (DarkDev::autoeat && [self getHunger] < 16) [self startUsingItem];
}
%end

%hook Player
- (void)normalTick {
    %orig;
    // 2. Fly Logic
    if (DarkDev::fly) {
        uintptr_t abilities = *(uintptr_t*)((uintptr_t)self + 0x930);
        *(bool*)(abilities + 0x10) = true; // mayFly
        *(bool*)(abilities + 0x11) = true; // isFlying
    }
}
%end

%hook Mob
- (float)getSpeed {
    return DarkDev::speed ? %orig * 2.5f : %orig;
}
%end

// --- INITIALIZATION ---
%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        
        floatingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        floatingBtn.frame = CGRectMake(20, 80, 50, 50);
        floatingBtn.backgroundColor = [UIColor colorWithRed:0.6 green:0 blue:0 alpha:0.8];
        floatingBtn.layer.cornerRadius = 25;
        floatingBtn.layer.borderWidth = 2;
        floatingBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        [floatingBtn setTitle:@"DD" forState:UIControlStateNormal];
        [floatingBtn addTarget:nil action:@selector(toggleDarkDev) forControlEvents:UIControlEventTouchUpInside];
        [window addSubview:floatingBtn];
        
        mainGUI = [[DarkDevGUI alloc] initWithFrame:CGRectMake(window.frame.size.width/2-160, window.frame.size.height/2-100, 320, 200)];
        mainGUI.hidden = YES;
        [window addSubview:mainGUI];
    });
}

void toggleDarkDev() {
    mainGUI.hidden = !mainGUI.hidden;
    if (!mainGUI.hidden) [mainGUI refreshTab];
}
