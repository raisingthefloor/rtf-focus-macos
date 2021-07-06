import CoreData
import Foundation
import RxCocoa
import RxSwift
import Cocoa

class Config {
   
    static var db = ""
    static var db_context: NSManagedObjectContext!
    static var db_memory_context: NSManagedObjectContext!
    static var delegate = NSApplication.shared.delegate as! AppDelegate
}
