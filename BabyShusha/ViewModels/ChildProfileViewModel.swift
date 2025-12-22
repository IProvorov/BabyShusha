import Foundation
import SwiftUI
import Combine

@MainActor
class ChildProfileViewModel: ObservableObject {
    @Published var children: [ChildProfile] = []
    @Published var activeChild: ChildProfile?
    @Published var isLoading = false
    
    private let storageService = DataStorageService.shared
    
    init() {
        loadChildren()
    }
    
    // MARK: - Child Management
    
    func loadChildren() {
        isLoading = true
        children = storageService.loadChildProfiles()
        activeChild = storageService.getActiveChildProfile()
        isLoading = false
    }
    
    func addChild(name: String, birthDate: Date, avatarEmoji: String = "👶") {
        let newChild = ChildProfile(
            name: name,
            birthDate: birthDate,
            avatarEmoji: avatarEmoji
        )
        
        storageService.saveChildProfile(newChild)
        setActiveChild(newChild)
        loadChildren()
    }
    
    func updateChild(_ child: ChildProfile) {
        storageService.saveChildProfile(child)
        if child.id == activeChild?.id {
            activeChild = child
        }
        loadChildren()
    }
    
    func deleteChild(_ child: ChildProfile) {
        storageService.deleteChildProfile(child)
        
        if child.id == activeChild?.id {
            if let firstChild = children.first(where: { $0.id != child.id }) {
                setActiveChild(firstChild)
            } else {
                activeChild = nil
                storageService.clearActiveChildProfile()
            }
        }
        
        loadChildren()
    }
    
    func setActiveChild(_ child: ChildProfile) {
        storageService.setActiveChildProfile(child)
        activeChild = child
    }
}
