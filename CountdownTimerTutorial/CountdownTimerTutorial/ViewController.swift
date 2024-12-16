//
//  ViewController.swift
//  CountdownTimerTutorial
//
//  Created by Marlon Raskin on 2024-12-16.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .backgroundPrimary
		
		view.addSubview(buttonContainer)
		buttonContainer.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			buttonContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			buttonContainer.leadingAnchor
				.constraint(equalTo: view.leadingAnchor, constant: Layout.contentStackPadding),
			buttonContainer.trailingAnchor
				.constraint(equalTo: view.trailingAnchor, constant: -Layout.contentStackPadding)
		])
		
		// Button UI Updates
	}
	
	private lazy var buttonContainer: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [resetButton, startStopButton])
		stack.distribution = .fillEqually
		stack.spacing = Layout.buttonStackSpacing
		return stack
	}()
	
	private func headlineStyledString(forTitle title: String) -> AttributedString {
		let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .headline)
		let font = UIFont(descriptor: descriptor, size: .zero)
		var string = AttributedString(title)
		string.font = font
		return string
	}
	
	private func buttonConfig(
		title: String,
		titleColor: UIColor,
		bgColor: UIColor
	) -> UIButton.Configuration {
		var config = UIButton.Configuration.filled()
		config.attributedTitle = headlineStyledString(forTitle: title)
		config.baseBackgroundColor = bgColor
		config.baseForegroundColor = titleColor
		config.buttonSize = .large
		config.cornerStyle = .large
		return config
	}
	
	private lazy var resetButton: UIButton = {
		let config = buttonConfig(title: "Reset", titleColor: .buttonText, bgColor: UIColor(.cyan))
		let button = UIButton(configuration: config, primaryAction: .init { [weak self] _ in
			print("Reset Button Tapped")
		})
		return button
	}()
	
	private lazy var startStopButton: UIButton = {
		let config = buttonConfig(title: "Start", titleColor: .buttonText, bgColor: .trim)
		let button = UIButton(configuration: config, primaryAction: .init { [weak self] _ in
			print("Start/Stop Button Tapped")
		})
		return button
	}()
}

extension ViewController {
	enum Layout {
		static let buttonStackSpacing: Double = 10
		static let contentStackPadding: Double = 24
	}
}
