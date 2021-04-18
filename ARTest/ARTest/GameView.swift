//
//  GameView.swift
//  ARTest
//
//  Created by Umar Haroon on 4/9/21.
//

import SwiftUI

struct GameView: View {
    var body: some View {
        ZStack {    
            VStack() {
                Text("Vaccines remaining")
                Text("15")
                    .padding()
            }
            .padding()
            .background(BlurView())
            .cornerRadius(24)
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
struct BlurView: UIViewRepresentable {
    typealias UIViewType = UIVisualEffectView
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: .systemMaterial)
    }
}

