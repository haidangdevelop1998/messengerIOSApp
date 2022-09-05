//
//  ProfileViewModel.swift
//  Messenger
//
//  Created by Ngô Hải Đăng on 03/09/2022.
//

import Foundation

enum ProfileViewModelType {
    case info, logout
}

struct ProfileViewModel {
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() -> Void)?
}
