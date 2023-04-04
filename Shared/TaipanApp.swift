//
//  TaipanApp.swift
//  Shared
//
//  Created by sh95014 on 3/27/22.
//

import SwiftUI

@main
struct TaipanApp: App {
    @StateObject var game = Game()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(game)
        }
    }
}

enum BartyCrouch {
    enum SupportedLanguage: String {
        case chineseTraditional = "zh-Hant"
        case english = "en"
    }
}
