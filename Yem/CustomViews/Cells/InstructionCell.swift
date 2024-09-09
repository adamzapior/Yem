//
//  InstructionCell.swift
//  Yem
//
//  Created by Adam Zapiór on 19/01/2024.
//

import UIKit
import Combine


final class InstructionCell: UITableViewCell {
    static let id: String = "InstructionCell"
        
    private let content: UIView = {
        let view = UIView()
        view.backgroundColor = .ui.primaryContainer
        view.layer.cornerRadius = 20
        return view
    }()
    
    private let indexLabel = TextLabel(
        fontStyle: .body,
        fontWeight: .semibold,
        textColor: .ui.secondaryText,
        textAlignment: .natural
    )
    
    private let textTextView = TextLabel(
        fontStyle: .body,
        fontWeight: .regular,
        textColor: .ui.primaryText,
        textAlignment: .natural
    )

    private let moveIcon: IconImage = {
        let icon = IconImage(
            systemImage: "text.justify",
            color: .ui.secondaryText,
            textStyle: .body
        )
        return icon
    }()
    
    private lazy var trashIcon: IconImage = {
        let icon = IconImage(
            systemImage: "trash",
            color: .red,
            textStyle: .body
        )
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapButtonAction)
        )
        icon.addGestureRecognizer(tapGesture)
        icon.isUserInteractionEnabled = true
        return icon
    }()
    
    // MARK: Combine properties
        
    /// Publisher store
    var eventPublisher: AnyPublisher<Void, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    /// Publisher
    private let eventSubject = PassthroughSubject<Void, Never>()
    
    var cancellables = Set<AnyCancellable>()
    
    // MARK: Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.isUserInteractionEnabled = true
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.removeAll()
    }
    
    // MARK: UI Setup
    
    func configure(with model: InstructionModel) {
        indexLabel.text = model.index.description
        textTextView.text = model.text
    }
    
    private func setupUI() {
        addSubview(content)
        
        content.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.left.right.equalToSuperview().inset(18)
            make.height.greaterThanOrEqualTo(60)
        }
        content.addSubview(trashIcon)
        content.addSubview(moveIcon)
        content.addSubview(indexLabel)
        content.addSubview(textTextView)
        
        moveIcon.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.leading.equalToSuperview().offset(18)
        }
        
        trashIcon.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-18)
            make.height.equalTo(18.VAdapted)
            make.width.equalTo(22.HAdapted)
        }
        
        indexLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.centerX.equalToSuperview()
        }
        
        textTextView.snp.makeConstraints { make in
            make.top.equalTo(indexLabel.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().offset(-12)
        }
    }

    @objc func didTapButtonAction() {
        eventSubject.send(())
    }
}
