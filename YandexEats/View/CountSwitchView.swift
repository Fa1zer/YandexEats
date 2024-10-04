//
//  CountSwitchView.swift
//  YandexEats
//
//  Created by Artemiy Zuzin on 03.09.2024.
//

import UIKit
import SnapKit

//MARK: - Delegate
/// протокол делегата  блока с выбором колличества продукта
protocol CountSwitchViewDelegate {
    func updateCountSwitchView(_ view: CountSwitchViewProtocol) -> Int
    func didTapChangeButton(_ view: CountSwitchViewProtocol, count: Int)
}

//MARK: - Count Switch View Delegate
/// протокол  блока с выбором колличества продукта
protocol CountSwitchViewProtocol: UIView {
    var delegate: CountSwitchViewDelegate? { get set }
    func update()
}

/// блок с выбором колличества продукта
final class CountSwitchView: UIView, CountSwitchViewProtocol {
    
//    MARK: - Properties
    /// делегат
    var delegate: (any CountSwitchViewDelegate)? {
        didSet {
            self.count = self.delegate?.updateCountSwitchView(self) ?? .zero
        }
    }
    /// колличество продукта
    private var count = Int.zero {
        didSet {
            self.countLabel.text = String(self.count)
        }
    }
    /// лейбл колличества
    private let countLabel: UILabel = {
        let view = UILabel()
        
        view.text = "0"
        view.font = .systemFont(ofSize: 16)
        view.textColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    /// кнопка "–"
    private lazy var minusButton: UIButton = {
        let view = UIButton()
        
        view.setTitle("–", for: .normal)
        view.titleLabel?.font = .systemFont(ofSize: 16)
        view.setTitleColor(.black, for: .normal)
        view.addTarget(self, action: #selector(self.didTapMinusButton), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    /// кнопка "+"
    private lazy var plusButton: UIButton = {
        let view = UIButton()
        
        view.setTitle("+", for: .normal)
        view.titleLabel?.font = .systemFont(ofSize: 16)
        view.setTitleColor(.black, for: .normal)
        view.addTarget(self, action: #selector(self.didTapPlusButton), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
//    MARK: - Life Cycle
    /// загрузка интерфейса
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupViews()
    }
    
//    MARK: - Setup View
    /// расположение интерфейса
    func setupViews() {
        self.backgroundColor = #colorLiteral(red: 0.9688869119, green: 0.96553725, blue: 0.9593732953, alpha: 1)
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 8
        self.addSubview(self.minusButton)
        self.addSubview(self.countLabel)
        self.addSubview(self.plusButton)
        self.minusButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        self.countLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        self.plusButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
    }
    
    /// обновление данных
    func update() {
        self.count = self.delegate?.updateCountSwitchView(self) ?? .zero
    }
    
//    MARK: - Action
    /// обработка нажатия на минус
    @objc private func didTapMinusButton() {
        guard self.count > .zero else { return }
        
        HapticFeedbackGenerator.selection.prepare()
        self.count -= 1
        self.delegate?.didTapChangeButton(self, count: self.count)
    }
    
    /// обработка нажатия на плюс
    @objc private func didTapPlusButton() {
        guard self.count < 99 else { return }
        
        HapticFeedbackGenerator.selection.prepare()
        self.count += 1
        self.delegate?.didTapChangeButton(self, count: self.count)
    }
    
}
