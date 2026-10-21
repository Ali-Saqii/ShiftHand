//
//  ContentView.swift
//  shifthand
//
//  Initial root placeholder conforming to ShiftHand Design Tokens.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.shBackgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: SHMetrics.spacingMD) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.shPrimaryTeal)

                Text("ShiftHand")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.shTextPrimary)

                Text("Volunteer Shift Manager")
                    .font(.subheadline)
                    .foregroundStyle(Color.shTextSecondary)
            }
            .padding()
        }
    }
}

#Preview("Light Mode") {
    ContentView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    ContentView()
        .preferredColorScheme(.dark)
}
