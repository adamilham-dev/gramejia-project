//
//  ProfileViewModel.swift
//  gramejia
//
//  Created by Adam on 21/12/24.
//

import Foundation
import Combine

class ProfileViewModel: BaseViewModel {
    
    private var profileUseCase: ProfileUseCaseProtocol = Injection().provideProfileUseCase()
    let typeUser: String = UserDefaultsManager.shared.get(forKey: .userLevel) ?? ""
    let username: String = UserDefaultsManager.shared.get(forKey: .currentUsername) ?? ""
    
    let userProfile = CurrentValueSubject<UserProfileModel?, Never>(nil)
    let isSuccessUpdateUser = CurrentValueSubject<Bool, Never>(false)
    let isSuccessDeleteUser = CurrentValueSubject<Bool, Never>(false)

    func updateUser() {
        isLoading.send(true)
        guard let user = userProfile.value else { return }
        
        if(typeUser == "customer") {
            self.profileUseCase.updateCustomer(username: username, name: user.name, password: user.password, profileImage: user.profileImage)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { [weak self] completion in
                    self?.isLoading.send(false)
                    switch(completion) {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.error.send(error)
                    }
                }, receiveValue: { [weak self] isSuccess in
                    self?.isSuccessUpdateUser.send(isSuccess)
                })
                .store(in: &cancellables)
        } else {
            self.profileUseCase.updateAdmin(username: username, name: user.name, password: user.password, profileImage: user.profileImage)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { [weak self] completion in
                    self?.isLoading.send(false)
                    switch(completion) {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.error.send(error)
                    }
                }, receiveValue: { [weak self] isSuccess in
                    self?.isSuccessUpdateUser.send(isSuccess)
                })
                .store(in: &cancellables)
        }
    }
    
    func deleteAccount(){
        self.profileUseCase.deleteCustomer(username: username)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch(completion) {
                case .finished:
                    break
                case .failure(let error):
                    self?.error.send(error)
                }
            }, receiveValue: { [weak self] isSuccess in
                self?.isSuccessDeleteUser.send(isSuccess)
            })
            .store(in: &cancellables)
    }
    
    func getUser() {
        isLoading.send(true)
        
        if(typeUser == "customer") {
            self.profileUseCase.getCustomer(username: username)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { [weak self] completion in
                    self?.isLoading.send(false)
                    switch(completion) {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.error.send(error)
                    }
                }, receiveValue: { [weak self] customer in
                    let profileImage = self?.userProfile.value?.profileImage
                    let userProfile = UserProfileModel(name: customer?.name ?? "", username: customer?.username ?? "", password: customer?.password ?? "", balance: customer?.balance, profileImage: profileImage ?? customer?.profileImage ?? "")
                    self?.error.send(nil)
                    self?.userProfile.send(userProfile)
                })
                .store(in: &self.cancellables)
        } else {
            self.profileUseCase.getAdmin(username: username)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { [weak self] completion in
                    self?.isLoading.send(false)
                    switch(completion) {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.error.send(error)
                    }
                }, receiveValue: { [weak self] admin in
                    let profileImage = self?.userProfile.value?.profileImage
                    let userProfile = UserProfileModel(name: admin?.name ?? "", username: admin?.name ?? "", password: admin?.password ?? "", profileImage: profileImage ?? admin?.profileImage ?? "")
                    self?.error.send(nil)
                    self?.userProfile.send(userProfile)
                })
                .store(in: &self.cancellables)
        }
    }
    
    func logoutUser() {
        UserDefaultsManager.shared.remove(forKey: .isSignedIn)
        UserDefaultsManager.shared.remove(forKey: .currentUsername)
        UserDefaultsManager.shared.remove(forKey: .currentUserFullname)
        UserDefaultsManager.shared.remove(forKey: .userLevel)
    }
}
