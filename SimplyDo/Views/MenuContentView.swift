//
//  MenuContentView.swift
//  SimplyDo
//
//  Created by Oleksandr
//
import SwiftUI

struct MenuContentView: View {
    var body: some View {
        Text("simply do")
            .padding()
        Button("quit"){
            NSApplication.shared.terminate(nil)
        }
        .padding()

    }
}

#Preview {
    MenuContentView()
}
