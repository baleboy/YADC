//
//  SettingsView.swift
//  YADC
//
//  Created by Francesco Balestrieri on 7.12.2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(RecipeStore.self) private var store
    @State private var showResetConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Settings")
                            .font(AppFont.serifHeadline(34))
                            .foregroundStyle(Color("TextPrimary"))
                        Text("Customize your artisan experience.")
                            .font(.subheadline)
                            .foregroundStyle(Color("TextSecondary"))
                    }
                    .padding(.horizontal)

                    // General Settings
                    VStack(alignment: .leading, spacing: 10) {
                        Text("GENERAL SETTINGS")
                            .sectionLabel()
                            .padding(.leading, 20)

                        VStack(spacing: 0) {
                            // Unit system
                            settingRow(
                                icon: "ruler",
                                iconColor: Color("AccentColor"),
                                iconBg: Color("AccentColor").opacity(0.12),
                                title: "Unit System",
                                subtitle: store.settings.unitSystem == .metric ? "Metric (grams)" : "Imperial (ounces)"
                            ) {
                                Picker("", selection: Binding(
                                    get: { store.settings.unitSystem },
                                    set: { store.updateUnitSystem($0) }
                                )) {
                                    Text("Metric").tag(UnitSystem.metric)
                                    Text("Imperial").tag(UnitSystem.imperial)
                                }
                                .pickerStyle(.segmented)
                                .frame(width: 160)
                            }

                            Divider()
                                .padding(.leading, 72)

                            // Dough residue
                            VStack(spacing: 12) {
                                settingRow(
                                    icon: "percent",
                                    iconColor: Color("BrownDark"),
                                    iconBg: Color("TertiaryFixed"),
                                    title: "Dough Residue",
                                    subtitle: "Loss during handling"
                                ) {
                                    Text(store.settings.doughResiduePercentage.percentageFormatted)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(Color("AccentColor"))
                                }

                                Slider(
                                    value: Binding(
                                        get: { store.settings.doughResiduePercentage },
                                        set: { store.updateDoughResidue($0) }
                                    ),
                                    in: 0...10,
                                    step: 0.5
                                )
                                .tint(Color("AccentColor"))
                                .padding(.horizontal, 20)
                                .padding(.bottom, 16)
                            }
                        }
                        .background(Color("FormRowBackground"))
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.default))
                        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 1)
                    }

                    // Account & Data
                    VStack(alignment: .leading, spacing: 10) {
                        Text("DATA")
                            .sectionLabel()
                            .padding(.leading, 20)

                        VStack(spacing: 0) {
                            Button {
                                showResetConfirmation = true
                            } label: {
                                settingRow(
                                    icon: "arrow.counterclockwise",
                                    iconColor: Color("ErrorColor"),
                                    iconBg: Color("ErrorColor").opacity(0.12),
                                    title: "Reset All Data",
                                    subtitle: "This action cannot be undone"
                                ) {
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(Color("TextTertiary"))
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        .background(Color("FormRowBackground"))
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.default))
                        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 1)
                    }

                    // About
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ABOUT")
                            .sectionLabel()
                            .padding(.leading, 20)

                        VStack(spacing: 0) {
                            settingRow(
                                icon: "info.circle",
                                iconColor: Color("BrownMedium"),
                                iconBg: Color("SecondaryContainer"),
                                title: "Version",
                                subtitle: "Autolyse for iOS"
                            ) {
                                Text("1.0.0")
                                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                                    .foregroundStyle(Color("TextSecondary"))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color("SurfaceContainerHighest"))
                                    .clipShape(Capsule())
                            }
                        }
                        .background(Color("FormRowBackground"))
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.default))
                        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 1)
                    }

                    // Footer
                    VStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Color("AccentColor").opacity(0.2))
                            .frame(width: 48, height: 2)
                        Text("Crafted for the modern baker")
                            .font(AppFont.serifItalic(14))
                            .foregroundStyle(Color("TextTertiary").opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
                .padding(.top, 8)
            }
            .background(Color("CreamBackground"))
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Autolyse")
                        .font(AppFont.serifHeadline(18))
                        .foregroundStyle(Color("AccentColor"))
                }
            }
            .alert("Reset All Data?", isPresented: $showResetConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    store.resetToDefaults()
                }
            } message: {
                Text("This will delete all your recipes and reset settings to default values. This action cannot be undone.")
            }
        }
    }

    private func settingRow<Trailing: View>(
        icon: String,
        iconColor: Color,
        iconBg: Color,
        title: String,
        subtitle: String,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(iconColor)
                .frame(width: 40, height: 40)
                .background(iconBg)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color("TextPrimary"))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color("TextSecondary"))
            }

            Spacer()

            trailing()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    SettingsView()
        .environment(RecipeStore())
}
