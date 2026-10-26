//
//  TimeInterval+Format.swift
//  pipeline
//

import Foundation

extension TimeInterval {
    /// A compact, localized duration such as "3 min, 42 sec".
    var abbreviatedDuration: String {
        Duration.seconds(self).formatted(
            .units(
                allowed: [.hours, .minutes, .seconds],
                width: .abbreviated,
                maximumUnitCount: 2
            )
        )
    }
}

extension Date {
    /// A localized relative description such as "3 minutes ago".
    var relativeDescription: String {
        formatted(.relative(presentation: .named))
    }
}
