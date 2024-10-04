//
//  AlertCoordinator.swift
//  YandexEats
//
//  Created by Artemiy Zuzin on 03.09.2024.
//

import UIKit

//MARK: - Alert Navigation Core
/// протокол координатора алертов, упрощает их презентацию
protocol AlertNavigationCore {
    func getAlertController(title: String, message: String?, buttons: [AlertButtonModel]) throws -> UIAlertController
    func getAlertController(title: String, message: String?, buttonTittle: String) -> UIAlertController
}

extension AlertNavigationCore {
    /// дефолтная реализация алерта с одной кнопкой, без действия, нужен что бы уведомить пользователя о чем либо
    func getAlertController(title: String, message: String?, buttonTittle: String) -> UIAlertController {
        (try? self.getAlertController(title: title, message: message, buttons: [.init(title: buttonTittle, style: .default)])) ?? .init()
    }
}

//MARK: - Alert Button Model
/// модель кнопки алерта, можно выбрать: заголовок кнопки, стиль, действие(не обязательно)
struct AlertButtonModel {
    var title: String
    var style: UIAlertAction.Style
    var action: (UIAlertAction) -> Void = { _ in }
}

//MARK: - Alert Navigation
final class AlertCoordinator: AlertNavigationCore {
    
//    MARK: - Shared
    private init() { }
    static let shared = AlertCoordinator()
    
//    MARK: - Actions
    /// алерт с любым колличеством кнопок
    func getAlertController(title: String, message: String?, buttons: [AlertButtonModel]) throws -> UIAlertController {
        guard !buttons.isEmpty else { throw AlertNavigationError.zeroButtonsCount }
        
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        for button in buttons {
            controller.addAction(UIAlertAction(
                title: button.title,
                style: button.style,
                handler: button.action
            ))
        }
        
        return controller
    }
    
}
