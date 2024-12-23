//
//  TimerManager.swift
//  CountdownTimerTutorial
//
//  Created by Marlon Raskin on 2024-12-19.
//

import Combine
import Foundation

final class TimerManager: ObservableObject {
	
	enum TimerState {
		case ready
		case running
		case paused
	}
	
	@Published var state: TimerState = .ready
	@Published var timeRemaining: Duration = .seconds(10)
	@Published var duration: Duration = .seconds(10)
	
	private var endDate: Date?
	
	private var timerConnector: AnyCancellable?
	
	private var timerFinishedSubject = PassthroughSubject<Void, Never>()
	var timerFinished: AnyPublisher<Void, Never> {
		timerFinishedSubject.eraseToAnyPublisher()
	}
	
	// MARK: - PUBLIC
	
	func formattedTime() -> String {
		timeRemaining
			.formatted(
				.time(
					pattern: .minuteSecond(
						padMinuteToLength: 2,
						fractionalSecondsLength: 2
					)
				)
			)
	}
	
	// START TIMER
	
	func startTimer() {
		guard state == .ready, duration.components.seconds > 0 else { return }
		endDate = Date().addingTimeInterval(Double(duration.components.seconds))
		connectTimer()
		state = .running
	}
	
	// STOP TIMER
	
	func stopTimer(reset: Bool = false) {
		if state == .running {
			disconnectTimer()
		}
		
		if reset {
			timeRemaining = duration
			endDate = nil
			state = .ready
			print("Timer Reset")
		} else {
			state = .paused
			print("Timer Paused")
		}
	}
	
	// RESUME TIMER
	
	func resumeTimer() {
		guard state == .paused else { return }
		endDate = Date().addingTimeInterval(Double(timeRemaining.components.seconds))
		connectTimer()
		state = .running
	}
	
	// MARK: - PRIVATE
	
	private func connectTimer() {
		timerConnector = Timer.publish(every: 0.01, on: .main, in: .common)
			.autoconnect()
			.sink { [weak self] currentDate in
				guard let self, let endDate, state == .running else { return }
				
				let timeRemaining = endDate.timeIntervalSince(currentDate)
				
				if timeRemaining > 0 {
					self.timeRemaining = .seconds(timeRemaining)
					print("Timer Fired – time remaining: \(timeRemaining)")
				} else {
					stopTimer(reset: true)
					timerFinishedSubject.send()
					print("Timer Finished")
				}
			}
	}
	
	private func disconnectTimer() {
		timerConnector?.cancel()
		timerConnector = nil
		print("Timer Stopped/Paused")
	}
}
