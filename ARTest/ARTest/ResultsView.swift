//
//  ResultsView.swift
//  Previewer
//
//  Created by Umar Haroon on 4/17/21.
//

import SwiftUI
import Combine
struct ResultsView: View {
    @ObservedObject var model: ResultModel
    @State var shouldShowCharts: Bool = false
    var body: some View {
        VStack(spacing: 0) {
            if model.isQuarantined {
                Text("Quarantined: \(model.quarantined)")
                    .foregroundColor(.primary)

            } else {
                Text("Vaccines left: \(model.vaccines)")
                .foregroundColor(.primary)
            }
            if model.isComplete {
                Text("Outbreak Complete!")
                    .font(.caption)
                    .padding(.bottom, 4)
                Button(action: {
                    withAnimation {
                        shouldShowCharts.toggle()
                    }
                    
                }, label: {
                    if shouldShowCharts {
                        Text("Hide Results")
                    } else {
                        Text("View Results")
                    }
                })
                .padding(.bottom, 4)
            }
            if shouldShowCharts {
                Charts(chartData: BarChartData(totalNodes: model.total, quarantined: model.quarantined, vaccinated: model.vaccines, infected: model.infected))
            }
        }
        .padding(.horizontal, 70)
        .padding(.vertical, 8)
        .background(
            ZStack {
                VisualEffectView(style: UIBlurEffect.Style.regular)
                    .cornerRadius(20)
//                Capsule(style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
//                    .foregroundColor(.secondary)
            }
        )
    }
}

//struct ResultsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ResultsView(vaccines: 0, isComplete: false, quarantined: 0, isQuarantined: false)
//    }
//}
class ResultModel: ObservableObject {
    @Published var vaccines: Int
    @Published var isComplete: Bool
    @Published var quarantined: Int
    @Published var isQuarantined: Bool
    @Published var total: Int
    @Published var infected: Int
    init(v: Int, c: Bool, q: Int, isQ: Bool, t: Int, i: Int) {
        self.vaccines = v
        self.isComplete = c
        self.quarantined = q
        self.isQuarantined = isQ
        self.total = t
        self.infected = i
    }
}
