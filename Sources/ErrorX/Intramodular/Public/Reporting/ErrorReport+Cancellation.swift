//
// Copyright (c) Vatsal Manot
//

/// Cancellation classification for an error report.
extension ErrorReport {
  /// Whether the reported error semantically represents cancellation.
  ///
  /// This recognizes Swift cancellation and the corresponding Foundation URL,
  /// Cocoa, and POSIX cancellation errors. It follows `.translatedFrom`
  /// relationships because a translation preserves the meaning of its source.
  /// It deliberately does not follow ordinary causes or other related failures:
  /// a cleanup failure caused by cancellation is still a failure worth reporting.
  ///
  /// The result describes the error value, not the current task's cancellation
  /// flag. Classify at the catch boundary before hopping to another task.
  public var isCancellation: Bool {
    var pending = [errorTree]

    while let tree = pending.popLast() {
      if tree.root._errorXIsCancellation {
        return true
      }

      pending.append(
        contentsOf: tree.relations.lazy.reversed().compactMap { relation in
          relation.kind == .translatedFrom ? relation.subtree : nil
        }
      )
    }

    return false
  }
}
