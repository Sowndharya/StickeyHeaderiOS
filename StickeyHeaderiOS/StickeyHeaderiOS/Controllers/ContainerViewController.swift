//
//  ContainerViewController.swift
//  StickeyHeaderiOS
//
//  Created by Sowndharya M on 06/01/18.
//  Copyright © 2018 Sowndharya M. All rights reserved.
//

import UIKit

var topViewInitialHeight : CGFloat = 200

let topViewFinalHeight : CGFloat = UIApplication.shared.statusBarFrame.size.height + 44 //navigation hieght

let topViewHeightConstraintRange = topViewFinalHeight..<topViewInitialHeight

class ContainerViewController: UIViewController {
    
    //MARK:- Change this value for number of tabs.
    
    let tabsCount = 5; #warning ("< 1 causes crash")
    
    //MARK:- Outlets
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tabBarCollectionView: UICollectionView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    
    //MARK:- Programatic UI Properties
    
    var pageViewController = UIPageViewController()
    var selectedTabView = UIView()
    
    //MARK:- View Model
    
    var pageCollection = PageCollection()
    
    //MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupPagingViewController()
        populateBottomView()
        addPanGestureToTopViewAndCollectionView()
    }
    
    //MARK: View Setup
    
    func setupCollectionView() {
        
        let layout = tabBarCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.estimatedItemSize = CGSize(width: 100, height: 50)
        
        tabBarCollectionView.register(UINib(nibName: TabBarCollectionViewCellID, bundle: nil),
                                      forCellWithReuseIdentifier: TabBarCollectionViewCellID)
        tabBarCollectionView.dataSource = self
        tabBarCollectionView.delegate = self
        
        setupSelectedTabView()
    }
    
    func setupSelectedTabView() {
        
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 10, height: 10))
        label.text = "TAB \(1)"
        label.sizeToFit()
        var width = label.intrinsicContentSize.width
        width = width + 40
        
        selectedTabView.frame = CGRect(x: 0 , y: 55, width: width, height: 5)
        selectedTabView.backgroundColor = UIColor(red:0.65, green:0.58, blue:0.94, alpha:1)
        tabBarCollectionView.addSubview(selectedTabView)
    }
    
    func setupPagingViewController() {
        
        pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                      navigationOrientation: .horizontal,
                                                      options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
    }
    
    func populateBottomView() {
        
        for subTabCount in 0..<tabsCount {
            
            let tabContentVC = ContentViewController2()
            tabContentVC.innerTableViewScrollDelegate = self
            tabContentVC.numberOfCells = (subTabCount + 1) * 10
            
            let displayName = "TAB \(subTabCount + 1)"
            let page = Page(with: displayName, _vc: tabContentVC)
            pageCollection.pages.append(page)
        }
        
        let initialPage = 0
        
        pageViewController.setViewControllers([pageCollection.pages[initialPage].vc],
                                                  direction: .forward,
                                                  animated: true,
                                                  completion: nil)
        
        
        addChild(pageViewController)
        pageViewController.willMove(toParent: self)
        bottomView.addSubview(pageViewController.view)
        
        pinPagingViewControllerToBottomView()
    }
    
    func pinPagingViewControllerToBottomView() {
        
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        pageViewController.view.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor).isActive = true
        pageViewController.view.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor).isActive = true
        pageViewController.view.topAnchor.constraint(equalTo: bottomView.topAnchor).isActive = true
        pageViewController.view.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor).isActive = true
    }

    func addPanGestureToTopViewAndCollectionView() {
        
        let topViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(topViewMoved))
        
        headerView.isUserInteractionEnabled = true
        headerView.addGestureRecognizer(topViewPanGesture)
        
        /* Adding pan gesture to collection view is overriding the collection view scroll.
         
        let collViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(topViewMoved))
        
        tabBarCollectionView.isUserInteractionEnabled = true
        tabBarCollectionView.addGestureRecognizer(collViewPanGesture)
         
        */
    }
    
    var dragInitialY: CGFloat = 0
    var dragPreviousY: CGFloat = 0
    var dragDirection: DragDirection = .Up
    
    @objc func topViewMoved(_ gesture: UIPanGestureRecognizer) {
        
        var dragYDiff : CGFloat
        
        switch gesture.state {
            
        case .began:
            
            dragInitialY = gesture.location(in: self.view).y
            dragPreviousY = dragInitialY
            
        case .changed:
            
            let dragCurrentY = gesture.location(in: self.view).y
            dragYDiff = dragPreviousY - dragCurrentY
            dragPreviousY = dragCurrentY
            dragDirection = dragYDiff < 0 ? .Down : .Up
            innerTableViewDidScroll(withDistance: dragYDiff)
            
        case .ended:
            
            innerTableViewScrollEnded(withScrollDirection: dragDirection)
            
        default: return
        
        }
    }
    
    //MARK:- View Action Methods
    
    func setBottomPagingView(toPageWithAtIndex index: Int, andNavigationDirection navigationDirection: UIPageViewController.NavigationDirection) {
        
        pageViewController.setViewControllers([pageCollection.pages[index].vc],
                                                  direction: navigationDirection,
                                                  animated: true,
                                                  completion: nil)
    }
    
    func scrollSelectedTabView(toIndexPath indexPath: IndexPath, shouldAnimate: Bool = true) {
        
        UIView.animate(withDuration: 0.3) {
            
            if let cell = self.tabBarCollectionView.cellForItem(at: indexPath) {
                
                self.selectedTabView.frame.size.width = cell.frame.width
                self.selectedTabView.frame.origin.x = cell.frame.origin.x
            }
        }
    }
}

extension ContainerViewController: UICollectionViewDataSource {
    
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

extension ContainerViewController: UICollectionViewDelegateFlowLayout {
    
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
        
        scrollSelectedTabView(toIndexPath: indexPath)
        
        setBottomPagingView(toPageWithAtIndex: indexPath.item, andNavigationDirection: direction)
    }
}

extension ContainerViewController: UIPageViewControllerDataSource {
    
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

extension ContainerViewController: UIPageViewControllerDelegate {
    
    //MARK:- Delegate Method to tell Inner View Controller movement inside Page View Controller
    //Capture it and change the selection bar position in collection View
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard completed else { return }
        
        guard let currentVC = pageViewController.viewControllers?.first else { return }
        
        guard let currentVCIndex = pageCollection.pages.firstIndex(where: { $0.vc == currentVC }) else { return }
        
        let indexPathAtCollectionView = IndexPath(item: currentVCIndex, section: 0)
        
        scrollSelectedTabView(toIndexPath: indexPathAtCollectionView)
        tabBarCollectionView.scrollToItem(at: indexPathAtCollectionView,
                                          at: .centeredHorizontally,
                                          animated: true)
    }
}

extension ContainerViewController: InnerTableViewScrollDelegate {
    
    var currentHeaderHeight: CGFloat {
        
        return headerViewHeightConstraint.constant
    }
    
    func innerTableViewDidScroll(withDistance scrollDistance: CGFloat) {
       
        headerViewHeightConstraint.constant -= scrollDistance
        
        /* Don't restrict the downward scroll.
 
        if headerViewHeightConstraint.constant > topViewInitialHeight {

            headerViewHeightConstraint.constant = topViewInitialHeight
        }
         
        */
        
        if headerViewHeightConstraint.constant < topViewFinalHeight {
            
            headerViewHeightConstraint.constant = topViewFinalHeight
        }
    }
    
    func innerTableViewScrollEnded(withScrollDirection scrollDirection: DragDirection) {
        
        let topViewHeight = headerViewHeightConstraint.constant
        
        /*
         *  Scroll is not restricted.
         *  So this check might cause the view to get stuck in the header height is greater than initial height.
 
        if topViewHeight >= topViewInitialHeight || topViewHeight <= topViewFinalHeight { return }
         
        */
        
        if topViewHeight <= topViewFinalHeight + 20 {
            
            scrollToFinalView()
            
        } else if topViewHeight <= topViewInitialHeight - 20 {
            
            switch scrollDirection {
                
            case .Down: scrollToInitialView()
            case .Up: scrollToFinalView()
            
            }
            
        } else {
            
            scrollToInitialView()
        }
    }
    
    func scrollToInitialView() {
        
        let topViewCurrentHeight = headerView.frame.height
        
        let distanceToBeMoved = abs(topViewCurrentHeight - topViewInitialHeight)
        
        var time = distanceToBeMoved / 500
        
        if time < 0.25 {
            
            time = 0.25
        }
        
        headerViewHeightConstraint.constant = topViewInitialHeight
        
        UIView.animate(withDuration: TimeInterval(time), animations: {
            
            self.view.layoutIfNeeded()
        })
    }
    
    func scrollToFinalView() {
        
        let topViewCurrentHeight = headerView.frame.height
        
        let distanceToBeMoved = abs(topViewCurrentHeight - topViewFinalHeight)
        
        var time = distanceToBeMoved / 500
        
        if time < 0.25 {
            
            time = 0.25
        }
        
        headerViewHeightConstraint.constant = topViewFinalHeight
        
        UIView.animate(withDuration: TimeInterval(time), animations: {
            
            self.view.layoutIfNeeded()
        })
    }
}
