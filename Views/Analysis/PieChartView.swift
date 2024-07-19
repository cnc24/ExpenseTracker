import SwiftUI

struct PieChartView: View {
    var data: [Double]
    var labels: [String]
    var title: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .padding()
            
            GeometryReader { geometry in
                ZStack {
                    ForEach(0..<self.data.count) { index in
                        self.slice(index: index, in: geometry.size)
                    }
                }
            }
        }
    }
    
    private func slice(index: Int, in size: CGSize) -> some View {
        let radius = min(size.width, size.height) / 2
        let startAngle = self.angle(for: index)
        let endAngle = self.angle(for: index + 1)
        
        return Path { path in
            path.move(to: CGPoint(x: size.width / 2, y: size.height / 2))
            path.addArc(center: CGPoint(x: size.width / 2, y: size.height / 2),
                        radius: radius,
                        startAngle: startAngle,
                        endAngle: endAngle,
                        clockwise: false)
        }
        .fill(self.color(for: index))
    }
    
    private func angle(for index: Int) -> Angle {
        let total = data.reduce(0, +)
        let value = data.prefix(index).reduce(0, +)
        return .degrees(360 * value / total)
    }
    
    private func color(for index: Int) -> Color {
        let colors: [Color] = [.red, .green, .blue, .orange, .purple, .yellow, .pink, .gray]
        return colors[index % colors.count]
    }
}

struct PieChartView_Previews: PreviewProvider {
    static var previews: some View {
        PieChartView(data: [100, 200, 300, 400], labels: ["A", "B", "C", "D"], title: "Demo")
            .frame(height: 300)
    }
}
