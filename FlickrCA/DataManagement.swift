//
//  DataManagement.swift
//  FlickerCA
//
//  Created by zhm on 16/8/16.
//  Copyright © 2016年 zhm. All rights reserved.
//

import Foundation

class DataManagement {
    var likePhotosDB : COpaquePointer = nil
    var insertStatement : COpaquePointer = nil
    var selectByTagStatement : COpaquePointer = nil
    var selectByUrlStatement : COpaquePointer = nil
    var updateStatement : COpaquePointer = nil
    var deleteStatement : COpaquePointer = nil
    var selectAllStatement : COpaquePointer = nil
    let SQLITE_TRANSIENT = unsafeBitCast(-1, sqlite3_destructor_type.self)
    
    init(){
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        
        print(paths)
        
        let docsDir = paths + "/likephotos.sqlite"
        
        if(sqlite3_open(docsDir, &likePhotosDB) == SQLITE_OK){
            let sql = "CREATE TABLE IF NOT EXISTS LIKEPHOTOS (ID INTEGER PRIMARY KEY AUTOINCREMENT, PHOTOID TEXT, URL TEXT, TITLE TEXT, TAG TEXT, COMMENTS TEXT)"
            
            if sqlite3_exec(likePhotosDB, sql, nil, nil, nil) != SQLITE_OK {
                print("Failed to create table")
                print(sqlite3_errmsg(likePhotosDB))
            }
        }else{
            print("Failed to open database")
            print(sqlite3_errmsg(likePhotosDB))
        }
        prepareStatement()
    }
    
    func prepareStatement(){
        var sqlString : String
        //create
        sqlString = "INSERT INTO LIKEPHOTOS (photoid,url,title,tag,comments) VALUES (?,?,?,?,?)"
        var cSql = sqlString.cStringUsingEncoding(NSUTF8StringEncoding)
        sqlite3_prepare_v2(likePhotosDB, cSql!, -1, &insertStatement, nil)
        //find by tag
        sqlString = "SELECT photoid,url,title,comments FROM LIKEPHOTOS WHERE tag = ?"
        cSql = sqlString.cStringUsingEncoding(NSUTF8StringEncoding)
        sqlite3_prepare_v2(likePhotosDB, cSql!, -1, &selectByTagStatement, nil)
        //find by url
        sqlString = "SELECT title FROM LIKEPHOTOS WHERE url = ?"
        cSql = sqlString.cStringUsingEncoding(NSUTF8StringEncoding)
        sqlite3_prepare_v2(likePhotosDB, cSql!, -1, &selectByUrlStatement, nil)
        //update
        sqlString = "UPDATE LIKEPHOTOS SET comments = ? WHERE url = ?"
        cSql = sqlString.cStringUsingEncoding(NSUTF8StringEncoding)
        sqlite3_prepare_v2(likePhotosDB, cSql!, -1, &updateStatement, nil)
        //delete
        sqlString = "DELETE FROM LIKEPHOTOS WHERE url = ?"
        cSql = sqlString.cStringUsingEncoding(NSUTF8StringEncoding)
        sqlite3_prepare_v2(likePhotosDB, cSql!, -1, &deleteStatement, nil)
        //select all
        sqlString = "SELECT photoid,url,title,tag,comments FROM LIKEPHOTOS"
        cSql = sqlString.cStringUsingEncoding(NSUTF8StringEncoding)
        sqlite3_prepare_v2(likePhotosDB, cSql!, -1, &selectAllStatement, nil)
    }
    
    func create(photoid : String,url : String,title : String,tag : String,comments : String)->Bool{
        var f : Bool
        let photoidStr = photoid as NSString?
        let urlStr = url as NSString?
        let titleStr = title as NSString?
        let tagStr = tag as NSString?
        let commentsStr = comments as NSString?
        
        sqlite3_bind_text(insertStatement, 1, photoidStr!.UTF8String, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(insertStatement, 2, urlStr!.UTF8String, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(insertStatement, 3, titleStr!.UTF8String, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(insertStatement, 4, tagStr!.UTF8String, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(insertStatement, 5, commentsStr!.UTF8String, -1, SQLITE_TRANSIENT)
        
        if sqlite3_step(insertStatement) == SQLITE_DONE {
            f = true
        }else{
            f = false
            print("Error code: ", sqlite3_errcode(likePhotosDB))
            let error = String.fromCString(sqlite3_errmsg(likePhotosDB))
            print("Error msg: ",error)
        }
        sqlite3_reset(insertStatement)
        sqlite3_clear_bindings(insertStatement)
        return f
    }
    
    func findByTag(tag : String)->[Photo]{
        var findPhotos = [Photo]()
        
        let tagStr = tag as NSString?
        sqlite3_bind_text(selectByTagStatement, 1, (tagStr?.UTF8String)!, -1, SQLITE_TRANSIENT)
        
        while sqlite3_step(selectByTagStatement) == SQLITE_ROW {
            let photoid_buf = sqlite3_column_text(selectByTagStatement, 0)
            let id = String.fromCString(UnsafePointer<CChar>(photoid_buf))
            let url_buf = sqlite3_column_text(selectByTagStatement, 1)
            let url = String.fromCString(UnsafePointer<CChar>(url_buf))
            let title_buf = sqlite3_column_text(selectByTagStatement, 2)
            let title = String.fromCString(UnsafePointer<CChar>(title_buf))
            let comments_buf = sqlite3_column_text(selectByTagStatement, 3)
            let comments = String.fromCString(UnsafePointer<CChar>(comments_buf))
            let photo = Photo(id: id!, url: url!, title: title!, tag: tag, comments: comments!)
            findPhotos.append(photo)
            print(findPhotos.count)
        }
        sqlite3_reset(selectByTagStatement)
        sqlite3_clear_bindings(selectByTagStatement)
        return findPhotos
    }
    
    func findByUrl(url : String)->Bool{
        var f = false
        let urlStr = url as NSString?
        sqlite3_bind_text(selectByUrlStatement, 1, (urlStr?.UTF8String)!, -1, SQLITE_TRANSIENT)
        
        if sqlite3_step(selectByUrlStatement) == SQLITE_ROW {
            f = true
        }
        sqlite3_reset(selectByUrlStatement)
        sqlite3_clear_bindings(selectByUrlStatement)
        return f
    }
    
    func update(comments : String, url : String)->Bool{
        var f : Bool
        let commentsStr = comments as NSString?
        let urlStr = url as NSString?
        
        sqlite3_bind_text(updateStatement, 1, commentsStr!.UTF8String, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(updateStatement, 2, urlStr!.UTF8String, -1, SQLITE_TRANSIENT)
        
        if sqlite3_step(updateStatement) == SQLITE_DONE {
            f = true
        }
        else{
            f = false
            print("Error code: ", sqlite3_errcode(likePhotosDB))
            let error = String.fromCString(sqlite3_errmsg(likePhotosDB))
            print("Error msg: ",error)
        }
        sqlite3_reset(updateStatement)
        sqlite3_clear_bindings(updateStatement)
        return f
    }
    
    func delete(url : String)->Bool{
        var f : Bool
        let urlStr = url as NSString?
        sqlite3_bind_text(deleteStatement, 1, (urlStr?.UTF8String)!, -1, SQLITE_TRANSIENT)
        
        if sqlite3_step(deleteStatement) == SQLITE_DONE {
            f = true
        }else{
            f = false
            print("Error code: ", sqlite3_errcode(likePhotosDB))
            let error = String.fromCString(sqlite3_errmsg(likePhotosDB))
            print("Error msg: ",error)
        }
        sqlite3_reset(deleteStatement)
        sqlite3_clear_bindings(deleteStatement)
        return f
    }
    
    func selectAll()->[Photo]{
        var findPhotos = [Photo]()
        while sqlite3_step(selectAllStatement) == SQLITE_ROW {
            let photoid_buf = sqlite3_column_text(selectAllStatement, 0)
            let id = String.fromCString(UnsafePointer<CChar>(photoid_buf))
            let url_buf = sqlite3_column_text(selectAllStatement, 1)
            let url = String.fromCString(UnsafePointer<CChar>(url_buf))
            let title_buf = sqlite3_column_text(selectAllStatement, 2)
            let title = String.fromCString(UnsafePointer<CChar>(title_buf))
            let tag_buf = sqlite3_column_text(selectAllStatement, 3)
            let tag = String.fromCString(UnsafePointer<CChar>(tag_buf))
            let comments_buf = sqlite3_column_text(selectAllStatement, 4)
            var comments = String.fromCString(UnsafePointer<CChar>(comments_buf))
            if comments == nil {
                comments = "no comments"
            }
            let photo = Photo(id: id!, url: url!, title: title!, tag: tag!, comments: comments!)
            findPhotos.append(photo)
        }
        sqlite3_reset(selectAllStatement)
        sqlite3_clear_bindings(selectAllStatement)
        return findPhotos
    }
    
    func closeDB(){
        sqlite3_close(likePhotosDB)
    }
    
}