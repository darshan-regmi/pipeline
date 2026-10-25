//
//  RunStatus.swift
//  pipeline
//

import Foundation

/// The lifecycle status returned by the GitHub Actions API.
enum RunStatus: String, Codable, Sendable {
    case queued
    case inProgress = "in_progress"
    case completed
    case waiting
    case requested
    case pending
}
