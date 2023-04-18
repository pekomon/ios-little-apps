//
//  ExternalWebLinkView.swift
//  Africa
//
//  Created by Pekka Rasanen on 18.4.2023.
//

import SwiftUI

struct ExternalWebLinkView: View {
    
    let animal: Animal
    var body: some View {
        GroupBox {
            HStack {
                Image(systemName: "globe")
                Text("Wikipedia")
                Spacer()
                
                Group {
                    Link(
                        animal.name,
                        destination: (URL(string: animal.link) ?? URL(string: "https://wikipedia.com"))!
                    )
                    Image(systemName: "arrow.up.right.square")
                }
                .foregroundColor(.accentColor)
            } //: HSTACK
        } //: BOX
    }
}

struct ExternalWebLinkView_Previews: PreviewProvider {
    
    static let animals: [Animal] = Bundle.main.decode("animals.json")
    
    static var previews: some View {
        ExternalWebLinkView(animal: animals[6])
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
