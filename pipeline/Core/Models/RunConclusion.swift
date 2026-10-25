//
//  RunConclusion.swift
//  pipeline
//

import Foundation

/// The result of a completed workflow run.
///
/// GitHub sends `null` while a run is still active, which is why this value is
/// optional everywhere it is used.
enum RunConclusion: String, Codable, Sendable {
    case success
    case failure
    case neutral
    case cancelled
    case skipped
    case timedOut = "timed_out"
    case actionRequired = "action_required"
    case stale
    case startupFailure = "startup_failure"
}
