//
//  FeedbackGenerator.swift
//  YandexEats
//
//  Created by Artemiy Zuzin on 03.09.2024.
//

import UIKit

/// протокол удобного гератора вибрации телефона
protocol FeedbackGenerator {
    func prepare()
}

/// удобный генератор вибрации, можно выбрать силу вибрации через enum case
enum HapticFeedbackGenerator: FeedbackGenerator {
    case error, success, warning, light, medium, heavy, selection
    
    /// производит вибрацию с выбранной силой
    func prepare() {
        switch self {
        case .error:
            let generator = UINotificationFeedbackGenerator()
            
            generator.notificationOccurred(.error)
        case .success:
            let generator = UINotificationFeedbackGenerator()
            
            generator.notificationOccurred(.success)
        case .warning:
            let generator = UINotificationFeedbackGenerator()
            
            generator.notificationOccurred(.warning)
        case .light:
            let generator = UIImpactFeedbackGenerator(style: .light)
            
            generator.impactOccurred()
        case .medium:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            
            generator.impactOccurred()
        case .heavy:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            
            generator.impactOccurred()
        default:
            let generator = UISelectionFeedbackGenerator()
            
            generator.selectionChanged()
        }
    }
}
