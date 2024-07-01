//
// Copyright (c) Vatsal Manot
//

import SwiftUI
import Swallow
import SwallowMacrosClient
import XCTest

final class ManagedActorMacroTests: XCTestCase {
    func testHashableExistentialInit() async throws {
        let actor = Barrz()
        
        XCTAssert(type(of: actor)._managedActorInitializationOptions == [.serializedExecution])
        
        let result = try await actor.foo(1)
        
        XCTAssert(result == 69)
    }
}

@ManagedActor(.serializedExecution)
@dynamicMemberLookup
public final class Barrz {
    var x: Int = 0
    
    func foo$(
        _ int: Int
    ) async throws -> Int? {

    }
    
    func bar$(
        _ int: Int
    ) async throws -> Int {
        69
    }
}

@ManagedActor(.serializedExecution)
@dynamicMemberLookup
public final class PlaygroundContentSession {
    static var effectSpecification: some EffectSpecification {
        For(.run)
            .retryPolicy(.delay(0.2), maxRetryCount: 2)
        
        OnChange($content) {
            Perform(.run)
        }
        
        OnPerform($uploadToServer)
            .reset($content)
        
        Log(.run)
        
        During([.run, .uploadToServer]) {
            Invariant(readyToRun == true)
        }
        
        During([.run, .uploadToServer]) {
            EnforceInvariant {
                Invariant(state.contains(.runningAndUploading))
            }
        }
        
        ReportProgress(.doManyTasks) {
            ProgressUnit(.foo)
            ProgressUnit(.bar)
        }
    }
    
    func doManyTasks$() async {
        await foo()
        await bar()
    }
    
    func foo$() async {
        
    }
    
    func bar$() async {
        
    }
    
    enum StateFlag {
        case runningAndUploading
    }

    @Published var readyToRun: Bool
    @Published var state: Set<StateFlag> = []
    
    @Published var content: String
    
    var x: Int = 0
    
    func run$() async throws {
        state.insert(.runningAndUploading)
        defer {
            state.remove(.runningAndUploading)
        }
    }
    
    func uploadToServer$() async throws {
        
    }
}

struct SessionView: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var session: PlaygroundContentSession
    
    @State var isRunning: Bool = false
    @State var isUploading: Bool = false
    
    var body: some View {
        ProgressView(session.progress(for: .doManyTasks))
    }
}
