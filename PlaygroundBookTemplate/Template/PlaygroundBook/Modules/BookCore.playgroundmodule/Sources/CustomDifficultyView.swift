//
//  CustomDifficultyView.swift
//  ARTest
//
//  Created by Umar Haroon on 4/17/21.
//

import SwiftUI
import Combine
struct CustomDifficultyView: View {
    @State var infectionRate: Double = 0.7
    @State var numberOfVaccines: Int = 3
    @State var numberOfStartingInfected: Int = 1
    @State var numberOfAntiVax: Int = 0
    @State var numberOfNodes: Int = 30
    
    var antiVaxLabel = "Anti-Vaxxers"
    var vaccinesLabel = "Vaccines available"
    var startedInfectedLabel = "Starting Infected"
    var numberNodesLabel = "Number of Nodes"
    var outputAction: ((Int, Difficulty) -> Void)
    var hasError: Bool {
        withAnimation {
            numberOfVaccines >= numberOfNodes ||
                numberOfStartingInfected >= numberOfNodes ||
                numberOfAntiVax >= (numberOfNodes - numberOfVaccines)
        }
    }
    var body: some View {
        VStack {
            
            Text("Infection Rate: \(infectionRate, specifier: "%0.2f")")
            Slider(value: $infectionRate, in: 0.1...1.0) {
                Text("Infection Rate")
            }
            .padding(.horizontal, 70)
            NumberStepper(value: $numberOfVaccines, min: 1, max: 50, textInfo: vaccinesLabel)
            NumberStepper(value: $numberOfStartingInfected, min: 1, max: 50, textInfo: startedInfectedLabel)
            NumberStepper(value: $numberOfAntiVax, min: 0, max: 50, textInfo: antiVaxLabel)
            NumberStepper(value: $numberOfNodes, min: 10, max: 50, textInfo: numberNodesLabel)
            Button(action: {
                outputAction(numberOfNodes, Difficulty(difficultyLevel: .custom(numberOfStartingInfected, infectionRate, numberOfVaccines, numberOfAntiVax)))
            }, label: {
                Text("Save")
                    .padding(.horizontal, 40)
                    .padding(.vertical, 10)
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 8).foregroundColor(.blue)
                    )
                    .frame(height: !hasError ? nil : 0)
            })
        }
        .background(
            ZStack {
                VisualEffectView(style: .regular)
                    .cornerRadius(8)
                    .padding(.vertical, -20)
            }
        )
        .padding()
    }
}
struct NumberStepper: View {
    @Binding var value: Int
    var min: Int = 10
    var max: Int = 50
    var textInfo: String
    var body: some View {
        VStack {
            Text(textInfo)
//            Stepper(value: <#T##Binding<Strideable>#>, in: ClosedRange<Strideable>, label: <#T##() -> _#>)
            Stepper(value: $value, in: min...max, label: { Text("\(value)")})
        }
        .padding(.horizontal, 20)
    }
}
struct CustomDifficultyView_Previews: PreviewProvider {
    static var previews: some View {
        CustomDifficultyView(numberOfVaccines: 0, numberOfStartingInfected: 0, numberOfAntiVax: 0, outputAction: { _,_  in })
    }
}
struct VisualEffectView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    
    func makeUIView(context: UIViewRepresentableContext<VisualEffectView>) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blurView, at: 0)
        NSLayoutConstraint.activate([
            blurView.heightAnchor.constraint(equalTo: view.heightAnchor),
            blurView.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
        return view
    }
    
    func updateUIView(_ uiView: UIView,
                      context: UIViewRepresentableContext<VisualEffectView>) {
        
    }
}
