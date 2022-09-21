//
//  ProfileViewModel.swift
//  Messenger
//
//  Created by Ngô Hải Đăng on 03/09/2022.
//

import Foundation
import UIKit

enum ProfileViewModelType {
    case settings, logout, detail
    case switchOption
}

enum ChangeInfoUser {
    case firstName, lastName
}

struct ProfileViewModel {
    let viewModelType: ProfileViewModelType
    let title: String
    let value: String?
    let icon: IconProfile?
    let handler: ((_ value: String) -> Void)?
    var isOn: Bool?
}

struct IconProfile {
    let image: UIImage?
    let color: UIColor?
}

struct Section {
    let title: String
    let options: [ProfileViewModel]
}
