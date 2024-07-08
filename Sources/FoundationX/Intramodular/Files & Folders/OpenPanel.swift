//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import Combine
import Foundation

extension OpenPanel {
    public struct Configuration {
        public var directoryURL: URL?
        public var canChooseFiles: Bool = true
        public var canChooseDirectories: Bool = false
        public var canCreateDirectories: Bool = false
        public var allowsMultipleSelection: Bool = false
        public var message: String?
        public var prompt: String?
        public var validateURL: ((URL) throws -> Void)?
        public var shouldEnableURL: ((URL) -> Bool)?
    }
}

@MainActor
public class OpenPanel: NSObject {
    private let panel = NSOpenPanel()
    
    @Published public var configuration: Configuration {
        didSet {
            configure(with: configuration)
        }
    }
    
    public init(configuration: Configuration) {
        self.configuration = configuration

        super.init()
                
        configure(with: configuration)
    }
    
    private func configure(with config: Configuration) {
        panel.directoryURL = config.directoryURL
        panel.canChooseFiles = config.canChooseFiles
        panel.canChooseDirectories = config.canChooseDirectories
        panel.canCreateDirectories = config.canCreateDirectories
        panel.allowsMultipleSelection = config.allowsMultipleSelection
        panel.message = config.message
        panel.prompt = config.prompt
        
        if config.validateURL != nil || config.shouldEnableURL != nil {
            panel.delegate = self
        }
    }
    
    private var validateURL: ((URL) throws -> Void)?
    private var shouldEnableURL: ((URL) -> Bool)?
    
    public func present() async throws -> URL {
        let response = await panel.beginSheetModal(for: NSApp.keyWindow ?? NSApp.mainWindow ?? NSWindow())
        
        switch response {
            case .OK:
                guard let selectedURL = panel.url else {
                    throw OpenPanelError.accessDenied
                }
                return selectedURL
            case .cancel:
                throw OpenPanelError.accessCancelled
            default:
                throw OpenPanelError.unknown
        }
    }
}

extension OpenPanel: NSOpenSavePanelDelegate {
    public func panel(_ sender: Any, shouldEnable url: URL) -> Bool {
        shouldEnableURL?(url) ?? true
    }
    
    public func panel(_ sender: Any, validate url: URL) throws {
        try validateURL?(url)
    }
}

public enum OpenPanelError: Error {
    case accessDenied
    case accessCancelled
    case invalidSelection(message: String)
    case unknown
}

#endif
