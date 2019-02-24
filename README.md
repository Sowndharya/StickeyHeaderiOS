# StickeyHeaderiOS
A custom header view implementation in iOS that expands and collapses along with table view scroll

Problem:
The header of the table view should expand and collapse along with table view scroll.

Solution:
A view controller that holds the table view container view controller as a child.
Manipulate the scroll view delegates of the inner view controller.
Compute the scroll offset.
Pass it to the outer view controller to expand/collapse the top header view.
