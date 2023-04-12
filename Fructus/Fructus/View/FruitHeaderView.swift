//
//  FruitHeaderView.swift
//  Fructus
//
//  Created by Pekka Rasanen on 12.4.2023.
//

import SwiftUI

struct FruitHeaderView: View {
    // MARK: - PROPERTIES
    var fruit: Fruit
    
    @State private var isAnimatingImage: Bool = false
    
    // MARK: - BODY
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: fruit.gradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(fruit.image)
                .resizable()
                .scaledToFit()
                .shadow(
                    color: Color(red: 0, green: 0, blue: 0, opacity: 0.15),
                    radius: 8,
                    x: 2,
                    y: 2
                )
                .padding(.vertical, 20)
                .scaleEffect(isAnimatingImage ? 1.0 : 0.6)
            
        } //: ZSTACK
        .frame(height: 440)
        .onAppear() {
            withAnimation(.easeInOut(duration: 0.5)) {
                isAnimatingImage = true
            }
        }
    }
}

// MARK: - PREVIEW
struct FruitHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        FruitHeaderView(fruit: fruitsData[4])
            .previewLayout(.fixed(width: 375, height: 440))
    }
}
