//
//  BarChart.swift
//  Previewer
//
//  Created by Umar Haroon on 4/18/21.
//

import SwiftUI

struct BarChart: View {
    var removed: Double
    var totalNodes: Double
    var total: Double {
        Double((totalNodes-removed)/totalNodes) * 100.0
    }
    var body: some View {
        VStack {
            Text("\(total, specifier: "%.f")%")
            Rectangle()
                .fill(Color.blue)
                .frame(width: 20, height: CGFloat(total)*3)
                .cornerRadius(8)
            Text("Total Saved %")
        }
    }
}

struct BarChart_Previews: PreviewProvider {
    static var previews: some View {
        BarChart(removed: 0.0, totalNodes: 100.0)
    }
}
