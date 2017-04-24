//
//  SharedCacheKitTests.swift
//  CacheKit
//
//  Created by Seivan Heidari on 17/04/20.
//
//

import Foundation
import XCTest
import CacheKit
class CacheKitTests: XCTestCase {
    
    
    func testCachingWithNewKey() {

        let cache = CacheKit()
        
        let cachedValue:String = cache.value(forKey: "1") { "Hello World" }
        
        XCTAssertEqual(cachedValue, "Hello World")
    }

    
    func testCachingWithExistingKey() {
        
        let cache = CacheKit()
        
        cache.value(forKey: "1") { "Hello World" }
        let cachedValue:String = cache.value(forKey: "1") { "ByeBye World" }

        
        XCTAssertEqual(cachedValue, "Hello World")
    }
    
    
    func testCachingWithExpiringKeyStillValid() {
        
        let cache = CacheKit()
        
        
        cache.value(forKey: "1", expires:.inSeconds(1)) { "Hello World" }
        let cachedValue:String = cache.value(forKey: "1") { "ByeBye World" }
        
        
        XCTAssertEqual(cachedValue, "Hello World")
    }

    func testCachingWithExpiringKeyNoLongerValid() {
        
        let cache = CacheKit()
        
        cache.value(forKey: "1", expires:.inSeconds(1)) { "Hello World" }
        
        sleep(2)
        
        let cachedValue:String = cache.value(forKey: "1") { "ByeBye World" }
        
        XCTAssertEqual(cachedValue, "ByeBye World")
    }
    
    func testCachingWithExpiringKeyBumpedStillValid() {
        
        let cache = CacheKit()

        
        cache.value(forKey: "1", expires:.inSeconds(1)) { "Hello World" }
        cache.value(forKey: "1", bump:.inSeconds(1)) { "Hello World" }
        
        sleep(1)
        
        let cachedValue:String = cache.value(forKey: "1") { "ByeBye World" }
        
        XCTAssertEqual(cachedValue, "Hello World")
    }

    func testCachingWithExpiringKeyBumpedButNoLongerValid() {
        
        let cache = CacheKit()
        
        
        cache.value(forKey: "1", expires:.inSeconds(1)) { "Hello World" }
        sleep(1)
        cache.value(forKey: "1", bump:.inSeconds(1)) { "Hello New World" }

        let cachedValue:String = cache.value(forKey: "1") { "ByeBye World" }
        
        XCTAssertEqual(cachedValue, "Hello New World")
    }
    
    
    func testCachingWithPreviousValue() {
        
        let cache = CacheKit()
        
        let expiration = CacheKit.Expiration.inSeconds(1)
        let date = expiration.date
        
        cache.value(forKey: "1", expires:expiration) { "Hello World" }

        sleep(2)
        
        let _:String = cache.value(forKey: "1", expires:nil, bump:nil) {
            XCTAssertEqual($0!.previousValue, "Hello World")
            XCTAssertEqualWithAccuracy($0!.expirationDate!.timeIntervalSince1970, date.timeIntervalSince1970, accuracy: 0.1)
            XCTAssertEqual($0!.expirationTime, expiration)
            return "Hello New World"
        }
        
        let cachedValue:String = cache.value(forKey: "1") { "ByeBye World" }
        
        XCTAssertEqual(cachedValue, "Hello New World")
    }
    
    
    func testValueForKey() {
        
        let cache = CacheKit()
        
        
        cache.value(forKey: "1") { "Hello World" }
        
        let cachedValue:String = cache.value(forKey: "1")!
        let noValue:String? = cache.value(forKey: "2")

        XCTAssertEqual(cachedValue, "Hello World")
        XCTAssertNil(noValue)
    }

    func testValueForExpiredKey() {
        
        let cache = CacheKit()
        
        
        cache.value(forKey: "1", expires: .inSeconds(1)) { "Hello World" }
        sleep(2)
        
        let cachedValue:String? = cache.value(forKey: "1")
        
        XCTAssertNil(cachedValue)
    }

    func testValueForReplacedExpiredKey() {
        
        let cache = CacheKit()
        
        cache.value(forKey: "1", expires: .inSeconds(1)) { "Hello World" }
        sleep(2)
        cache.value(forKey: "1") { "Hello New World" }
        let cachedValue:String? = cache.value(forKey: "1")
        XCTAssertEqual(cachedValue, "Hello New World")


    }

    
    func testSetValueForKey() {
        
        let cache = CacheKit()
    
        cache.set("Hello World", forKey: "1")
        let cachedValue:String? = cache.value(forKey: "1")
        XCTAssertEqual(cachedValue, "Hello World")
        
        cache.set("Hello New World", forKey: "1")
        let newValue:String? = cache.value(forKey: "1")
        XCTAssertEqual(newValue, "Hello New World")
        
    }

    func testContainsValueForKey() {
        
        let cache = CacheKit()
        
        cache.set("Hello World", forKey: "1")
        XCTAssertTrue(cache.contains(key: "1", withValueType:String.self))
        
    }


    func testContainsNoValueForExpiredKey() {
        
        let cache = CacheKit()
        
        cache.value(forKey: "1", expires: .inSeconds(1)) { "Hello World" }
        sleep(2)
        XCTAssertFalse(cache.contains(key: "1", withValueType:String.self))
        
    }

    func testContainsValueForBumpedKey() {
        
        let cache = CacheKit()
        
        cache.value(forKey: "1", expires: .inSeconds(1)) { "Hello World" }
        cache.value(forKey: "1", bump: .inSeconds(1)) { "Hello New World" }
        sleep(1)
        XCTAssertTrue(cache.contains(key: "1", withValueType:String.self))
        
    }

    func testPopValueForKey() {
        
        let cache = CacheKit()
        
        cache.value(forKey: "1") { "Hello World" }
        XCTAssertTrue(cache.contains(key: "1", withValueType:String.self))
        let cachedValue:String? = cache.popValue(forKey: "1")
        XCTAssertEqual(cachedValue, "Hello World")
        XCTAssertFalse(cache.contains(key: "1", withValueType:String.self))
        
    }

    func testPopValueForKeyExpired() {
        
        let cache = CacheKit()
        
        cache.value(forKey: "1", expires: .inSeconds(1)) { "Hello World" }
        XCTAssertTrue(cache.contains(key: "1", withValueType:String.self))
        sleep(2)
        let cachedValue:String? = cache.popValue(forKey: "1")
        XCTAssertNil(cachedValue)
        XCTAssertFalse(cache.contains(key: "1", withValueType:String.self))
        
    }

    func testRemoveValueForKey() {
        
        let cache = CacheKit()
        
        cache.value(forKey: "1") { "Hello World" }
        XCTAssertTrue(cache.contains(key: "1", withValueType:String.self))
        cache.removeValue(forKey: "1")
        let cachedValue:String? = cache.value(forKey: "1")
        XCTAssertNil(cachedValue)
        XCTAssertFalse(cache.contains(key: "1", withValueType:String.self))
        
    }

    func testRemoveAllObjects() {
        
        let cache = CacheKit()
        
        cache.value(forKey: "1") { "Hello World" }
        cache.set("Hello New World", forKey: "2")

        cache.removeAllObjects()
        
        let otherCachedValue:String? = cache.value(forKey: "2")
        let cachedValue:String? = cache.value(forKey: "1")
        XCTAssertNil(cachedValue)
        XCTAssertNil(otherCachedValue)
        
        
    }

    
}
