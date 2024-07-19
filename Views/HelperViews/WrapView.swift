import SwiftUI

struct WrapView<Data: RandomAccessCollection, ID: Hashable, Content: View>: View where Data.Element: Equatable {
    var data: Data
    var id: KeyPath<Data.Element, ID>
    var content: (Data.Element) -> Content

    @State private var totalHeight = CGFloat.infinity

    var body: some View {
        GeometryReader { geo in
            self.generateContent(in: geo)
        }
    }

    private func generateContent(in geo: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(self.data, id: self.id) { item in
                self.content(item)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > geo.size.width) {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if item == self.data.first {
                            width = 0
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { _ in
                        let result = height
                        if item == self.data.first {
                            height = 0
                        }
                        return result
                    })
            }
        }
    }
}

struct WrapView_Previews: PreviewProvider {
    static var previews: some View {
        WrapView(data: ["Tag1", "Tag2", "Tag3"], id: \.self) { tag in
            Text(tag)
                .padding(8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
}
