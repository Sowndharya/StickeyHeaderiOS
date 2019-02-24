//
//  TabContainerViewController.swift
//  ProfilePageSampleProject
//
//  Created by Sowndharya M on 24/02/19.
//  Copyright © 2019 Sowndharya M. All rights reserved.
//

import UIKit

extension TabContainerViewController {
    
    struct Page {
        
        var name = ""
        var vc = TabContentViewController()
        
        init(with _name: String, _vc: TabContentViewController) {
            
            name = _name
            vc = _vc
        }
    }
    
    struct PageCollection {
        
        var pages = [Page]()
        var selectedPageIndex = 0 //The first page is selected by default in the beginning
    }
}

class TabContainerViewController: UIViewController {
    
    //MARK:- Change this value for number of tabs
    
    let subTabsCount = 4
    
    //MARK:- Outlets
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tabBarCollectionView: UICollectionView!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    var tabsPageViewController = UIPageViewController()
    
    var selectionBar = UIView()
    
    //MARK:- View Model
    
    var pageCollection = PageCollection()
    
    //MARK: View Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupCollectionView()
        setupPagingViewController()
        populateBottomView()
        addPanGestureToTopViewAndCollectionVi()
    }
    
    //MARK: View Setup
    
    func setupCollectionView() {
        
        tabBarCollectionView.backgroundColor = UIColor(red:0.93, green:0.94, blue:0.95, alpha:1)
        
        let layout = tabBarCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.scrollDirection = .horizontal
        layout?.estimatedItemSize = CGSize(width: 100, height: 50)
        
        tabBarCollectionView.register(UINib(nibName: TabBarCollectionViewCellID, bundle: nil),
                                      forCellWithReuseIdentifier: TabBarCollectionViewCellID)
        tabBarCollectionView.isScrollEnabled = true
        tabBarCollectionView.dataSource = self
        tabBarCollectionView.delegate = self
        
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 10, height: 10))
        label.text = "TAB \(1)"
        label.sizeToFit()
        var width = label.intrinsicContentSize.width
        width = width + 40
        
        selectionBar.frame = CGRect(x: 0 , y: 55, width: width, height: 5)
        selectionBar.backgroundColor = UIColor(red:0.65, green:0.58, blue:0.94, alpha:1)
        tabBarCollectionView.addSubview(selectionBar)
    }
    
    func setupPagingViewController() {
        
        tabsPageViewController = UIPageViewController(transitionStyle: .scroll,
                                                      navigationOrientation: .horizontal,
                                                      options: nil)
        tabsPageViewController.dataSource = self
        tabsPageViewController.delegate = self
    }
    
    func populateBottomView() {
        
        for subTabCount in 0..<subTabsCount {

            let tabContentVC = TabContentViewController()
            tabContentVC.innerTableViewScrollDelegate = self
            tabContentVC.numberOfCells = (subTabCount + 1) * 2

            let displayName = "TAB \(subTabCount + 1)"
            let page = Page(with: displayName, _vc: tabContentVC)
            pageCollection.pages.append(page)
        }
        
        let initialPage = 0
        
        tabsPageViewController.setViewControllers([pageCollection.pages[initialPage].vc],
                                                  direction: .forward,
                                                  animated: true,
                                                  completion: nil)
        
        
        addChild(tabsPageViewController)
        tabsPageViewController.willMove(toParent: self)
        bottomView.addSubview(tabsPageViewController.view)
        
        pinPagingViewControllerToBottomView()
    }
    
    func pinPagingViewControllerToBottomView() {
        
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        tabsPageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        tabsPageViewController.view.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor).isActive = true
        tabsPageViewController.view.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor).isActive = true
        tabsPageViewController.view.topAnchor.constraint(equalTo: bottomView.topAnchor).isActive = true
        tabsPageViewController.view.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor).isActive = true
    }
    
    func addPanGestureToTopViewAndCollectionVi() {
        
        let topViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(topViewMoved))
        
        topView.isUserInteractionEnabled = true
        topView.addGestureRecognizer(topViewPanGesture)
        
        let collViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(topViewMoved))
        
        tabBarCollectionView.isUserInteractionEnabled = true
        tabBarCollectionView.addGestureRecognizer(collViewPanGesture)
    }
    
    var dragInitialY: CGFloat = 0
    var dragPreviousY: CGFloat = 0
    var dragDirection: DragDirection = .Up
    
    @objc func topViewMoved(_ gesture: UIPanGestureRecognizer) {
        
        var dragYDiff : CGFloat
        
        if gesture.state == .began {
            
            dragInitialY = gesture.location(in: self.view).y
            dragPreviousY = dragInitialY
            return
            
        } else if gesture.state == .changed {
            
            let dragCurrentY = gesture.location(in: self.view).y
            
            dragYDiff = dragPreviousY - dragCurrentY
            
            dragPreviousY = dragCurrentY
            
            dragDirection = dragYDiff < 0 ? .Down : .Up
            
            innerTableViewScroll(with: dragYDiff)
            
            return
            
        } else if(gesture.state == .ended) {
            
            innerTableViewScrollEnded(withScrollDirection: dragDirection)
        }
    }
    
    //MARK:- View Action Methods
    
    func setBottomPagingView(toPageWithAtIndex index: Int, andNavigationDirection navigationDirection: UIPageViewController.NavigationDirection) {
        
        tabsPageViewController.setViewControllers([pageCollection.pages[index].vc],
                                                  direction: navigationDirection,
                                                  animated: true,
                                                  completion: nil)
    }
    
    func scrollSectionBar(toIndexPath indexPath: IndexPath, shouldAnimate: Bool = true) {
        
        UIView.animate(withDuration: 0.3) {
            
            if let cell = self.tabBarCollectionView.cellForItem(at: indexPath) {
                
                self.selectionBar.frame.size.width = cell.frame.width
                self.selectionBar.frame.origin.x = cell.frame.origin.x
            }
        }
    }
}

extension TabContainerViewController: UICollectionViewDataSource {
    
    //MARK:- Collection View Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return pageCollection.pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let tabCell = collectionView.dequeueReusableCell(withReuseIdentifier: TabBarCollectionViewCellID, for: indexPath) as? TabBarCollectionViewCell {
            
            tabCell.tabNameLabel.text = pageCollection.pages[indexPath.row].name
            return tabCell
        }
        
        return UICollectionViewCell()
    }
}

extension TabContainerViewController: UICollectionViewDelegateFlowLayout {
    
    //MARK:- Collection View Delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.item == pageCollection.selectedPageIndex {
            
            return
        }
        
        var direction: UIPageViewController.NavigationDirection
        
        if indexPath.item > pageCollection.selectedPageIndex {
            
            direction = .forward
            
        } else {
            
            direction = .reverse
        }
        
        pageCollection.selectedPageIndex = indexPath.item
        
        tabBarCollectionView.scrollToItem(at: indexPath,
                                          at: .centeredHorizontally,
                                          animated: true)
        
        scrollSectionBar(toIndexPath: indexPath)
        
        setBottomPagingView(toPageWithAtIndex: indexPath.item, andNavigationDirection: direction)
    }
}

extension TabContainerViewController: UIPageViewControllerDataSource {
    
    //MARK:- Delegate Method to give the next and previous View Controllers to the Page View Controller
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let currentViewControllerIndex = pageCollection.pages.firstIndex(where: { $0.vc == viewController }) {
            
            if (1..<pageCollection.pages.count).contains(currentViewControllerIndex) {
                
                // go to previous page in array
                
                return pageCollection.pages[currentViewControllerIndex - 1].vc
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if let currentViewControllerIndex = pageCollection.pages.firstIndex(where: { $0.vc == viewController }) {
            
            if (0..<(pageCollection.pages.count - 1)).contains(currentViewControllerIndex) {
                
                // go to next page in array
                
                return pageCollection.pages[currentViewControllerIndex + 1].vc
            }
        }
        return nil
    }
}

extension TabContainerViewController: UIPageViewControllerDelegate {
    
    //MARK:- Delegate Method to tell Inner View Controller movement inside Page View Controller
    //Capture it and change the selection bar position in collection View
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard completed else { return }
        
        guard let currentVC = pageViewController.viewControllers?.first else { return }
        
        guard let currentVCIndex = pageCollection.pages.firstIndex(where: { $0.vc == currentVC }) else { return }
        
        let indexPathAtCollectionView = IndexPath(item: currentVCIndex, section: 0)
        
        scrollSectionBar(toIndexPath: indexPathAtCollectionView)
        tabBarCollectionView.scrollToItem(at: indexPathAtCollectionView,
                                          at: .centeredHorizontally,
                                          animated: true)
    }
}

extension TabContainerViewController: InnerTableViewScrollDelegate {
    
    func getCurrentHeightConstraint() -> CGFloat {
        
        return topViewHeightConstraint.constant
    }
    
    func innerTableViewScroll(with height: CGFloat) {
        
        topViewHeightConstraint.constant -= height
        
        if(topViewHeightConstraint.constant < topViewFinalHeight) {
            self.topViewHeightConstraint.constant = topViewFinalHeight
        }
        
        if(topViewHeightConstraint.constant > topViewInitialHeight) {
            self.topViewHeightConstraint.constant = topViewInitialHeight
        }
    }
    
    func innerTableViewScrollEnded(withScrollDirection scrollDirection: DragDirection) {
        
        let topViewHeight = topViewHeightConstraint.constant
        
        if topViewHeight >= topViewInitialHeight || topViewHeight <= topViewFinalHeight {
            
            return
        }
        
        if topViewHeight <= topViewFinalHeight + 20 {
            
            scrollToFinalView()
            
        } else if topViewHeight <= topViewInitialHeight - 20 {
            
            switch scrollDirection {
                
            case .Down:
                scrollToInitialView()
                break
            case .Up:
                scrollToFinalView()
                break
            }
            
        } else {
            
            scrollToInitialView()
        }
    }
    
    func scrollToInitialView() {
        
        topViewHeightConstraint.constant = topViewInitialHeight
        
        UIView.animate(withDuration: 0.25, animations: {
            
            self.view.layoutIfNeeded()
        })
    }
    
    func scrollToFinalView() {
        
        topViewHeightConstraint.constant = topViewFinalHeight
        
        UIView.animate(withDuration: 0.25, animations: {
            
            self.view.layoutIfNeeded()
        })
    }
}

