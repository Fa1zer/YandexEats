//
//  ImageLoader.swift
//  YandexEats
//
//  Created by Artemiy Zuzin on 03.09.2024.
//

import UIKit

//MARK: - Protocol
/// протокол загрузчика картинок
protocol ImageLoaderProtocol {
    func load(from url: String) async throws -> Data
}

//MARK: - Mock
/// загрузчик картинок mock
final class ImageLoaderMock: ImageLoaderProtocol {
    
    private init() { }
    static let shared = ImageLoaderMock()
    
//    MARK: - Load
    /// загрузка картинок, по факту просто берет из xcassets, т.к. mock
    func load(from url: String) async throws -> Data {
        guard let data = UIImage(named: url)?.pngData() else { throw ImageLoaderError.notFound }
        
        return data
    }
    
}
