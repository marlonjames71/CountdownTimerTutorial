//
//  SegmentedStepper.swift
//  CountdownTimerTutorial
//
//  Created by Marlon Raskin on 2024-12-22.
//

import SwiftUI

struct SegmentedStepper<N: Numeric & Hashable>: View {
	@State private var selection: N?
	
	private let steps: [N]
	private var onIncrement: (N) -> Void
	private var onDecrement: (N) -> Void
	
	@Namespace private var animation
	
	init(
		steps: N...,
		onIncrement: @escaping (N) -> Void,
		onDecrement: @escaping (N) -> Void
	) {
		self.steps = steps
		self.onIncrement = onIncrement
		self.onDecrement = onDecrement
	}
	
	var body: some View {
		HStack(spacing: 3) {
			Button {
				onDecrement(selection ?? 0)
			} label: {
				Image(systemName: "minus")
					.frame(width: 60, height: 50)
					.font(.headline)
					.background(Color.selection)
					.clipShape(
						.rect(
							topLeadingRadius: 30,
							bottomLeadingRadius: 30,
							bottomTrailingRadius: 8,
							topTrailingRadius: 8,
							style: .continuous
						)
					)
			}
			.tint(.trim)
			
			ForEach(steps, id: \.self) { step in
				Button {
					selection = step
				} label: {
					Text("\(step)s")
				}
				.frame(height: 50)
				.frame(maxWidth: .infinity)
				.font(.headline)
				.background(
					(isSelectedStep(step: step) ? Color.selection : Color.clear)
						.matchedGeometryEffect(id: step, in: animation)
				)
				.clipShape(RoundedRectangle(cornerRadius: 8))
				.tint(.buttonTextInverted)
			}
			
			Button {
				onIncrement(selection ?? 0)
			} label: {
				Image(systemName: "plus")
					.frame(width: 60, height: 50)
					.font(.headline)
					.background(Color.selection)
					.clipShape(
						.rect(
							topLeadingRadius: 8,
							bottomLeadingRadius: 8,
							bottomTrailingRadius: 30,
							topTrailingRadius: 30,
							style: .continuous
						)
					)
			}
			.tint(.trim)
		}
		.padding(4)
		.clipShape(Capsule())
		.overlay {
			Capsule()
				.stroke(Color.selection, style: .init(lineWidth: 3))
		}
	}
	
	private func isSelectedStep(step: N) -> Bool {
		selection == step
	}
}

#Preview {
	@Previewable @State var number = 0
	
	ZStack {
		Color.backgroundPrimary.ignoresSafeArea()
		
		
		VStack(spacing: 50) {
			Text("\(number)")
				.font(.largeTitle)
			
			SegmentedStepper(steps: 1, 5, 10, 20) { num in
				number += num
			} onDecrement: { num in
				number -= num
			}
		}
		.padding(.horizontal, 20)
	}
}
