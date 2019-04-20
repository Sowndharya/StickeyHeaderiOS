//
//  ContentViewController1.swift
//  StickeyHeaderiOS
//
//  Created by Sowndharya M on 06/01/18.
//  Copyright © 2018 Sowndharya M. All rights reserved.
//

import UIKit

enum DragDirection {
    
    case Up
    case Down
}

protocol InnerTableViewScrollDelegate: class {
    
    var currentHeaderHeight: CGFloat { get }
    
    func innerTableViewDidScroll(withDistance scrollDistance: CGFloat)
    func innerTableViewScrollEnded(withScrollDirection scrollDirection: DragDirection)
}

class ContentViewController1: UIViewController {
    
    //MARK:- Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- Scroll Delegate
    
    weak var innerTableViewScrollDelegate: InnerTableViewScrollDelegate?
    
    //MARK:- Stored Properties for Scroll Delegate
    
    private var dragDirection: DragDirection = .Up
    private var oldContentOffset = CGPoint.zero
    
    //MARK:- Data Source
    
    var numberOfCells: Int = 0
    
    //MARK:- View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    //MARK:- View Setup
    
    func setupTableView() {
        
        tableView.register(UINib(nibName: ProfileTableViewCellID, bundle: nil),
                           forCellReuseIdentifier: ProfileTableViewCellID)
        tableView.dataSource = self
        tableView.delegate = self
    }
}


//MARK:- Table View Data Source

extension ContentViewController1: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return numberOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCellID) as? ProfileTableViewCell {
            
            cell.cellLabel.text = "This is cell \(indexPath.row + 1)"
            return cell
        }
        
        return UITableViewCell()
    }
}

//MARK:- Scroll View Actions

extension ContentViewController1: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let delta = scrollView.contentOffset.y - oldContentOffset.y
        
        let topViewCurrentHeightConst = innerTableViewScrollDelegate?.currentHeaderHeight
        
        if let topViewUnwrappedHeight = topViewCurrentHeightConst {
            
            /**
             *  Re-size (Shrink) the top view only when the conditions meet:-
             *  1. The current offset of the table view should be greater than the previous offset indicating an upward scroll.
             *  2. The top view's height should be within its minimum height.
             *  3. There are cases when you can keep on draggin the table view up even after the bottom most cell has been reached.. Make sure you are not dragging the top view up once we do such a drag and scroll upwards.
             */
            
            if delta > 0
                && topViewUnwrappedHeight > topViewHeightConstraintRange.lowerBound
                && scrollView.contentOffset.y > 0 {
                
                dragDirection = .Up
                innerTableViewScrollDelegate?.innerTableViewDidScroll(withDistance: delta)
                scrollView.contentOffset.y -= delta
            }
            
            /**
             *  Re-size (Expand) the top view only when the conditions meet:-
             *  1. The current offset of the table view should be lesser than the previous offset indicating an downward scroll.
             *  2. The top view's height should be within its maximum height.
             *  3. There are cases when you can keep on draggin the table view up even after the top most cell has been reached.. Make sure you are not dragging the top view up once we do such a drag and scroll upwards.
             */
            
            if delta < 0
                // && topViewUnwrappedHeight < topViewHeightConstraintRange.upperBound
                && scrollView.contentOffset.y < 0 {
                
                dragDirection = .Down
                innerTableViewScrollDelegate?.innerTableViewDidScroll(withDistance: delta)
                scrollView.contentOffset.y -= delta
            }
        }
        
        oldContentOffset = scrollView.contentOffset
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        //You should not bring the view down until the table view has scrolled to it's top most cell.
        
        if scrollView.contentOffset.y <= 0 {
            
            innerTableViewScrollDelegate?.innerTableViewScrollEnded(withScrollDirection: dragDirection)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        //You should not bring the view down until the table view has scrolled to it's top most cell.
        
        if decelerate == false && scrollView.contentOffset.y <= 0 {
            
            innerTableViewScrollDelegate?.innerTableViewScrollEnded(withScrollDirection: dragDirection)
        }
    }
}
