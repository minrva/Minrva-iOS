#import "RadioButtonGroup.h"

@implementation RadioButtonGroup
@synthesize radioButtons;
@synthesize cur_index;
@synthesize groupDelegate;

- (id)initWithFrame:(CGRect)frame andOptions:(NSArray *)options andColumns:(int)columns andFontSize:(float) font_size
{
    // Allocate button space
	NSMutableArray *arrTemp = [[NSMutableArray alloc]init];
	self.radioButtons = arrTemp;
 
    // Calculate # of Rows
    int rows = [options count]/columns;
    if([options count] % columns != 0)
        rows++;

    if (self = [super initWithFrame:frame])
    {
        
        // Calculate dimensions
        float frame_x = (((int) frame.size.width) % columns) / 2;
		float frame_y = (((int) frame.size.height) % rows) / 2;

		float cell_width = frame.size.width/columns;
		float cell_height = frame.size.height/rows;
          
        
        float img_width = 0.33 * cell_width;
        float img_height = 1 * cell_height;
        float img_dim = 0;
        if(img_width > img_height)
            img_dim = img_height;
        else
            img_dim = img_width;

        float lbl_width = cell_width - img_dim;
        
        // Make radio buttons
		int cell_count = 0;
		for(int row = 0; row < rows; row++) // for each row
        {
			for(int column = 0; column < columns; column++) // for each column
            {
                if(cell_count < [options count]) // if we need more cells
                {
                    // Calc. cell origin
                    int cell_x = frame_x + cell_width * column;
                    int cell_y = frame_y + cell_height * row;

                    // Create custom button
                    UIButton *btTemp = [UIButton buttonWithType:UIButtonTypeCustom];
                    btTemp.frame = CGRectMake( cell_x, cell_y, cell_width, cell_height );
                    
                    // Add image
                    float img_x = (img_width - img_dim)/2;
                    float img_y = (img_height - img_dim)/2;
                    UIImageView* imgView = [ [UIImageView alloc] initWithFrame:CGRectMake(img_x, img_y, img_dim, img_dim) ];
                    imgView.tag = 1;
                    [imgView setImage:[UIImage imageNamed:@"radio-off.png"]];
                    [btTemp addSubview:imgView];
                    
                    // Add text
                    float lbl_x = imgView.frame.origin.x + imgView.frame.size.width;
                    UILabel* lblView = [[UILabel alloc] initWithFrame:CGRectMake(lbl_x, 0, lbl_width, 1 )];
                    lblView.tag = 2;
                    lblView.backgroundColor =[UIColor clearColor];
                    lblView.font =[UIFont systemFontOfSize:font_size];
                    lblView.text = [options objectAtIndex:cell_count];
                    [lblView sizeToFit];
                    CGRect tmpFrame = lblView.frame;
                    tmpFrame.origin.y = (cell_height - tmpFrame.size.height)/2;
                    lblView.frame = tmpFrame;
                    [btTemp addSubview:lblView];
                    
                    // Add listener
                    [btTemp addTarget:self action:@selector(radioButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
				
                    // Add objects
                    [self.radioButtons addObject:btTemp];
                    [self addSubview:btTemp];
                
                    // Increment cell count
                    cell_count++;
                }
			}
		}
        
        // Set first radio button as default
        UIButton* curBtn = [self.radioButtons objectAtIndex:0];
        UIImageView* imgView = (UIImageView*) [curBtn viewWithTag:1];
        [ imgView setImage:[UIImage imageNamed:@"radio-on.png"] ];
        cur_index = 0;
    }
    
    return self;
}

-(void) radioButtonClicked:(UIButton *) sender
{
    // Get new index
    int new_index = cur_index;
    for(int i = 0; i < [self.radioButtons count]; i++)
        if([self.radioButtons objectAtIndex:i] == sender)
            new_index = i;
    
    // Update buttons
    if( new_index != cur_index)
        [self switchCurrentButton: cur_index withButton: new_index];
}

-(void) switchCurrentButton:(int) old_index withButton: (int) new_index
{
    // Shut off currently selected
    UIButton* btnOld = [self.radioButtons objectAtIndex:old_index];
    UIImageView* imgOld = (UIImageView*) [btnOld viewWithTag:1];
    [ imgOld setImage:[UIImage imageNamed:@"radio-off.png"] ];
    
    // Turn on newly selected
    UIButton* btnNew = [self.radioButtons objectAtIndex:new_index];
    UIImageView* imgNew = (UIImageView*) [btnNew viewWithTag:1];
    [ imgNew setImage:[UIImage imageNamed:@"radio-on.png"] ];
    
    // Update current index
    cur_index = new_index;
    
    // Notify changes
    [groupDelegate RadioButtonGroup:self selectedIndex:cur_index];
}

-(void) setSelected:(int) new_index
{
    if( new_index != cur_index)
        [self switchCurrentButton: cur_index withButton: new_index];
}

-(void) disableButtons
{
    for(int i = 0; i < [self.radioButtons count]; i++)
        ((UIButton*)[self.radioButtons objectAtIndex:i]).enabled = FALSE;
}

-(void) enableButtons
{
    for(int i = 0; i < [self.radioButtons count]; i++)
        ((UIButton*)[self.radioButtons objectAtIndex:i]).enabled = TRUE;
}


@end
