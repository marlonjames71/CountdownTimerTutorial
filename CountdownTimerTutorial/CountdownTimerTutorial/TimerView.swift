//
//  TimerView.swift
//  CountdownTimerTutorial
//
//  Created by Marlon Raskin on 2024-12-19.
//

import SwiftUI

struct TimerView: View {
	
	init(manager: TimerManager) {
		self.manager = manager
	}
	
	@ObservedObject var manager: TimerManager
	@State private var timerValue = 10
	@State private var isShowingAlert = false
	
	var body: some View {
		VStack(spacing: 40) {
			ZStack {
				Circle()
					.stroke(.secondaryTrim, style: .init(lineWidth: 10, lineCap: .round))
					.padding(5)
				
				Circle()
					.trim(from: 0, to: trimValue)
					.stroke(.trim, style: .init(lineWidth: 10, lineCap: .round))
					.padding(5)
					.rotationEffect(.degrees(-90))
					.animation(
						manager.state == .ready ? nil : .linear(duration: 1),
						value: manager.timeRemaining
					)
					.overlay {
						Text("\(Int(max(0, manager.timeRemaining)))")
							.font(.largeTitle)
							.fontWeight(.bold)
							.monospaced()
							.contentTransition(.numericText(countsDown: true))
							.animation(.easeInOut, value: manager.timeRemaining)
					}
			}
			.frame(width: 150, height: 150)
			.onReceive(manager.timerFinished) { _ in
				isShowingAlert = true
			}
			.alert("🥳 Timer Finished", isPresented: $isShowingAlert) {
				Button("Awesome") {
					isShowingAlert = false
				}
			}
			
			HStack(spacing: 30) {
				stepper(step: 1)
					.tint(.stepButtonColor1)
				stepper(step: 5)
					.tint(.stepButtonColor2)
			}
			.disabled(disableStepper)
			.onChange(of: timerValue) { _, newValue in
				manager.duration = TimeInterval(newValue)
				manager.timeRemaining = TimeInterval(newValue)
			}
		}
	}
	
	private var trimValue: Double {
		manager.timeRemaining > 0 ? manager.timeRemaining / manager.duration : 0
	}
	
	private var disableStepper: Bool {
		manager.state != .ready
	}
	
	private func stepper(step: Int) -> some View {
		VStack {
			Label("\(step)", systemImage: "plusminus")
				.font(.headline)
				.foregroundStyle(.tint)
				.padding(5)
			
			Stepper("") {
				timerValue += step
			} onDecrement: {
				let futureValue = timerValue - step
				guard futureValue > 0 else { return }
				timerValue -= step
			}
			.labelsHidden()
		}
	}
}

#Preview {
	TimerView(manager: TimerManager())
}
