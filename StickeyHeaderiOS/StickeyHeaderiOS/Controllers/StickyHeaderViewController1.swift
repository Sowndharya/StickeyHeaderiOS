//
//  StickyHeaderViewController1.swift
//  StickeyHeaderiOS
//
//  Created by Sowndharya M on 20/04/19.
//  Copyright © 2019 Sowndharya M. All rights reserved.
//

import UIKit

class StickyHeaderViewController1: UIViewController {
    
    let offset_HeaderStop:CGFloat = 200 - 64  // At this offset the Header stops its transformations
    
    //MARK:- Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stickyHeaderView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    //MARK:- View Properties
    
    var headerView = UIView()
    
    //MARK:- Stored Properties
    
    var numberOfSections = 1
    var numberOfCells = 50
    
    var headerHeight: CGFloat = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    func setupTableView() {
        
        tableView.register(UINib(nibName: ProfileTableViewCellID, bundle: nil),
                           forCellReuseIdentifier: ProfileTableViewCellID)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 44
        
        tableView.contentInset = UIEdgeInsets(top: stickyHeaderView.frame.height + segmentedControl.frame.height,
                                              left: 0,
                                              bottom: 0,
                                              right: 0)
    }
    
    
    @IBAction func onClickCloseButton(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
}

//MARK:- Table View Data Source

extension StickyHeaderViewController1: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return numberOfSections
    }
    
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

//MARK:- Table View Delegate

extension StickyHeaderViewController1: UITableViewDelegate {
    
    // MARK: Scroll view delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y + stickyHeaderView.bounds.height + segmentedControl.bounds.height
        
        var headerTransform = CATransform3DIdentity
        var segmentTransform = CATransform3DIdentity
        
        if offset < 0 {
            
            // PULL DOWN -----------------
            
            let headerScaleFactor:CGFloat = -(offset) / stickyHeaderView.bounds.height
            let headerSizevariation = ((stickyHeaderView.bounds.height * (1.0 + headerScaleFactor)) - stickyHeaderView.bounds.height)/2
            headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
            headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
            
        } else {
            
            // SCROLL UP/DOWN ------------
            
            headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
        }
        
        // Apply Transformations
        
        stickyHeaderView.layer.transform = headerTransform
        
        // Segment control
        
        let segmentViewOffset = -offset
        
        // Scroll the segment view until its offset reaches the same offset at which the header stopped shrinking
        segmentTransform = CATransform3DTranslate(segmentTransform, 0, max(segmentViewOffset, -offset_HeaderStop), 0)
        
        segmentedControl.layer.transform = segmentTransform
    }
}
