//
//  Glob.swift
//
//  Created by John Holdsworth on 03/12/2023.
//  Repo: https://github.com/johnno1962/Popen
//
//  List of files matching pattern from shell.
//

import Foundation

public class Glob: Sequence, IteratorProtocol {
    var pglob = glob_t()
    var index = 0

    public init?(pattern: String, flags: CInt = 0) {
        if glob(pattern, flags, nil, &pglob) != 0 {
            return nil
        }
    }

    public func next() -> String? {
        defer { index += 1 }
        #if !os(Linux)
        guard index < pglob.gl_matchc else { return nil }
        #endif
        return pglob.gl_pathv[index]
            .flatMap { String(cString: $0) }
    }

    deinit {
        globfree(&pglob)
    }
}
