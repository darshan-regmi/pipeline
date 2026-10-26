//
//  RelativeTimeText.swift
//  pipeline
//

import SwiftUI

/// A self-updating relative timestamp such as "3 minutes ago".
struct RelativeTimeText: View {
    let date: Date

    var body: some View {
        TimelineView(.periodic(from: .now, by: 30)) { _ in
            Text(date, format: .relative(presentation: .named))
        }
    }
}
