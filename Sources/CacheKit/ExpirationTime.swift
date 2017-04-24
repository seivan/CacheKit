//
//  ExpirationTime.swift
//  CacheKit
//
//  Created by Seivan Heidari on 17/04/22.
//
//

import Foundation

extension CacheKit {
    public enum Expiration {
        case at(Date)
        case inSeconds(Int)
        case inMinutes(Int)
        case inHours(Int)
        
        public func and(_ component:Expiration) -> Expiration {
            switch self {
            case let .at(date):           return .at(date.addingTimeInterval(Double(self.seconds)))
            case let .inSeconds(seconds): return .inSeconds(seconds + component.seconds)
            case let .inMinutes(minutes): return .inMinutes(minutes + component.minutes)
            case let .inHours(hours):     return .inHours(hours     + component.hours)
            }
        }
        
        
        private var rounded:Int { return Int(self.date.timeIntervalSinceNow.rounded()) }
        
        public var seconds:Int  { return self.rounded       }
        public var minutes:Int  { return self.rounded/60    }
        public var hours:Int    { return self.rounded/3600  }
        
        
        public var date:Date {
            switch self {
            case let .at(date):           return date
            case let .inSeconds(seconds): return Date(timeIntervalSinceNow: Double(seconds))
            case let .inMinutes(minutes): return Date(timeIntervalSinceNow: Double(minutes) * 60)
            case let .inHours(hours):     return Date(timeIntervalSinceNow: Double(hours) * 3600)
            }
        }
        
        internal func bumped(with expiration:Expiration) -> Expiration {
            let at:Expiration = .at(expiration.date)
            switch self {
            case let .at(date):           return .at(date.addingTimeInterval(Double(self.seconds)))
            case let .inSeconds(seconds): return .inSeconds(seconds +  at.seconds)
            case let .inMinutes(minutes): return .inMinutes(minutes +  at.minutes)
            case let .inHours(hours):     return .inHours(hours     +  at.hours)
            }
            
        }
        
    }
    
}

extension CacheKit.Expiration : CustomDebugStringConvertible, CustomPlaygroundQuickLookable  {
    
    public var debugDescription: String {
        func on(_ d:Date) -> String { return "on \(d)" }
        let e = "Expires"
        switch self {
        case let .at(date):             return "\(e) \(on(date))"
        case let .inSeconds(seconds):   return "\(e) in \(seconds) seconds \(on(date))"
        case let .inMinutes(minutes):   return "\(e) in \(minutes) minutes \(on(date))"
        case let .inHours(hours):       return "\(e) in \(hours) hours \(on(date))"
        }
        
    }
    
    public var customPlaygroundQuickLook: PlaygroundQuickLook { return .text(self.debugDescription) }
    
}

extension CacheKit.Expiration : Hashable {
    public var hashValue: Int {return self.seconds.hashValue }
    public static func ==(lhs: CacheKit.Expiration, rhs: CacheKit.Expiration) -> Bool { return lhs.hashValue == rhs.hashValue }
}


extension CacheKit.Expiration : Comparable {
    public static func <(lhs: CacheKit.Expiration, rhs: CacheKit.Expiration) -> Bool    { return lhs.seconds < rhs.seconds  }
    public static func <=(lhs: CacheKit.Expiration, rhs: CacheKit.Expiration) -> Bool   { return lhs.seconds <= rhs.seconds }
    public static func >=(lhs: CacheKit.Expiration, rhs: CacheKit.Expiration) -> Bool   { return lhs.seconds >= rhs.seconds }
    public static func >(lhs: CacheKit.Expiration, rhs: CacheKit.Expiration) -> Bool    { return lhs.seconds > rhs.seconds  }
}
