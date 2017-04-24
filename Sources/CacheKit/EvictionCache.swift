//
//  EvictionCache.swift
//  CacheKit
//
//  Created by Seivan Heidari on 17/04/23.
//
//

import Foundation
//private class Box {
//    let value: Any
//
//    init(_ value: Any) {
//        self.value = value
//    }
//}

final internal class EvictionCacher<K: Hashable, V> {
    
    private let cache = NSCache<AnyObject, AnyObject>()
    
    internal init() {
        #if os(tvOS) || os(iOS)
            NotificationCenter
                .default
                .addObserver(
                    self,
                    selector: #selector(self.purge),
                    name: .UIApplicationDidReceiveMemoryWarning,
                    object: nil)
        #endif
    }
    
    internal func object(forKey key: K) -> V? { return self.cache.object(forKey: key as AnyObject)?.value as? V }
    internal func setObject(_ obj: V, forKey key: K) { self.cache.setObject(obj as AnyObject, forKey: key as AnyObject) }
    internal func setObject(_ obj: V, forKey key: K, cost: Int) { self.cache.setObject(obj as AnyObject, forKey: key as AnyObject , cost: cost) }
    internal func removeObject(forKey key: K) { self.cache.removeObject(forKey: key as AnyObject) }
    
    internal func removeAllObjects() { self.cache.removeAllObjects() }
    
    
    private func purge() { self.removeAllObjects() }
    
    internal var name: String {
        get { return self.cache.name }
        set { self.cache.name = newValue }
    }
    
    internal weak var delegate: NSCacheDelegate? {
        get { return self.cache.delegate }
        set { self.cache.delegate = newValue }
    }
    
    internal var totalCostLimit: Int {
        get { return self.cache.totalCostLimit }
        set { self.cache.totalCostLimit = newValue }
    }
    
    internal var countLimit: Int {
        get { return cache.countLimit }
        set { cache.countLimit = newValue }
    }
    
    internal var evictsObjectsWithDiscardedContent: Bool {
        get { return self.cache.evictsObjectsWithDiscardedContent }
        set { self.cache.evictsObjectsWithDiscardedContent = newValue }
    }
    
    deinit {
        #if os(tvOS) || os(iOS)
            NotificationCenter.default.removeObserver(self)
        #endif
    }
    
}
