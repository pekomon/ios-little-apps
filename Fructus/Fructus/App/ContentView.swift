//
//  ContentView.swift
//  Fructus
//
//  Created by Pekka Rasanen on 4.4.2023.
//

import SwiftUI

struct ContentView: View {

    // MARK: - PROPERTIES
    var fruits: [Fruit] = fruitsData
    
    // MARK: - BO
    var body: some View {
        NavigationView {
            List {
                ForEach(fruits.shuffled()) { item in
                    FruitRowView(fruit: item)
                        .padding(.vertical, 4)
                }
            }
            .navigationTitle("Fruits")
        } //: NAVIGATION
    }
}

// MARK: - PREVIEW
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(fruits: fruitsData)
    }
}
