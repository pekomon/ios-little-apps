//
//  FruitCardView.swift
//  Fructus
//
//  Created by Pekka Rasanen on 9.4.2023.
//

import SwiftUI

struct FruitCardView: View {
    
    // MARK: - Properties
    
    // MARK: - BODY
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // FRUIT: IMAGE
                Image("blueberry")
                    .resizable()
                    .scaledToFit()
                    .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.15), radius: 8, x: 6, y: 8)
                // FRUIT: TITLE
                Text("Blueberry")
                // FRUIT: HEADLINE
                // BUTTON: START
            } //: VSTACK
        } //: ZSTACK
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity
            
        )
        .background(
            LinearGradient(
                gradient: Gradient(
                    colors: [Color("ColorBlueberryLight"), Color("ColorBlueberryDark")]
                ),
                startPoint: .top,
                endPoint: .bottom)
        )
        .cornerRadius(20)
    }
}

// MARK: - Preview

struct FruitCardView_Previews: PreviewProvider {
    static var previews: some View {
        FruitCardView()
            .previewLayout(.fixed(width: 320, height: 640))
    }
}
