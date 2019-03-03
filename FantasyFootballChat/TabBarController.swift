//
//  TabBarController.swift
//  FantasyFootballChat
//
//  Created by Андрей Гончаров on 28/03/2018.
//  Copyright © 2018 Goncharov Andrei. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let dialoguesController = DialoguesController()
        dialoguesController.tabBarItem = UITabBarItem(title: "Chats", image: nil, tag: 0)
        dialoguesController.tabBarItem.badgeColor = UIColor(red: 10/255 , green: 80/255, blue: 10/255, alpha: 1)
        dialoguesController.tabBarItem.badgeColor = UIColor(red: 10/255 , green: 80/255, blue: 10/255, alpha: 1)
        
        // statsVC for statistics of Fantasy
        let statsController = StatsController()
        statsController.tabBarItem = UITabBarItem(title: "Stats", image: nil, tag: 1)
        statsController.tabBarItem.badgeColor = UIColor(red: 10/255 , green: 80/255, blue: 10/255, alpha: 1)
        statsController.tabBarItem.badgeColor = UIColor(red: 10/255 , green: 80/255, blue: 10/255, alpha: 1)
        
        let viewControllerList = [dialoguesController, statsController]

        viewControllers = viewControllerList
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
