#import <UIKit/UIKit.h>
#import <substrate.h>

// --- C++ CLASS DECLARATIONS (Για να μην βγάζει Error ο compiler) ---
class Entity;
class Player;
class LocalPlayer;
class Mob;

class LocalPlayer {
public:
    virtual void tick();
    void swing();
    int getHunger();
    void startUsingItem();
    void setMotionY(float y);
    float getFallDistance();
    float distanceTo(Entity*);
    void* getLevel();
    void attack(Entity*);
};

// --- DARKDEV SETTINGS ---
struct Settings {
    bool killaura = false;
    bool fly = false;
    bool speed = false;
    bool esp = false;
    bool tracers = false;
    bool autototem = false;
    bool criticals = false;
    bool autoeat = false;
} darkDev;

// --- GUI: DARKDEV MENU ---
@interface DarkDevGUI : UIView
@property (nonatomic, strong) UIScrollView *scroll;
@end

@implementation DarkDevGUI
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.05 alpha:0.95];
        self.layer.borderColor = [UIColor redColor].CGColor;
        self.layer.borderWidth = 2;
        self.layer.cornerRadius = 12;
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0,0,frame.size.width,35)];
        title.text = @"DARKDEV v1.0"; 
        title.textColor = [UIColor whiteColor];
        title.textAlignment = NSTextAlignmentCenter; 
        title.backgroundColor = [UIColor redColor];
        [self addSubview:title];

        self.scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 35, frame.size.width, frame.size.height-35)];
        [self addSubview:self.scroll];

        [self addTgl:@"KillAura" var:&darkDev.killaura y:10];
        [self addTgl:@"Fly" var:&darkDev.fly y:50];
        [self addTgl:@"Speed" var:&darkDev.speed y:90];
        [self addTgl:@"ESP" var:&darkDev.esp y:130];
        [self addTgl:@"Tracers" var:&darkDev.tracers y:170];
        [self addTgl:@"Auto Totem" var:&darkDev.autototem y:210];
        
        self.scroll.contentSize = CGSizeMake(frame.size.width, 300);
    }
    return self;
}

- (void)addTgl:(NSString *)n var:(bool *)v y:(int)y {
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(10,y,100,30)];
    l.text = n; l.textColor = [UIColor whiteColor]; [self.scroll addSubview:l];
    UISwitch *s = [[UISwitch alloc] initWithFrame:CGRectMake(self.frame.size.width-60,y,0,0)];
    s.onTintColor = [UIColor redColor];
    [s addTarget:self action:@selector(sw:) forControlEvents:UIControlEventValueChanged];
    objc_setAssociatedObject(s, "p", [NSValue valueWithPointer:v], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.scroll addSubview:s];
}

- (void)sw:(UISwitch *)s {
    bool *v = (bool *)[[objc_getAssociatedObject(s, "p") pointerValue] pointerValue];
    *v = s.on;
}
@end

static DarkDevGUI *menu;

// --- THE CHEATS (HOOKS) ---
// Χρησιμοποιούμε MS Hook για C++ μεθόδους
void (*old_LocalPlayer_tick)(LocalPlayer*);
void new_LocalPlayer_tick(LocalPlayer* self) {
    if (darkDev.killaura) { self->swing(); }
    if (darkDev.criticals && self->getFallDistance() == 0.0f) self->setMotionY(0.12f);
    old_LocalPlayer_tick(self);
}

float (*old_Mob_getSpeed)(Mob*);
float new_Mob_getSpeed(Mob* self) {
    float original = old_Mob_getSpeed(self);
    return darkDev.speed ? original * 2.8f : original;
}

// --- STARTUP ---
%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(10, 150, 50, 50);
        btn.backgroundColor = [UIColor redColor];
        btn.layer.cornerRadius = 25;
        [btn setTitle:@"DD" forState:UIControlStateNormal];
        [btn addTarget:nil action:@selector(tglM) forControlEvents:UIControlEventTouchUpInside];
        [win addSubview:btn];

        menu = [[DarkDevGUI alloc] initWithFrame:CGRectMake(50, 50, 200, 250)];
        menu.hidden = YES;
        [win addSubview:menu];
    });

    // Εδώ κάνουμε το "πάντρεμα" με το παιχνίδι
    // Σημείωση: Τα ονόματα των συμβόλων εξαρτώνται από το binary
    MSHookFunction(NULL, (void *)&new_LocalPlayer_tick, (void **)&old_LocalPlayer_tick);
}

void tglM() { if(menu) menu.hidden = !menu.hidden; }
