//
//  ViewController.swift
//  CountdownTimerTutorial
//
//  Created by Marlon Raskin on 2024-12-16.
//

import Combine
import SwiftUI
import UIKit

class ViewController: UIViewController {
	
	private let timerManager = TimerManager()
	private var cancellable: AnyCancellable?

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .backgroundPrimary
		
		view.addSubview(contentContainer)
		contentContainer.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			contentContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			contentContainer.leadingAnchor
				.constraint(equalTo: view.leadingAnchor),
			contentContainer.trailingAnchor
				.constraint(equalTo: view.trailingAnchor)
		])
		
		// Button UI Updates
		
		cancellable = timerManager.$state
			.sink { [weak self] state in
				guard let self else { return }
				
				let (title, bgColor): (String, UIColor) = switch state {
				case .ready:
					("Start", .trim)
				case .running:
					("Pause", UIColor(.red))
				case .paused:
					("Resume", .trim)
				}
				
				let startStopTitleColor: UIColor = state == .running ? .lightTextPrimary : .buttonText
				
				startStopButton.configuration?.attributedTitle = headlineStyledString(forTitle: title)
				startStopButton.configuration?.baseBackgroundColor = bgColor
				startStopButton.configuration?.baseForegroundColor = startStopTitleColor
				
				resetButton.isEnabled = state != .running
			}
	}
	
	private lazy var timerView: UIView = {
		let timerView = TimerView(manager: timerManager)
		let hostingController = UIHostingController(rootView: timerView)
		hostingController.view.backgroundColor = .clear
		hostingController.sizingOptions = .intrinsicContentSize
		addChild(hostingController)
		hostingController.didMove(toParent: self)
		return hostingController.view
	}()
	
	private lazy var contentContainer: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [timerView, buttonContainer])
		stack.axis = .vertical
		stack.spacing = Layout.contentStackSpacing
		stack.isLayoutMarginsRelativeArrangement = true
		stack.layoutMargins = .init(
			top: 0,
			left: Layout.contentStackPadding,
			bottom: 0,
			right: Layout.contentStackPadding
		)
		return stack
	}()
	
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
			self?.timerManager.stopTimer(reset: true)
		})
		return button
	}()
	
	private lazy var startStopButton: UIButton = {
		let config = buttonConfig(title: "Start", titleColor: .buttonText, bgColor: .trim)
		let button = UIButton(configuration: config, primaryAction: .init { [weak self] _ in
			guard let self else { return }
			switch timerManager.state {
			case .ready:
				timerManager.startTimer()
			case .running:
				timerManager.stopTimer()
			case .paused:
				timerManager.resumeTimer()
			}
		})
		return button
	}()
}

extension ViewController {
	enum Layout {
		static let buttonStackSpacing: Double = 10
		static let contentStackPadding: Double = 24
		static let contentStackSpacing: Double = 50
	}
}

#Preview {
	ViewController()
}
