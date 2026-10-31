//
//  RunStateTests.swift
//  pipelineTests
//

import Testing
@testable import pipeline

@MainActor
struct RunStateTests {
    @Test func completedSuccessMapsToSuccess() {
        #expect(RunState(status: .completed, conclusion: .success) == .success)
    }

    @Test func completedFailureMapsToFailure() {
        #expect(RunState(status: .completed, conclusion: .failure) == .failure)
        #expect(RunState(status: .completed, conclusion: .actionRequired) == .failure)
        #expect(RunState(status: .completed, conclusion: .startupFailure) == .failure)
    }

    @Test func completedCancelledMapsToCancelled() {
        #expect(RunState(status: .completed, conclusion: .cancelled) == .cancelled)
    }

    @Test func completedTimedOutMapsToTimedOut() {
        #expect(RunState(status: .completed, conclusion: .timedOut) == .timedOut)
    }

    @Test func activeStatusesMapToRunningOrQueued() {
        #expect(RunState(status: .inProgress, conclusion: nil) == .running)
        #expect(RunState(status: .queued, conclusion: nil) == .queued)
        #expect(RunState(status: .waiting, conclusion: nil) == .queued)
        #expect(RunState(status: .requested, conclusion: nil) == .queued)
        #expect(RunState(status: .pending, conclusion: nil) == .queued)
    }

    @Test func completedWithoutConclusionMapsToUnknown() {
        #expect(RunState(status: .completed, conclusion: nil) == .unknown)
        #expect(RunState(status: .completed, conclusion: .stale) == .unknown)
    }

    @Test func stateGroupingHelpersAreConsistent() {
        #expect(RunState.failure.isFailure)
        #expect(RunState.timedOut.isFailure)
        #expect(!RunState.success.isFailure)

        #expect(RunState.running.isActive)
        #expect(RunState.queued.isActive)
        #expect(!RunState.success.isActive)

        #expect(RunState.success.isHealthy)
        #expect(RunState.skipped.isHealthy)
        #expect(RunState.neutral.isHealthy)
        #expect(!RunState.failure.isHealthy)
    }
}
