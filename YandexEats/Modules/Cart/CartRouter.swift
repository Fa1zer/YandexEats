//
//  CartRouter.swift
//  YandexEats
//
//  Created by Artemiy Zuzin on 03.09.2024.
//

import UIKit

//MARK: - Protocol
/// протокол роутера корзины, нуен для взаимодействия с координаторами
protocol CartRouterProtocol {
    var alertCoordinator: AlertNavigationCore { get set }
    var navigationCoordinator: NavigationCore { get set }
    
    func getAlert(title: String, message: String?, buttonTitle: String) -> UIAlertController
    func getAlert(title: String, message: String?, buttons: [AlertButtonModel]) throws -> UIAlertController
}

//MARK: - Router
/// роутер корзины
final class CartRouter: CartRouterProtocol {
    
    /// координатор алертов
    var alertCoordinator: any AlertNavigationCore
    /// главный координатор в приложение
    var navigationCoordinator: any NavigationCore
    
    init(alertCoordinator: any AlertNavigationCore, navigationCoordinator: any NavigationCore) {
        self.alertCoordinator = alertCoordinator
        self.navigationCoordinator = navigationCoordinator
    }
    
    /// вызов алерта с одной кнопкой
    func getAlert(title: String, message: String? = nil, buttonTitle: String) -> UIAlertController {
        self.alertCoordinator.getAlertController(title: title, message: message, buttonTittle: buttonTitle)
    }
    
    /// вызов алерта с несколькими кнопками
    func getAlert(title: String, message: String? = nil, buttons: [AlertButtonModel]) throws -> UIAlertController {
        try self.alertCoordinator.getAlertController(title: title, message: message, buttons: buttons)
    }
    
}
