//
//  ResultsView.swift
//  Previewer
//
//  Created by Umar Haroon on 4/17/21.
//

import SwiftUI

struct ResultsView: View {
    @State var vaccines: Int = 0
    @State var isComplete: Bool = true
    @State var quarantined: Int = 0
    @State var isQuarantined: Bool = false
    var body: some View {
        VStack(spacing: 0) {
            if isQuarantined {
                Text("Quarantined: \(quarantined)")
                    .foregroundColor(.primary)

            } else {
            Text("Vaccines left: \(vaccines)")
                .foregroundColor(.primary)
            }
            if isComplete {
                Text("Outbreak Complete!")
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(.bottom, 4)
                Button("View Results", action: {})
                    .padding(.bottom, 4)
            }
        }
        .padding(.horizontal, 70)
        .padding(.vertical, 8)
        .background(
            ZStack {
                VisualEffectView(style: UIBlurEffect.Style.regular)
                Capsule(style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                    .foregroundColor(.secondary)
            }
        )
    }
    func updateView(vacc: Int, isQ: Bool, q: Int, isDone: Bool) {
        
    }
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView()
    }
}
