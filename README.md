# Sticky Header iOS

This project is an attempt to mimic the sticky header effect of Twitter's profile page.
While there are many examples on how to achieve the blur effect and the header scroll, it was difficult to find one single project that implements both the sticking header and the tabbed layout.

Here is a brief of the problem and the solution.

# Problem:
1. The header of the table view should expand and collapse based on the table view scroll.
2. Additionally, there is not just one table view, but an array of table views (Tabbed layout). Every table view's scroll should change the header height or Y position, depending on the need.

# Solution:
1. The view heirarchy of the main UIViewController is as follows.
      1. A simple UIView - Acting as the header.
      2. A UICollectionView - for switching between tabs.
      3. A UIPageViewController - Multiple UITableViews as child view controllers.
2. In viewDidScroll of the child view controller, take the content offset and delegate it to the main view controller.

# Features Available:
1. Expand/Collapse header view based on scroll.
2. Expand/Collapse header view based on pan gesture on the header view - Remember that the header here is a gimmick and not a default table view header.
3. Collection view with selection indicator.
4. Swipe through the pages of child view controller - Achieved using UIPageViewController.
