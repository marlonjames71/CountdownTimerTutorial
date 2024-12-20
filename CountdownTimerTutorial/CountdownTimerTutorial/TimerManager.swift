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
	@Published var timeRemaining: TimeInterval = 10
	@Published var duration: TimeInterval = 10
	
	private var endDate: Date?
	
	private var timerConnector: AnyCancellable?
	
	private var timerFinishedSubject = PassthroughSubject<Void, Never>()
	var timerFinished: AnyPublisher<Void, Never> {
		timerFinishedSubject.eraseToAnyPublisher()
	}
	
	// MARK: - PUBLIC
	
	// START TIMER
	
	func startTimer() {
		guard state == .ready, duration > 0 else { return }
		endDate = Date().addingTimeInterval(duration)
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
		endDate = Date().addingTimeInterval(timeRemaining)
		connectTimer()
		state = .running
	}
	
	// MARK: - PRIVATE
	
	private func connectTimer() {
		timerConnector = Timer.publish(every: 0.1, on: .main, in: .common)
			.autoconnect()
			.sink { [weak self] currentDate in
				guard let self, let endDate, state == .running else { return }
				
				let timeRemaining = endDate.timeIntervalSince(currentDate)
				
				if timeRemaining > 0 {
					self.timeRemaining = timeRemaining
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
