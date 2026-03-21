//
//  YADCApp.swift
//  YADC
//
//  Created by Francesco Balestrieri on 7.12.2025.
//

import SwiftUI

@main
struct YADCApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var store = RecipeStore()
    @State private var journalStore = JournalStore()
    @State private var navigationManager = NavigationManager.shared

    init() {
        configureAppearance()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .environment(journalStore)
                .environment(navigationManager)
                .preferredColorScheme(.light)
                .tint(Color("AccentColor"))
                .accentColor(Color("AccentColor"))
        }
    }

    private func configureAppearance() {
        // Background colors
        UITableView.appearance().backgroundColor = UIColor(Color("CreamBackground"))
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().backgroundView = nil

        // Form/List row backgrounds
        UITableViewCell.appearance().backgroundColor = UIColor(Color("FormRowBackground"))
        UITableViewCell.appearance().contentView.backgroundColor = UIColor(Color("FormRowBackground"))

        if let cellContentViewClass = NSClassFromString("UITableViewCellContentView") as? UIView.Type {
            cellContentViewClass.appearance().backgroundColor = UIColor(Color("FormRowBackground"))
        }

        // Navigation bar — translucent with frosted glass
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        navBarAppearance.backgroundColor = UIColor(Color("CreamBackground").opacity(0.8))
        navBarAppearance.backgroundEffect = UIBlurEffect(style: .systemThinMaterial)
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor(Color("TextPrimary"))]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color("TextPrimary"))]
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().compactScrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().tintColor = UIColor(Color("AccentColor"))

        // Tab bar — translucent with frosted glass
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithTransparentBackground()
        tabBarAppearance.backgroundColor = UIColor(Color("CreamBackground").opacity(0.8))
        tabBarAppearance.backgroundEffect = UIBlurEffect(style: .systemThinMaterial)

        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color("AccentColor"))
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Color("AccentColor"))]
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color("TextSecondary")).withAlphaComponent(0.4)
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Color("TextSecondary")).withAlphaComponent(0.4)]

        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBar.appearance().tintColor = UIColor(Color("AccentColor"))
        UITabBar.appearance().unselectedItemTintColor = UIColor(Color("TextSecondary")).withAlphaComponent(0.4)

        // Labels
        UILabel.appearance().textColor = UIColor(Color("TextPrimary"))

        // Buttons
        UIButton.appearance().tintColor = UIColor(Color("AccentColor"))

        // Segmented control — no borders, warm styling
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color("AccentColor"))
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color("TextPrimary"))], for: .normal)
        UISegmentedControl.appearance().backgroundColor = UIColor(Color("SecondaryContainer"))

        // Steppers
        UIStepper.appearance().tintColor = UIColor(Color("AccentColor"))
        UIStepper.appearance().backgroundColor = UIColor(Color("SecondaryContainer"))

        // Switches
        UISwitch.appearance().onTintColor = UIColor(Color("AccentColor"))

        // Sliders
        UISlider.appearance().minimumTrackTintColor = UIColor(Color("AccentColor"))
        UISlider.appearance().maximumTrackTintColor = UIColor(Color("SurfaceContainerHighest"))

        // Text Fields — no borders, tonal background
        UITextField.appearance().backgroundColor = UIColor(Color("SurfaceContainerHigh"))
        UITextField.appearance().textColor = UIColor(Color("TextPrimary"))
        UITextField.appearance().tintColor = UIColor(Color("AccentColor"))
    }
}
