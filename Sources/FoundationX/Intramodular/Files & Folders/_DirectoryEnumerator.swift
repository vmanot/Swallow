//
// Copyright (c) Vatsal Manot
//

import Swallow

public class _DirectoryEnumerator: IteratorProtocol {
    private let fileManager: FileManager
    private let directoryURL: URL
    private let startDate: Date
    private var currentEnumerator: FileManager.DirectoryEnumerator?
    private var currentURL: URL?
    
    public init?(
        directoryURL: URL,
        fileManager: FileManager = .default
    ) {
        guard fileManager.fileExists(atPath: directoryURL.path) else {
            return nil
        }
        
        self.directoryURL = directoryURL
        self.fileManager = fileManager
        self.startDate = Date()
        self.currentEnumerator = fileManager.enumerator(
            at: directoryURL,
            includingPropertiesForKeys: nil,
            options: [.skipsSubdirectoryDescendants]
        )
    }
    
    public func next() -> Result<URL, Error>? {
        guard let currentEnumerator = self.currentEnumerator else {
            return nil
        }
        
        repeat {
            guard let nextURL = currentEnumerator.nextObject() as? URL else {
                return nil
            }
            
            let resourceValues = try? nextURL.resourceValues(forKeys: [.contentModificationDateKey])
            let modificationDate = resourceValues?.contentModificationDate ?? startDate
            
            if modificationDate > startDate {
                // Directory structure changed while enumerating
                return .failure(NSError(domain: NSCocoaErrorDomain, code: NSFileReadInvalidFileNameError, userInfo: nil))
            }
            
            self.currentURL = nextURL
        } while currentURL != nil && !fileManager.fileExists(atPath: currentURL!.path)
        
        guard let currentURL = self.currentURL else {
            return nil
        }
        
        return .success(currentURL)
    }
}

public struct _AsyncDirectoryIterator: AsyncIteratorProtocol {
    private var iterator: _DeferredAsyncIterator<AnyAsyncIterator<Result<URL, Error>>>
    
    public init(directoryURL: URL) {
        self.iterator = _DeferredAsyncIterator {
            let enumerator = try _DirectoryEnumerator(directoryURL: directoryURL).unwrap()
            
            return AnyAsyncIterator(enumerator)
        }
    }
    
    public mutating func next() async throws -> URL? {
        return try await iterator.next()?.get()
    }
}
