import SwiftUI
import CoreData

@main
struct MatchMateApp: App {
    
    private let viewModel: MatchesViewModel
    
    init() {
        
        let persistenceController = PersistenceController()
        
        let networkClient = URLSessionNetworkClient()
        
        let randomUserService = DefaultRandomUserService(
            networkClient: networkClient
        )
        
        let localDataSource = CoreDataLocalDataSource(
            context: persistenceController.container.viewContext
        )
        
        let repository = DefaultMatchesRepository(
            remoteService: randomUserService,
            localDataSource: localDataSource
        )
        
        self.viewModel = MatchesViewModel(
            repository: repository
        )
    }
    
    var body: some Scene {
        WindowGroup {
            MatchesView(
                viewModel: viewModel
            )
        }
    }
}
