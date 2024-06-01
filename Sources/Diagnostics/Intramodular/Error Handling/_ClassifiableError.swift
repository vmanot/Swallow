//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol _ClassifiableError {
    associatedtype Classification: _ElementGrouping where Classification.Element: ErrorClassificationProtocol
    
    var errorClassification: Classification { get }
}

public protocol ErrorClassificationProtocol {
    
}

public enum GeneralErrorClassification: String, ErrorClassificationProtocol {
    case network // Timeout, Connectivity, DNS
    case database // Query, Connection, Schema
    case fileSystem // NotFound, Permission, DiskSpace
    case authorization // Authentication, Access, TokenExpiration
    case validation // Input, Data, Boundary
    case serialization // Encoding, Decoding, Format
    case userInterface // Layout, Interaction, Animation
    case concurrent // RaceCondition, Deadlock, Synchronization
    case resource // Memory, CPU, I/O
    case thirdPartyLibrary // Integration, Compatibility, Versioning
    case hardware // Device, Sensor, Peripheral
    case operatingSystem // System, Updates, Compatibility
    case security // Encryption, Certificate, Vulnerability
    case payment // Transaction, Refund, Subscription
    case analytics // Tracking, Reporting, Event
    case communication // Messaging, Notification, Chat
    case configuration // Setup, Environment, Infrastructure
    case stateManagement // Store, Cache, Session
    case internationalization // Subcategories: Localization, Formatting, Currency
    case deprecation // Subcategories: Obsolescence, Removal, Replacement
    case performance // Subcategories: Optimization, Bottleneck, Profiling
    case testing // Subcategories: Unit, Integration, System
    case unsupportedFeature // Subcategories: Compatibility, Limitations, Platform
    case interoperability // Subcategories: Communication, Contract, DataSharing
    case documentation // Subcategories: Outdated, Inaccurate, Incomplete
}
