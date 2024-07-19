import SwiftUI

struct SignInView: View {
    var body: some View {
        VStack {
            Text("Sign In / Sign Up")
                .font(.largeTitle)
                .padding()
            // Fügen Sie hier Ihre Anmelde-/Registrierungsansicht hinzu
            Spacer()
        }
        .navigationBarTitle("Anmelden", displayMode: .inline)
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
