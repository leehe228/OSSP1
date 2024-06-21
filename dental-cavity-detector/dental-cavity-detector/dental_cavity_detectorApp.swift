//
//  dental_cavity_detectorApp.swift
//  dental-cavity-detector
//
//  Created by Hoeun Lee on 5/21/24.
//

import SwiftUI

@main
struct dental_cavity_detectorApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(viewModel: RootViewModel())
        }
    }
}
