//
//  NavProtoApp.swift
//  NavProto
//
//  Created by Gnascimento on 11/03/2026.
//

import NavigatorUI
import SwiftUI

@main
struct NavProtoApp: App {
    private let navigator = Navigator(
        configuration: NavigationConfiguration(
            restorationKey: nil,
            verbosity: .info,
            autoDestinationMode: true
        )
    )

    var body: some Scene {
        WindowGroup {
            ContentView()
                .navigationRoot(navigator)
        }
    }
}
