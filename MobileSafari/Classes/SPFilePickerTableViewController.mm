// SPFilePickerTableViewController.mm
// (c) 2019 opa334

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

#import "SPFilePickerTableViewController.h"

#import "../Shared.h"
#import "SPFilePickerNavigationController.h"
#import "SPLocalizationManager.h"
#import "SPFileManager.h"
#import "SPFile.h"

@implementation SPFilePickerTableViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	//Activate checkmarks on the left while editing
	self.tableView.allowsMultipleSelectionDuringEditing = YES;
}

- (void)dismiss
{
	//Dismiss file picker
	[((SPFilePickerNavigationController*)self.navigationController).filePickerDelegate filePicker:(SPFilePickerNavigationController*)self.navigationController didSelectFiles:nil];
}

- (void)didSelectFile:(SPFile*)file atIndexPath:(NSIndexPath*)indexPath
{
	if(file.isRegularFile)
	{
		//tapped entry is file -> call delegate to upload file
		[((SPFilePickerNavigationController*)self.navigationController).filePickerDelegate filePicker:(SPFilePickerNavigationController*)self.navigationController didSelectFiles:@[file.fileURL]];
	}

	[super didSelectFile:file atIndexPath:indexPath];
}

- (void)didLongPressFile:(SPFile*)file atIndexPath:(NSIndexPath*)indexPath
{
	if(!self.tableView.editing && file.isRegularFile)
	{
		//Toggle editing mode
		[self toggleEditing];

		//Select file
		[self.tableView selectRowAtIndexPath:indexPath animated:YES
		 scrollPosition:UITableViewScrollPositionNone];

		//Update top right button status
		[self updateTopRightButtonAvailability];
	}
}

- (void)toggleEditing
{
	//Toggle editing
	[self.tableView setEditing:!self.tableView.editing animated:YES];

	if(self.tableView.editing)
	{
		//Entered editing mode -> change top buttons
		UIBarButtonItem* cancelItem = [[UIBarButtonItem alloc]
					       initWithTitle:[localizationManager
							      localizedSPStringForKey:@"CANCEL"]
					       style:UIBarButtonItemStylePlain
					       target:self action:@selector(toggleEditing)];

		UIBarButtonItem* uploadItem = [[UIBarButtonItem alloc]
					       initWithTitle:[localizationManager
							      localizedSPStringForKey:@"UPLOAD"]
					       style:UIBarButtonItemStylePlain
					       target:self action:@selector(uploadSelectedItems)];

		self.navigationItem.leftBarButtonItem = cancelItem;
		self.navigationItem.rightBarButtonItem = uploadItem;

		self.navigationItem.rightBarButtonItem.enabled = NO;
	}
	else
	{
		//Exited editing mode -> revert top buttons
		self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
		[self setUpRightBarButtonItems];
		self.navigationItem.rightBarButtonItem.enabled = YES;
	}
}

- (void)uploadSelectedItems
{
	//Get selected items
	NSArray* selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
	NSMutableArray* selectedURLs = [NSMutableArray new];

	//Store fileURLs into array
	for(NSIndexPath* indexPath in selectedIndexPaths)
	{
		NSURL* fileURL = self.filesAtCurrentURL[indexPath.row].fileURL;
		[selectedURLs addObject:fileURL];
	}

	//Call delegate to upload files
	[((SPFilePickerNavigationController*)self.navigationController).filePickerDelegate filePicker:(SPFilePickerNavigationController*)self.navigationController
	 didSelectFiles:selectedURLs];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];

	[self updateTopRightButtonAvailability];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self updateTopRightButtonAvailability];
}

- (void)updateTopRightButtonAvailability
{
	if(self.tableView.editing)
	{
		NSArray *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
		if([selectedIndexPaths count] <= 0)
		{
			//Count of selected files is 0 -> disable button
			self.navigationItem.rightBarButtonItem.enabled = NO;
		}
		else
		{
			//Count of selected files is 1 or more -> enable button
			self.navigationItem.rightBarButtonItem.enabled = YES;
		}
	}
	else
	{
		//TableView is not in editing mode -> enable button
		self.navigationItem.rightBarButtonItem.enabled = YES;
	}
}

@end
