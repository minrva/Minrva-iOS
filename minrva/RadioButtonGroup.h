#import <UIKit/UIKit.h>

@protocol RadioButtonGroupDelegate;

@interface RadioButtonGroup : UIView {
	NSMutableArray *radioButtons;
    int cur_index;
    __unsafe_unretained id<RadioButtonGroupDelegate> groupDelegate;
}

@property (nonatomic,retain) NSMutableArray *radioButtons;
@property (nonatomic) int cur_index;
@property (nonatomic, unsafe_unretained) id groupDelegate;

- (id)initWithFrame:(CGRect)frame andOptions:(NSArray *)options andColumns:(int)columns andFontSize:(float) font_size;
-(void) radioButtonClicked:(UIButton *) sender;
-(void) setSelected:(int) index;
-(void) switchCurrentButton:(int) old_index withButton: (int) new_index;
-(void) disableButtons;
-(void) enableButtons;

@end

@protocol RadioButtonGroupDelegate <NSObject>
-(void) RadioButtonGroup:(RadioButtonGroup*)RadioButtonGroup selectedIndex:(int) index;
@end

