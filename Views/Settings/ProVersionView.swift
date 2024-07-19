import SwiftUI

struct ProVersionView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var proVersionManager = ProVersionManager.shared
    
    var body: some View {
        VStack {
            Text("Erwerbe die Pro-Version")
                .font(.largeTitle)
                .padding()
            
            Text("Vorteile der Pro-Version:")
                .font(.headline)
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("• Detaillierte Analyse")
                Text("• OCR-Erkennung von Kassenbons")
                Text("• Anfügen von Rechnungen")
            }
            .padding()
            
            Spacer()
            
            Button(action: {
                proVersionManager.purchaseProVersion()
            }) {
                Text("Pro-Version für 2,99€ pro Jahr kaufen")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.bottom)
            
            Button(action: {
                proVersionManager.restorePurchases()
            }) {
                Text("Käufe wiederherstellen")
                    .foregroundColor(.blue)
            }
            .padding(.bottom)
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Schließen")
                    .foregroundColor(.red)
            }
            .padding(.bottom)
        }
    }
}

struct ProVersionView_Previews: PreviewProvider {
    static var previews: some View {
        ProVersionView()
    }
}
