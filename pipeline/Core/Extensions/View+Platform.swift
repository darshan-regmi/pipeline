//
//  View+Platform.swift
//  pipeline
//

import SwiftUI

extension View {
    /// Applies keyboard behavior that only exists on iOS while keeping the
    /// shared SwiftUI code compiling on macOS.
    @ViewBuilder
    func pipelineKeyboardBehavior() -> some View {
        #if os(iOS)
        self
            .scrollDismissesKeyboard(.interactively)
            .textInputAutocapitalization(.never)
            .keyboardType(.asciiCapable)
        #else
        self
            .autocorrectionDisabled()
        #endif
    }

    @ViewBuilder
    func pipelineNavigationBarInline() -> some View {
        #if os(iOS)
        self.navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }
}
