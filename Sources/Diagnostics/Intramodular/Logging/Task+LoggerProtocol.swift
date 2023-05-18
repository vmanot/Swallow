//
// Copyright (c) Vatsal Manot
//

import Swift

extension Task where Failure == Error {
    @discardableResult
    public func logger<L: LoggerProtocol>(_ logger: L) -> Task {
        Task.detached(priority: .utility) {
            do {
                return try await self.value
            } catch {
                logger.error(error)
                
                throw error
            }
        }
        
        return self
    }
}
