// ContentRootView.swift
// Root view that gates first-launch PIN setup.
// See ADR-004 §3 for ContentRootView design.

import SwiftUI

struct ContentRootView: View {
    @Environment(\.appEnvironment) private var appEnvironment
    @State private var isPINSetupRequired = false
    @State private var showParentManagement = false
    @State private var showPINEntry = false

    var body: some View {
        ChildRoutineView(
            showParentManagement: $showParentManagement,
            showPINEntry: $showPINEntry
        )
        .fullScreenCover(isPresented: $isPINSetupRequired) {
            PINSetupView(onComplete: {
                isPINSetupRequired = false
            })
        }
        .fullScreenCover(isPresented: $showPINEntry) {
            PINEntryView(
                onSuccess: {
                    showPINEntry = false
                    showParentManagement = true
                },
                onCancel: {
                    showPINEntry = false
                }
            )
        }
        .fullScreenCover(isPresented: $showParentManagement) {
            ParentHomeView(onDismiss: {
                showParentManagement = false
            })
        }
        .task {
            // Use .task instead of .onAppear to run before first render completes.
            // This ensures the fullScreenCover is triggered before any accessibility tree snapshot.
            guard !appEnvironment.skipPINSetup else { return }
            isPINSetupRequired = KeychainStore.shared.loadPINHash() == nil
        }
    }
}
