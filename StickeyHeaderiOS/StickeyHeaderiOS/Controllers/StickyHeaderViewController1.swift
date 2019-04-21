//
//  StickyHeaderViewController1.swift
//  StickeyHeaderiOS
//
//  Created by Sowndharya M on 20/04/19.
//  Copyright © 2019 Sowndharya M. All rights reserved.
//

import UIKit

class StickyHeaderViewController1: UIViewController {
    
    //MARK:- Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stickyHeaderView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    //MARK:- Data Source
    
    var numberOfCells = 50
    
    //MARK: View Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupTableView()
    }
    
    //MARK: View Setup
    
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
    
    //MARK:- Action Methods
    
    @IBAction func onClickCloseButton(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
}

//MARK:- Table View Data Source

extension StickyHeaderViewController1: UITableViewDataSource {
    
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
    
    //MARK:- Sticky Header Effect
    
    static let offset_HeaderStop: CGFloat = 200 - 64  // At this offset the Header stops its transformations (Header height - Approx Nav Bar Height)
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let totalOffset = scrollView.contentOffset.y + stickyHeaderView.bounds.height + segmentedControl.bounds.height
        
        var headerTransform = CATransform3DIdentity // Both Scale and Translate.
        var segmentTransform = CATransform3DIdentity // Translate only.
        
        if totalOffset < 0 {
            
            /*
             * Table is pulled down below the header.
             * Animation to transform.
             */
            
            let headerScaleFactor:CGFloat = -(totalOffset) / stickyHeaderView.bounds.height
            let headerSizevariation = ((stickyHeaderView.bounds.height * (1.0 + headerScaleFactor)) - stickyHeaderView.bounds.height)/2
            headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
            headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
            
        } else {
            
            /*
             * Table scrolled up or down.
             */
            
            headerTransform = CATransform3DTranslate(headerTransform, 0, max(-StickyHeaderViewController1.offset_HeaderStop, -totalOffset), 0)
        }
        
        stickyHeaderView.layer.transform = headerTransform
        
        /*
         *  Scroll the segment view until its offset reaches the same offset at which the header stopped shrinking.
         */
        
        let segmentViewOffset = -totalOffset
        segmentTransform = CATransform3DTranslate(segmentTransform, 0, max(segmentViewOffset, -StickyHeaderViewController1.offset_HeaderStop), 0)
        segmentedControl.layer.transform = segmentTransform
    }
}
