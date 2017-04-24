//
//  CacheKit.swift
//  CacheKit
//
//  Created by Seivan Heidari on 17/04/23.
//
//

import Foundation

final public class CacheKit {
    
    fileprivate let cache = NSCache<AnyObject, AnyObject>()
    
    
    public init() {}

    @discardableResult
    public func value<K:Hashable, V>(forKey key:K, expires expiration:Expiration, _ handler:() -> V) -> V {
        return self.value(forKey: key, expires: expiration, bump: nil) { _ in handler() }
    }

    @discardableResult
    public func value<K:Hashable, V>(forKey key:K, bump:Expiration, _ handler:() -> V) -> V {
        return self.value(forKey: key, expires: nil, bump: bump) { _ in handler() }
    }

    @discardableResult
    public func value<K:Hashable, V>(forKey key:K, _ handler:() -> V) -> V {
        return self.value(forKey: key, expires: nil, bump: nil) { _ in handler() }
    }

    @discardableResult
    public func value<K:Hashable, V>(forKey key:K, expires expiration:Expiration?, bump:Expiration?, _ handler:( CacheItem<V>?) -> V) -> V {
        let container:ValueContainer<K, V>? = self.container(forKey: key)
        switch (container, container?.expirationDate)  {
        case let (container?, expirationDate?) where expirationDate > Date():
            if let b = bump { DispatchQueue.global(qos: .userInitiated).async { self.set(container.bumped(b)) } }
            return container.value
        case let (container?, nil):
            return container.value
        default:
            let value  = handler(container?.item)
            self.set(ValueContainer(key: key, value: value, expires: expiration))
            return value
            
        }
        
        
    }
    
    
    
    
    
    public func value<K:Hashable, V>(forKey key:K) -> V?  {
        guard let container = (self.cache.object(forKey: key as AnyObject) as? ValueContainer<K, V>) else { return nil }
        guard let expirationDate = container.expirationDate else { return container.value }
        guard expirationDate > Date() else { return nil }
        return container.value
        
        
        
    }
    
    
    public func set<K:Hashable, V>(_ value: V, forKey key:K) {
        self.set(ValueContainer(key: key, value: value))
    }
    
    fileprivate func set<K:Hashable, V>(_ container: ValueContainer<K, V>) {
        self.cache.setObject(container as AnyObject, forKey: container.key as AnyObject )
    }
    
    
    private func container<K:Hashable, V>(forKey key: K) -> ValueContainer<K, V>?  {
        return self.cache.object(forKey: key as AnyObject) as? ValueContainer<K, V>
    }
    
    
    public func contains<K:Hashable, V>(key:K, withValueType valueType:V.Type) -> Bool  {
        let value:V? = self.value(forKey: key)
        return value != nil
        
    }
    
    
    public func popValue<K:Hashable, V>(forKey key: K) -> V? {
        defer { self.removeValue(forKey: key) }
        guard let container = (self.cache.object(forKey: key as AnyObject) as? ValueContainer<K, V>) else { return nil }
        guard let expirationDate = container.expirationDate else { return container.value }
        guard expirationDate > Date() else { return nil }
        return container.value
    }
    
    public func removeValue<K:Hashable>(forKey key: K) {
        self.cache.removeObject(forKey: key as AnyObject)
    }
    
    public func removeAllObjects() {
        self.cache.removeAllObjects()
    }
}


public typealias CacheItem<V> = (
    expirationDate:Date?,
    expirationTime:CacheKit.Expiration?,
    previousValue:V
)


fileprivate struct ValueContainer<K:Hashable, V>  {
    
    private(set) var expirationDate:Date?
    var expirationTime:CacheKit.Expiration? { didSet { self.expirationDate = self.expirationTime?.date } }
    
    var value:V
    let key:K
    
    
    fileprivate mutating func bump(_ expiration: CacheKit.Expiration) { self = self.bumped(expiration) }
    
    fileprivate func bumped(_ expiration: CacheKit.Expiration) -> ValueContainer<K, V> {
        var copy = self
        copy.expirationTime = expiration.bumped(with: expiration)
        return copy
    }
    
    
    fileprivate init(key:K, value:V, expires expiration:CacheKit.Expiration? = nil) {
        self.key = key
        self.value = value
        self.expirationTime = expiration
        self.expirationDate = expiration?.date
    }
    
    
    
    fileprivate var item:CacheItem<V> {
        return CacheItem(
            self.expirationDate,
            self.expirationTime,
            self.value
        )
    }
    
    
}







