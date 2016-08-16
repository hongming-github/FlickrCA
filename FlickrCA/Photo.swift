//
//  Photo.swift
//  FlickerCA
//
//  Created by zhm on 16/8/15.
//  Copyright © 2016年 zhm. All rights reserved.
//

import Foundation

class Photo{
    var id: String
    var url : String
    var title: String
    var tag : String
    var like : Bool
    var comments : String?
    
    init(id:String,url:String,title:String,tag:String){
        self.id = id
        self.url = url
        self.title = title
        self.tag = tag
        self.like = false
        self.comments = "no comments"
    }
    
    init(id:String,url:String,title:String,tag:String,comments : String){
        self.id = id
        self.url = url
        self.title = title
        self.tag = tag
        self.like = false
        self.comments = comments
    }
    
}