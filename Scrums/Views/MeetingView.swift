//
//  MeetingView.swift
//  Scrums
//
//  Created by Javier Galera Robles on 10/12/21.
//

import SwiftUI
import AVFoundation

struct MeetingView: View {
    @StateObject var scrumTimer = ScrumTimer()
    @StateObject var speechRecognizer = SpeechRecognizer()
    
    @State private var isRecording = false
    @Binding var scrum: DailyScrum
    
    private var player: AVPlayer { AVPlayer.sharedDingPlayer }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16.0)
                .fill(scrum.theme.mainColor)
            VStack {
                MeetingHeaderView(secondsElapsed: scrumTimer.secondsElapsed, secondsRemaining: scrumTimer.secondsRemaining, theme: scrum.theme)
                MeetingTimerView(speakers: scrumTimer.speakers, theme: scrum.theme, isRecording: isRecording)
                MeetingFooterView(speakers: scrumTimer.speakers, skipAction: scrumTimer.skipSpeaker)
            }
        }
        .padding()
        .foregroundColor(scrum.theme.accentColor)
        .onAppear {
            scrumTimer.reset(lengthInMinutes: scrum.lengthInMinutes, attendees: scrum.attendees)
            scrumTimer.speakerChangedAction = {
                player.seek(to: .zero)
                player.play()
            }
            speechRecognizer.reset()
            speechRecognizer.transcribe()
            isRecording = true
            scrumTimer.startScrum()
        }
        .onDisappear {
            let newHistory = History(attendees: scrum.attendees, lengthInMinutes: scrum.timer.secondsElapsed / 60, transcript: speechRecognizer.transcript)
            scrum.history.insert(newHistory, at: 0)
            speechRecognizer.stopTranscribing()
            isRecording = false
            scrumTimer.stopScrum()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MeetingHeaderView: View {
    let secondsElapsed: Int
    let secondsRemaining: Int
    let theme: Theme
    
    private var totalSeconds: Int {
        secondsElapsed + secondsRemaining
    }
    
    private var progress: Double {
        guard totalSeconds > 0 else { return 1 }
        return Double(secondsElapsed) / Double(totalSeconds)
    }
    
    private var minutesRemaining: Int {
        secondsRemaining / 60
    }
    
    var body: some View {
        VStack {
            ProgressView(value: 5, total: 15)
                .progressViewStyle(ScrumProgressViewStyle(theme: theme))
            HStack {
                VStack(alignment: .leading) {
                    Text("Seconds elapsed")
                        .font(.caption)
                    Label("\(secondsElapsed)", systemImage: "hourglass.bottomhalf.fill")
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Seconds remaining")
                        .font(.caption)
                    Label("\(secondsRemaining)", systemImage: "hourglass.tophalf.fill")
                        .labelStyle(.trailingIcon)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Time remaining")
            .accessibilityValue("\(minutesRemaining) minutes")
        }
        .padding([.top, .horizontal])
    }
}

struct MeetingFooterView: View {
    let speakers: [ScrumTimer.Speaker]
    
    var skipAction: ()->Void
    
    private var speakerNumber: Int? {
        guard let index = speakers.firstIndex(where: { !$0.isCompleted }) else { return nil }
        return index + 1
    }
    
    private var isLastSpeaker: Bool {
        return speakers.dropLast().allSatisfy { $0.isCompleted }
    }
    
    private var speakerText: String {
        guard let speakerNumber = speakerNumber else { return "No more speakers" }
        return "Speaker \(speakerNumber) of \(speakers.count)"
    }
    
    var body: some View {
        VStack {
            HStack {
                if isLastSpeaker {
                    Text("Last Speaker")
                } else {
                    Text(speakerText)
                    Spacer()
                    Button(action: skipAction) {
                        Image(systemName: "forward.fill")
                    }
                    .accessibilityLabel("Next speaker")
                }
            }
        }
        .padding([.bottom, .horizontal])
    }
}

struct MeetingTimerView: View {
    let speakers: [ScrumTimer.Speaker]
    let theme: Theme
    let isRecording: Bool
    
    private var currentSpeaker: String {
        speakers.first(where: { !$0.isCompleted })?.name ?? "Someone"
    }
    
    var body: some View {
        Circle()
            .strokeBorder(lineWidth: 24)
            .overlay {
                VStack {
                    Text(currentSpeaker)
                        .font(.title)
                    Text("is speaking")
                    Image(systemName: isRecording ? "mic" : "mic.slash")
                        .font(.title)
                        .padding(.top)
                }
                .accessibilityElement(children: .combine)
                .foregroundStyle(theme.accentColor)
            }
            .overlay {
                ForEach(speakers) { speaker in
                    if speaker.isCompleted, let index = speakers.firstIndex(where: { $0.id == speaker.id }) {
                        SpeakerArc(speakerIndex: index, totalSpeakers: speakers.count)
                            .rotation(Angle(degrees: -90))
                            .stroke(theme.mainColor, lineWidth: 12)
                    }
                }
            }
            .padding(.horizontal)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MeetingView(scrum: .constant(DailyScrum.sampleData[0]))
    }
}
