//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension CocoaPredicateExpression where Value == String {
    public func isEqualTo(_ string: String, _ options: CocoaComparisonPredicate.Options) -> CocoaPredicate<Root> {
        .comparison(.init(self, .equal, string, options))
    }
    
    public func beginsWith(_ string: String, _ options: CocoaComparisonPredicate.Options = .caseInsensitive) -> CocoaPredicate<Root> {
        .comparison(.init(self, .beginsWith, string, options))
    }
    
    public func contains(_ string: String, _ options: CocoaComparisonPredicate.Options = .caseInsensitive) -> CocoaPredicate<Root> {
        .comparison(.init(self, .contains, string, options))
    }
    
    public func endsWith(_ string: String, _ options: CocoaComparisonPredicate.Options = .caseInsensitive) -> CocoaPredicate<Root> {
        .comparison(.init(self, .endsWith, string, options))
    }
    
    public func like(_ string: String, _ options: CocoaComparisonPredicate.Options = .caseInsensitive) -> CocoaPredicate<Root> {
        .comparison(.init(self, .like, string, options))
    }
    
    public func matches(_ regex: NSRegularExpression, _ options: CocoaComparisonPredicate.Options = .caseInsensitive) -> CocoaPredicate<Root> {
        .comparison(.init(self, .matches, regex.pattern, options))
    }
}
