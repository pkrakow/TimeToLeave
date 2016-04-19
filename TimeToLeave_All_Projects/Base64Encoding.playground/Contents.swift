//: Playground - noun: a place where people can play

import UIKit

let plainString = "my plain data"

let plainData = (plainString as NSString).dataUsingEncoding(NSUTF8StringEncoding)
let base64String = plainData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
print(base64String) // bXkgcGxhbmkgdGV4dA==


let decodedData = NSData(base64EncodedString: base64String, options:NSDataBase64DecodingOptions(rawValue: 0))
let decodedString = NSString(data: decodedData!, encoding: NSUTF8StringEncoding)
print(decodedString) // my plain data




class Book: NSObject, NSCoding {
    var title: String
    var author: String
    var pageCount: Int
    var categories: [String]
    var available: Bool
    
    // Memberwise initializer
    init(title: String, author: String, pageCount: Int, categories: [String], available: Bool) {
        self.title = title
        self.author = author
        self.pageCount = pageCount
        self.categories = categories
        self.available = available
    }
    
    // MARK: NSCoding
    
    required convenience init?(coder decoder: NSCoder) {
        guard let title = decoder.decodeObjectForKey("title") as? String,
            let author = decoder.decodeObjectForKey("author") as? String,
            let categories = decoder.decodeObjectForKey("categories") as? [String]
            else { return nil }
        
        self.init(
            title: title,
            author: author,
            pageCount: decoder.decodeIntegerForKey("pageCount"),
            categories: categories,
            available: decoder.decodeBoolForKey("available")
        )
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.title, forKey: "title")
        coder.encodeObject(self.author, forKey: "author")
        coder.encodeInt(Int32(self.pageCount), forKey: "pageCount")
        coder.encodeObject(self.categories, forKey: "categories")
        coder.encodeBool(self.available, forKey: "available")
    }
}

let books = Book(title: "testTitle", author: "testAuthor", pageCount: 5, categories: ["test"], available: true)

let data = NSKeyedArchiver.archivedDataWithRootObject(books)
NSUserDefaults.standardUserDefaults().setObject(data, forKey: "books")
print(data)

if let data = NSUserDefaults.standardUserDefaults().objectForKey("books") as? NSData {
    let books = NSKeyedUnarchiver.unarchiveObjectWithData(data)
}