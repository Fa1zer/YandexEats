//
//  LocalizatoinKey.swift
//  YandexEats
//
//  Created by Artemiy Zuzin on 03.09.2024.
//

import Foundation

/// протокол менеджера локазизации, нужен для удобной локализации через enum case
protocol LocalizationManager {
    func value(_ comment: String?) -> String
    func value(with argument: Int, comment: String?) -> String
}

/// менеджер лакализации через перечисление
enum LocalizatoinKey: String, LocalizationManager {
    case cartTitle = "cart.title"
    case cartButtonTitle = "cart.button.title"
    case cartSubtitle = "cart.subtitle"
    case cartDeleteAlertTitle = "cart.delete.alert.title"
    case cartDeleteAlertYes = "cart.delete.alert.yes"
    case cartDeleteAlertNo = "cart.delete.alert.no"
    case cartError = "cart.error"
    case cartSucces = "cart.succes"
    case cartBackAlert = "cart.back.alert"
    case cartNoItems = "cart.no.items"
    
    /// получить занчение по текущему ключу
    func value(_ comment: String? = nil) -> String {
        NSLocalizedString(self.rawValue, comment: comment ?? .init())
    }
    
    /// получить занчаение локализации в нужном формате по ключу и аргументу Integer
    func value(with argument: Int, comment: String? = nil) -> String {
        .localizedStringWithFormat(self.value(), argument)
    }
}
