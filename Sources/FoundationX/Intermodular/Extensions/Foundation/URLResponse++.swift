//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension URLResponse {
    public func validateHTTPURLResponse() throws {
        guard let httpResponse = self as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        switch httpResponse.statusCode {
            case 200...299:
                return
            case 400...499:
                throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
            case 500...599:
                throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
            default:
                throw URLError(.unknown)
        }
    }
}
