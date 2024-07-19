import SwiftUI

struct ProVersionView: View {
    var body: some View {
        VStack {
            Text("Pro Version Kaufen")
                .font(.largeTitle)
                .padding()
            // Fügen Sie hier Ihre Pro-Version-Kaufansicht hinzu
            Spacer()
        }
        .navigationBarTitle("Pro Version", displayMode: .inline)
    }
}

struct ProVersionView_Previews: PreviewProvider {
    static var previews: some View {
        ProVersionView()
    }
}
