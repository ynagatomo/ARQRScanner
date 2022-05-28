//
//  arqrscannerApp.swift
//  arqrscanner
//
//  Created by Yasuhito Nagatomo on 2022/05/26.
//

import SwiftUI

@main
struct ARQRScannerApp: App {
    var body: some Scene {
        WindowGroup {
            ScanView()
                .ignoresSafeArea()
        }
    }
}
