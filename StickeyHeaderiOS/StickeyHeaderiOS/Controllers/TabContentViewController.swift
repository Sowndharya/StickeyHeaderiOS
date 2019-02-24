//
//  ProfileTabViewController.swift
//  ProfilePageSampleProject
//
//  Created by Sowndharya M on 06/01/18.
//  Copyright © 2018 Sowndharya M. All rights reserved.
//

import UIKit

enum DragDirection {
    
    case Up
    case Down
}

var topViewInitialHeight : CGFloat = 300 // If self profile, then 234, This should be changed in viewDidLoad()

let topViewFinalHeight : CGFloat = UIApplication.shared.statusBarFrame.size.height + 44 //navigation hieght

var topViewHeightConstraintRange = topViewFinalHeight..<topViewInitialHeight

protocol InnerTableViewScrollDelegate: class {
    
    func getCurrentHeightConstraint() -> CGFloat
    func innerTableViewScroll(with height: CGFloat)
    func innerTableViewScrollEnded(withScrollDirection scrollDirection: DragDirection)
}

class TabContentViewController: UIViewController {

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

extension TabContentViewController: UITableViewDataSource {
    
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

extension TabContentViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let delta = scrollView.contentOffset.y - oldContentOffset.y
        
        var topViewCurrentHeightConst = self.innerTableViewScrollDelegate?.getCurrentHeightConstraint()
        
        if let topViewUnwrappedHeight = topViewCurrentHeightConst {
            
            if delta > 0 // The current offset should be greater than the previous offset indicating an upward scroll
                && topViewUnwrappedHeight > topViewHeightConstraintRange.lowerBound // The top view shouldn't have reached it's min height
                && scrollView.contentOffset.y > 0 { //There are cases when u can keep on draggin the table view down even after the top most cell has been reached.. Make sure you are not dragging the view up once we do such a drag and scroll upwards
                
                dragDirection = .Up
                innerTableViewScrollDelegate?.innerTableViewScroll(with: delta)
                scrollView.contentOffset.y -= delta
            }
        }
        
        topViewCurrentHeightConst = self.innerTableViewScrollDelegate?.getCurrentHeightConstraint()
        
        if let topViewUnwrappedHeight = topViewCurrentHeightConst {
            
            if delta < 0 // The current offset should be greater than the previous offset indicating an upward scroll
                && topViewUnwrappedHeight < topViewHeightConstraintRange.upperBound // The top view shouldn't have reached it's min height
                && scrollView.contentOffset.y < 0 { //There are cases when u can keep on draggin the table view down even after the top most cell has been reached.. Make sure you are not dragging the view up once we do such a drag and scroll upwards
                
                dragDirection = .Down
                innerTableViewScrollDelegate?.innerTableViewScroll(with: delta)
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
