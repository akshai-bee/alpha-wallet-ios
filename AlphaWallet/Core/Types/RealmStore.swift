//
//  RealmStore.swift
//  AlphaWallet
//
//  Created by Vladyslav Shepitko on 06.04.2022.
//

import RealmSwift
import Foundation

final class RealmStore {
    private let queue: DispatchQueue
    private let realm: Realm

    public init(queue: DispatchQueue = DispatchQueue(label: "RealmStore.syncQueue", qos: .background), realm: Realm) {
        self.queue = queue
        self.realm = realm
    }

    func performSync(_ callback: (Realm) -> Void) {
        dispatchPrecondition(condition: .notOnQueue(queue))
        queue.sync { [unowned self] in
            autoreleasepool {
                let realm = self.realm.threadSafe
                callback(realm)
            }
        }
    }
}

extension Realm {
    var threadSafe: Realm {
         try! Realm(configuration: configuration)
    }

    public func safeWrite(_ block: (() throws -> Void)) throws {
        if isInWriteTransaction {
            try block()
        } else {
            try write(block)
        }
    }
}