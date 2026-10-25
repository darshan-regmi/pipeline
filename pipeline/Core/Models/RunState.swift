//
//  RunState.swift
//  pipeline
//

import Foundation

/// A UI-friendly state derived from GitHub's separate `status` and
/// `conclusion` fields.
///
/// Keeping this mapping in one place means every screen describes a run the
/// same way and new statuses only need to be handled once.
enum RunState: String, CaseIterable, Sendable {
    case success
    case failure
    case running
    case queued
    case cancelled
    case skipped
    case neutral
    case timedOut
    case unknown

    init(status: RunStatus, conclusion: RunConclusion?) {
        switch status {
        case .queued, .waiting, .requested, .pending:
            self = .queued
        case .inProgress:
            self = .running
        case .completed:
            switch conclusion {
            case .success:
                self = .success
            case .failure, .actionRequired, .startupFailure:
                self = .failure
            case .cancelled:
                self = .cancelled
            case .skipped:
                self = .skipped
            case .neutral:
                self = .neutral
            case .timedOut:
                self = .timedOut
            case .stale, .none:
                self = .unknown
            }
        }
    }

    var title: String {
        switch self {
        case .success: String(localized: "Success", comment: "Workflow run status")
        case .failure: String(localized: "Failure", comment: "Workflow run status")
        case .running: String(localized: "Running", comment: "Workflow run status")
        case .queued: String(localized: "Queued", comment: "Workflow run status")
        case .cancelled: String(localized: "Cancelled", comment: "Workflow run status")
        case .skipped: String(localized: "Skipped", comment: "Workflow run status")
        case .neutral: String(localized: "Neutral", comment: "Workflow run status")
        case .timedOut: String(localized: "Timed out", comment: "Workflow run status")
        case .unknown: String(localized: "Unknown", comment: "Workflow run status")
        }
    }

    var symbolName: String {
        switch self {
        case .success: "checkmark"
        case .failure: "xmark"
        case .running: "arrow.triangle.2.circlepath"
        case .queued: "clock"
        case .cancelled: "minus"
        case .skipped: "forward.end"
        case .neutral: "equal"
        case .timedOut: "hourglass"
        case .unknown: "questionmark"
        }
    }

    var isFailure: Bool {
        self == .failure || self == .timedOut
    }

    var isActive: Bool {
        self == .running || self == .queued
    }

    var isHealthy: Bool {
        self == .success || self == .skipped || self == .neutral
    }
}
