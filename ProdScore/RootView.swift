import SwiftUI

struct RootView: View {
    @State private var hasCompletedOnboarding = DataStore.profile.hasCompletedOnboarding

    var body: some View {
        if hasCompletedOnboarding {
            ProductListView()
        } else {
            OnboardingView {
                withAnimation {
                    hasCompletedOnboarding = true
                }
            }
        }
    }
}
