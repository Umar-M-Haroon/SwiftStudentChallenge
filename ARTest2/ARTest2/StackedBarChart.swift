//
//  StackedBarChart.swift
//  Previewer
//
//  Created by Umar Haroon on 4/18/21.
//

import SwiftUI
struct BarChartData {
    var totalNodes: Int
    var quarantined: Int
    var vaccinated: Int
    var infected: Int
    var nonInfected: Int {
        totalNodes - quarantined - vaccinated - infected
    }
}
struct StackedBarChart: View {
    var chartData = BarChartData(totalNodes: 100, quarantined: 10, vaccinated: 20, infected: 10)
    var body: some View {
        HStack(spacing: 10) {
            VStack(spacing: 0) {
                HStack {
                    if chartData.infected != 0 {
                        Text("\(chartData.infected)")
                            .frame(width: 30)
                            .padding(.trailing, 4)
                    }
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 20, height: CGFloat(chartData.infected) * 3)
                }
                HStack {
                    if chartData.quarantined != 0 {
                        Text("\(chartData.quarantined)")
                            .frame(width: 30)
                            .padding(.trailing, 4)
                    }
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: 20, height: CGFloat(chartData.quarantined) * 3)
                }
                HStack {
                    if chartData.vaccinated != 0 {
                    Text("\(chartData.vaccinated)")
                        .frame(width: 30)
                        .padding(.trailing, 4)
                    }
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: 20, height: CGFloat(chartData.vaccinated) * 3)
                }
                if chartData.nonInfected != chartData.totalNodes {
                    HStack {
                        Text("\(chartData.nonInfected)")
                            .frame(width: 30)
                            .padding(.trailing, 4)
                        Rectangle()
                            .fill(Color.gray)
                            .frame(width: 20, height: CGFloat(chartData.nonInfected) * 3)
                    }
                } else {
                    VStack {
                        Text("\(chartData.nonInfected)")
                            .frame(width: 30)
                            .padding(.trailing, 4)
                        Rectangle()
                            .fill(Color.gray)
                            .frame(width: 20, height: CGFloat(chartData.nonInfected) * 3)
                            .cornerRadius(8)
                    }
                }
            }
            Legend()
        }
    }
}
struct Charts: View {
    var chartData: BarChartData
    
    var body: some View {
        HStack(alignment: .bottom, spacing: nil) {
            StackedBarChart(chartData: chartData)
            BarChart(removed: Double(chartData.totalNodes - chartData.nonInfected), totalNodes: Double(chartData.totalNodes))
                .frame(alignment: .bottom)
        }
        .frame(alignment: .bottom)
    }
}
    
struct Charts_Previews: PreviewProvider {
    static var previews: some View {
        Charts(chartData: BarChartData(totalNodes: 100, quarantined: 0, vaccinated: 0, infected: 0))
    }
}

struct Legend: View {
    var body: some View {
        VStack {
//            HStack {
//                RoundedRectangle(cornerRadius: 4)
//                    .frame(width: 25, height: 25, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
//                    .foregroundColor(Color.yellow)
//
//                Text("Anti-Vax")
//                    .frame(width: 125)
//            }
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .frame(width: 25, height: 25, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .foregroundColor(Color.blue)
                
                Text("Vaccinated")
                    .frame(width: 125, alignment: Alignment.leading)
                    .multilineTextAlignment(.leading)
            }
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .frame(width: 25, height: 25, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .foregroundColor(Color.green)
                
                Text("Quarantined")
                    .frame(width: 125, alignment: Alignment.leading)
            }
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .frame(width: 25, height: 25, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .foregroundColor(Color.gray)
                
                Text("Non-Infected")
                    .frame(width: 125, alignment: Alignment.leading)
            }
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .frame(width: 25, height: 25, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .foregroundColor(Color.red)
                
                Text("Infected")
                    .frame(width: 125, alignment: Alignment.leading)
            }
        }
    }
}

struct StackedBarChart_Previews: PreviewProvider {
    static var previews: some View {
        StackedBarChart()
    }
}
