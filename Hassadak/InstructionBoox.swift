//
//  InstructionBox.swift
//  HassadakTesting
//
//  Created by BASHAER AZIZ on 05/09/1446 AH.
//

import SwiftUI

struct InstructionBoox: View {
    @Binding var showInstructions: Bool

    var body: some View {
        VStack {
            Text("How to Use the App")
                .font(.title)
                .fontWeight(.bold)
                .padding()

            Text("1. Point the camera at the vegetables.\n2. Tap the Counter button.\n3. The app will count and display the quantity.")
                .font(.body)
                .padding()

            Button(action: {
                showInstructions = false
            }) {
                Text("Close")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 150)
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding()
        }
        .frame(width: 300, height: 200)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
}
