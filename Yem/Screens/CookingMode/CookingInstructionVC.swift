//
//  InstructionVC.swift
//  Yem
//
//  Created by Adam Zapiór on 22/08/2024.
//

// ViewControler used in CookingModeVC as UIPageViewController

import SnapKit
import UIKit

class CookingInstructionVC: UIViewController {
    var instruction: InstructionModel
    var pageIndex: Int = 0

    private let ingredients: [IngredientModel]
    private let instructionTextView = UITextView()

    init(instruction: InstructionModel, ingredients: [IngredientModel]) {
        self.instruction = instruction
        self.ingredients = ingredients
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        instructionTextView.textColor = UIColor.ui.primaryText

        updateTextColors()

        instructionTextView.isEditable = false
        instructionTextView.isSelectable = false
        instructionTextView.font = UIFont.preferredFont(forTextStyle: .title1)
        instructionTextView.textAlignment = .center
        instructionTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionTextView)

        instructionTextView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.leading.equalTo(view.snp.leading).offset(16)
            make.trailing.equalTo(view.snp.trailing).inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        centerTextVertically()
    }

    private func formatTextWithIngredients(
        _ text: String,
        highlightColor: UIColor,
        defaultTextColor: UIColor
    ) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)

        // Set the default color for the entire text
        attributedString.addAttribute(
            .foregroundColor,
            value: defaultTextColor,
            range: NSRange(location: 0, length: attributedString.length)
        )

        // Highlight ingredients
        for ingredient in ingredients {
            let ingredientName = ingredient.name
            let ingredientRange = (text as NSString).range(
                of: ingredientName,
                options: .caseInsensitive
            )

            if ingredientRange.location != NSNotFound {
                attributedString.addAttribute(
                    .foregroundColor,
                    value: highlightColor,
                    range: ingredientRange
                )
            }
        }

        // Regular expression for time expressions (e.g., "1 minute", "10 minutes", "1 hour", "2 hours")
        let timePattern = "\\b(\\d+)\\s*(minute|min|minutes|hour|hours)\\b"
        let regex = try? NSRegularExpression(
            pattern: timePattern,
            options: .caseInsensitive
        )

        // Highlight time expressions
        if let regex = regex {
            let matches = regex.matches(
                in: text,
                options: [],
                range: NSRange(location: 0, length: text.utf16.count)
            )
            for match in matches {
                attributedString.addAttribute(
                    .foregroundColor,
                    value: highlightColor,
                    range: match.range
                )
            }
        }

        return attributedString
    }

    private func updateTextColors() {
        let highlightColor = UIColor.ui.theme
        let defaultTextColor = UIColor.ui.primaryText

        let formattedText = formatTextWithIngredients(
            instruction.text,
            highlightColor: highlightColor,
            defaultTextColor: defaultTextColor
        )
        instructionTextView.attributedText = formattedText
    }

    private func centerTextVertically() {
        let textViewSize = instructionTextView.bounds.size
        let contentSize = instructionTextView.sizeThatFits(textViewSize)
        let topInset = max(0, (textViewSize.height - contentSize.height) / 2)
        instructionTextView.contentInset.top = topInset
    }
}
