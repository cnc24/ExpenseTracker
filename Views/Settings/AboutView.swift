import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack {
            Text("Expense Tracker")
                .font(.largeTitle)
                .padding()
            Text("Version 1.0.0")
                .padding()
            Spacer()
            Text("© 2024 Your Company Name")
                .padding()
        }
        .navigationBarTitle("Über die App", displayMode: .inline)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
