//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension Foundation.FileManager.SearchPathDirectory: Swift.CaseIterable {
    #if os(iOS) || os(macOS)
    public static let allCases: [Self] = [
        .applicationDirectory,
        .demoApplicationDirectory,
        .developerApplicationDirectory,
        .adminApplicationDirectory,
        .libraryDirectory,
        .developerDirectory,
        .userDirectory,
        .documentationDirectory,
        .documentDirectory,
        .coreServiceDirectory,
        .desktopDirectory,
        .cachesDirectory,
        .applicationSupportDirectory,
        .allLibrariesDirectory,
        .trashDirectory,
        .autosavedInformationDirectory,
        .downloadsDirectory,
        .inputMethodsDirectory,
        .moviesDirectory,
        .musicDirectory,
        .picturesDirectory,
        .printerDescriptionDirectory,
        .sharedPublicDirectory,
        .preferencePanesDirectory,
        .itemReplacementDirectory,
    ]
    #elseif os(tvOS)
    public static let allCases: [Self] = [
        .applicationDirectory,
        .demoApplicationDirectory,
        .developerApplicationDirectory,
        .adminApplicationDirectory,
        .libraryDirectory,
        .developerDirectory,
        .userDirectory,
        .documentationDirectory,
        .documentDirectory,
        .coreServiceDirectory,
        .desktopDirectory,
        .cachesDirectory,
        .applicationSupportDirectory,
        .allLibrariesDirectory,
        .autosavedInformationDirectory,
        .downloadsDirectory,
        .inputMethodsDirectory,
        .moviesDirectory,
        .musicDirectory,
        .picturesDirectory,
        .printerDescriptionDirectory,
        .sharedPublicDirectory,
        .preferencePanesDirectory,
        .itemReplacementDirectory,
    ]
    #else
    public static let allCases: [Self] = [
        .applicationDirectory,
        .demoApplicationDirectory,
        .developerApplicationDirectory,
        .adminApplicationDirectory,
        .libraryDirectory,
        .developerDirectory,
        .userDirectory,
        .documentationDirectory,
        .documentDirectory,
        .coreServiceDirectory,
        .desktopDirectory,
        .cachesDirectory,
        .applicationSupportDirectory,
        .allLibrariesDirectory,
        .autosavedInformationDirectory,
        .downloadsDirectory,
        .inputMethodsDirectory,
        .moviesDirectory,
        .musicDirectory,
        .picturesDirectory,
        .printerDescriptionDirectory,
        .sharedPublicDirectory,
        .preferencePanesDirectory,
        .itemReplacementDirectory,
    ]
    #endif
}
