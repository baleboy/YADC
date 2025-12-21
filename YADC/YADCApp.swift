//
//  YADCApp.swift
//  YADC
//
//  Created by Francesco Balestrieri on 7.12.2025.
//

import SwiftUI

@main
struct YADCApp: App {
    @State private var store = RecipeStore()
    @State private var journalStore = JournalStore()

    init() {
        configureAppearance()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .environment(journalStore)
                .preferredColorScheme(.light)
                .tint(Color("AccentColor"))
                .accentColor(Color("AccentColor"))
        }
    }

    private func configureAppearance() {
        // Background colors
        UITableView.appearance().backgroundColor = UIColor(Color("CreamBackground"))
        UITableView.appearance().separatorColor = UIColor(Color("TextTertiary"))
        UITableView.appearance().backgroundView = nil

        // Form/List row backgrounds - more aggressive approach
        UITableViewCell.appearance().backgroundColor = UIColor(Color("FormRowBackground"))
        UITableViewCell.appearance().contentView.backgroundColor = UIColor(Color("FormRowBackground"))

        // Set background for all UIViews in cells
        if let cellContentViewClass = NSClassFromString("UITableViewCellContentView") as? UIView.Type {
            cellContentViewClass.appearance().backgroundColor = UIColor(Color("FormRowBackground"))
        }

        // Navigation bar
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(Color("CreamBackground"))
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor(Color("TextPrimary"))]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color("TextPrimary"))]
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().compactScrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().tintColor = UIColor(Color("AccentColor"))

        // Tab bar
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Color("CreamBackground"))

        // Selected tab item
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color("AccentColor"))
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Color("AccentColor"))]

        // Unselected tab item - use medium brown instead of gray
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color("TextSecondary"))
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Color("TextSecondary"))]

        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBar.appearance().tintColor = UIColor(Color("AccentColor"))
        UITabBar.appearance().unselectedItemTintColor = UIColor(Color("TextSecondary"))

        // Labels - more aggressive text color setting
        UILabel.appearance().textColor = UIColor(Color("TextPrimary"))

        // Buttons
        UIButton.appearance().tintColor = UIColor(Color("AccentColor"))

        // Segmented control - completely custom styling
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color("AccentColor"))
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color("TextPrimary"))], for: .normal)
        UISegmentedControl.appearance().backgroundColor = UIColor(Color("CreamBackground"))
        UISegmentedControl.appearance().layer.borderWidth = 1
        UISegmentedControl.appearance().layer.borderColor = UIColor(Color("TextTertiary")).cgColor

        // Steppers - customize the background
        UIStepper.appearance().tintColor = UIColor(Color("AccentColor"))
        UIStepper.appearance().backgroundColor = UIColor(Color("FormRowBackground"))

        // Switches (toggles)
        UISwitch.appearance().onTintColor = UIColor(Color("AccentColor"))

        // Sliders - customize track colors
        UISlider.appearance().minimumTrackTintColor = UIColor(Color("AccentColor"))
        UISlider.appearance().maximumTrackTintColor = UIColor(Color("TextTertiary"))
        UISlider.appearance().thumbTintColor = UIColor(Color("FormRowBackground"))

        // Text Fields - customize background and text color
        UITextField.appearance().backgroundColor = UIColor(Color("FormRowBackground"))
        UITextField.appearance().textColor = UIColor(Color("TextPrimary"))
        UITextField.appearance().tintColor = UIColor(Color("AccentColor"))

        // Text Field border style
        UITextField.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).layer.borderColor = UIColor(Color("TextTertiary")).cgColor
        UITextField.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).layer.borderWidth = 1
        UITextField.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).layer.cornerRadius = 8
    }
}
