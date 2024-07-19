import Foundation
import Combine

class UserViewModel: ObservableObject {
    @Published var isProUser: Bool
    private var cancellables = Set<AnyCancellable>()

    init(isProUser: Bool = false) {
        self.isProUser = isProUser
        setupBindings()
    }

    private func setupBindings() {
        ProVersionManager.shared.$isProVersionUnlocked
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isPro in
                self?.isProUser = isPro
            }
            .store(in: &cancellables)
    }
}
