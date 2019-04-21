//
//  InitialViewController.swift
//  StickeyHeaderiOS
//
//  Created by Sowndharya M on 20/04/19.
//  Copyright © 2019 Sowndharya M. All rights reserved.
//

import UIKit

struct Approach {
    
    var title: String
    var subTitle: String
}

class InitialViewController: UITableViewController {
    
    var approaches = [Approach]()
    
    let titles = ["Approach 1", "Approach 2"]
    let subTitles = ["Adjust header view height based on table content offset and reset the content inset. - Does not work with mutliplt table views.",
                     "Adjust header view height based on table content offset and reset the content offset - with multiple table views."]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        setupDataSource()
        setupTableView()
    }
    
    func setupDataSource() {
        
        let approach1 = Approach(title: titles[0], subTitle: subTitles[0])
        let approach2 = Approach(title: titles[1], subTitle: subTitles[1])
        
        approaches = [approach1, approach2]
    }
    
    func setupTableView() {
        
        tableView.register(UINib(nibName: InitialTableViewCellID, bundle: nil),
                           forCellReuseIdentifier: InitialTableViewCellID)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 80
    }
}

extension InitialViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return approaches.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: InitialTableViewCellID) as? InitialTableViewCell {
            
            cell.headerLabel.text = approaches[indexPath.row].title
            cell.contentLabel.text = approaches[indexPath.row].subTitle
            return cell
        }
        
        return UITableViewCell()
    }
}

extension InitialViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            
            let vc = StickyHeaderViewController1()
            present(vc, animated: true, completion: nil)
        
        } else if indexPath.row == 1 {
            
            let vc = StickyHeaderViewController2()
            present(vc, animated: true, completion: nil)
        }
    }
}
