//
//  SearchPhoto.swift
//  CollectionViewTest
//
//  Created by zhm on 16/8/13.
//  Copyright © 2016年 zhm. All rights reserved.
//

import Foundation

class SearchPhoto {
    
    let id: NSMutableArray
    let owner: NSMutableArray
    let farm: NSMutableArray
    let server: NSMutableArray
    let secret: NSMutableArray
    let title: NSMutableArray
    var tag: String
    
    init(){
        id = NSMutableArray()
        owner = NSMutableArray()
        farm = NSMutableArray()
        server = NSMutableArray()
        secret = NSMutableArray()
        title = NSMutableArray()
        tag = ""
    }
    
    func clear(){
        id.removeAllObjects()
        owner.removeAllObjects()
        farm.removeAllObjects()
        server.removeAllObjects()
        secret.removeAllObjects()
        title.removeAllObjects()
        tag = ""
    }
    
}