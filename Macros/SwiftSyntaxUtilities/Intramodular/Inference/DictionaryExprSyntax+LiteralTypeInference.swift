//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

extension DictionaryExprSyntax {
    public var inferredLiteralKeyType: TypeSyntax? {
        guard case .elements(let elements) = content else {
            return nil
        }

        return elements.map(\.key).inferredCommonLiteralType
    }

    public var inferredLiteralValueType: TypeSyntax? {
        guard case .elements(let elements) = content else {
            return nil
        }

        return elements.map(\.value).inferredCommonLiteralType
    }

    /// This dictionary literal's type, when mechanically inferable from its entries.
    public var inferredLiteralType: TypeSyntax? {
        guard let keyType = inferredLiteralKeyType,
              let valueType = inferredLiteralValueType else {
            return nil
        }

        return dictionaryTypeSyntax(key: keyType, value: valueType)
    }
}

extension Sequence where Element == DictionaryExprSyntax {
    /// A common dictionary type inferred from nonempty literals in this sequence.
    public var inferredCommonLiteralType: TypeSyntax? {
        let dictionaries = filter { !$0.isEmptyDictionaryLiteral }
        let elementLists = dictionaries.compactMap { dictionary -> DictionaryElementListSyntax? in
            guard case .elements(let elements) = dictionary.content else {
                return nil
            }

            return elements
        }

        guard !dictionaries.isEmpty,
              elementLists.count == dictionaries.count,
              let keyType = elementLists.flatMap({ $0.map(\.key) }).inferredCommonLiteralType,
              let valueType = elementLists.flatMap({ $0.map(\.value) }).inferredCommonLiteralType else {
            return nil
        }

        return dictionaryTypeSyntax(key: keyType, value: valueType)
    }
}

private func dictionaryTypeSyntax(
    key: TypeSyntax,
    value: TypeSyntax
) -> TypeSyntax {
    TypeSyntax(
        DictionaryTypeSyntax(
            key: key,
            colon: .colonToken(trailingTrivia: .space),
            value: value
        )
    )
}
