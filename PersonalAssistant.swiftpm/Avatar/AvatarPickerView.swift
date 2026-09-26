// Avatar/AvatarPickerView.swift
// Identity switcher sheet for Maya and Saar.
// Per V3 §Avatar/AvatarPickerView.swift blueprint.

import SwiftUI

struct AvatarPickerView: View {
    @Binding var selectedIdentity: AvatarIdentity
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(AvatarIdentity.allCases, id: \.self) { identity in
                    Button {
                        selectedIdentity = identity
                        dismiss()
                    } label: {
                        HStack(spacing: AppTheme.Spacing.md) {
                            AvatarView(state: .idle, identity: identity, size: 50)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(identity.rawValue)
                                    .font(.headline)
                                    .foregroundStyle(Color.primary)
                                Text(identity == .maya ? "Creative and intuitive assistant" : "Analytical and structured assistant")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.secondary)
                            }

                            Spacer()

                            if selectedIdentity == identity {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.accentColor)
                                    .font(.headline)
                            }
                        }
                        .padding(.vertical, AppTheme.Spacing.xs)
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Choose Identity")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
