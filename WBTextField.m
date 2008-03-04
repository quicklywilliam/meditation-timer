#import "WBTextField.h"

@implementation WBTextField
- (void)mouseDown:(NSEvent *)theEvent
{
	[self sendAction:[[self cell] action] to:[[self cell] target]];
}
@end
