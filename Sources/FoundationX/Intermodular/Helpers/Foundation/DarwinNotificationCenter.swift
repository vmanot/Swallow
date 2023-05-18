//
// Copyright (c) Vatsal Manot
//

import Combine
import Foundation
import Swift

public struct DarwinNotification {
    public struct Name: Equatable {
        /// The CFNotificationName's value
        fileprivate var rawValue: String
        
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        /// Initialize a new Notification Name, based on a CFNotificationName.
        public init(_ cfNotificationName: CFNotificationName) {
            rawValue = cfNotificationName.rawValue as String
        }
        
        public static func == (lhs: DarwinNotification.Name, rhs: DarwinNotification.Name) -> Bool {
            return (lhs.rawValue as String) == (rhs.rawValue as String)
        }
    }
    
    /// The Darwin notification name
    public let name: Name
    
    /// Initializes the notification based on the name.
    public init(_ name: Name) {
        self.name = name
    }
}

public final class DarwinNotificationCenter {
    public static let shared = DarwinNotificationCenter()
    
    private let base = CFNotificationCenterGetDarwinNotifyCenter()
    
    private init() {
        
    }
    
    public func post(_ name: DarwinNotification.Name) {
        guard let cfNotificationCenter = self.base else {
            fatalError("Invalid CFNotificationCenter")
        }
        
        CFNotificationCenterPostNotification(
            cfNotificationCenter, CFNotificationName(rawValue: name.rawValue as CFString),
            nil,
            nil,
            false
        )
    }
    
    public func publisher(for name: DarwinNotification.Name) -> Publisher {
        .init(name: name)
    }
}

extension DarwinNotificationCenter {
    public struct Publisher: Combine.Publisher {
        public typealias Output = Void
        public typealias Failure = Never
        
        public let name: DarwinNotification.Name
        
        public func receive<S: Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
            subscriber.receive(subscription: Subscription(name: name, subscriber: .init(subscriber)))
        }
        
        final class Subscription: Combine.Subscription {
            let name: DarwinNotification.Name
            let subscriber: AnySubscriber<Void, Never>
            
            init(name: DarwinNotification.Name, subscriber: AnySubscriber<Void, Never>) {
                self.name = name
                self.subscriber = subscriber
                
                guard let notificationCenter = DarwinNotificationCenter.shared.base else {
                    fatalError("Invalid Darwin observation info.")
                }
                
                let callback: CFNotificationCallback = { (center, observer, name, object, userInfo) in
                    guard let observer = observer else {
                        return
                    }
                    
                    let subscription = Unmanaged<Subscription>.fromOpaque(observer).takeUnretainedValue()
                    
                    guard let name = name.map({ $0.rawValue as String }), name == subscription.name.rawValue else {
                        return
                    }
                    
                    _ = subscription.subscriber.receive(())
                }
                
                CFNotificationCenterAddObserver(
                    notificationCenter,
                    Unmanaged.passUnretained(self).toOpaque(),
                    callback,
                    name.rawValue as CFString,
                    nil,
                    .coalesce
                )
            }
            
            func request(_ demand: Subscribers.Demand) {
                
            }
            
            func cancel() {
                guard let notificationCenter = DarwinNotificationCenter.shared.base else {
                    fatalError("Invalid Darwin observation info.")
                }
                
                CFNotificationCenterRemoveObserver(
                    notificationCenter,
                    Unmanaged.passUnretained(self).toOpaque(),
                    CFNotificationName(rawValue: name.rawValue as CFString),
                    nil
                )
            }
        }
    }
}
