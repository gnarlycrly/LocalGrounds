//
//  NotesListView.swift
//  LocalGrounds
//
//  Created by Carly Jazwin on 11/05/25.
//

//shows all the notes the users made with search and filters
import SwiftUI
import Combine

struct NotesListView: View {
    @EnvironmentObject var notesVM: NotesViewModel
    @EnvironmentObject var cafeListVM: CafeListViewModel
    @State private var searchText: String = ""

    enum SentimentFilter: String, CaseIterable, Identifiable { //sentiment filters for the ai analysis
        case all
        case positive
        case neutral
        case negative
        
        var id: String { rawValue }

        var label: String { //labels for the analysis
            switch self {
            case .all: return "All"
            case .positive: return "Positive"
            case .neutral: return "Neutral"
            case .negative: return "Negative"
            }
        }
    }

    @State private var selectedSentiment: SentimentFilter = .all //which sentiment is being filtered
    
    private var filteredNotes: [CafeNoteEntry] {
        let all = notesVM.allNotesSorted()
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let textFiltered: [CafeNoteEntry] //filters by the search text
        
        if trimmed.isEmpty {
            textFiltered = all
        } else {
            textFiltered = all.filter { note in
                note.cafeName.localizedCaseInsensitiveContains(trimmed) ||
                note.text.localizedCaseInsensitiveContains(trimmed)
            }
        }
        let sentimentFiltered: [CafeNoteEntry]
        
        switch selectedSentiment {//switches for the sentiment filters
        case .all:
            sentimentFiltered = textFiltered
        case .positive, .neutral, .negative:
            sentimentFiltered = textFiltered.filter { note in
                guard let s = note.aiSentiment?.lowercased() else { return false }
                return s == selectedSentiment.rawValue
            }
        }

        return sentimentFiltered
    }

    var body: some View {
        Image("localgroundslogo")
            .resizable()
            .scaledToFit()
            .frame(width: 220)
            .padding(.top, 8)
        
        VStack {
            
            if !notesVM.allNotesSorted().isEmpty { //if theres no notes dont show the filters
                Picker("Sentiment", selection: $selectedSentiment) {
                    ForEach(SentimentFilter.allCases) { filter in
                        Text(filter.label).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
            }

            if filteredNotes.isEmpty { //message if no notes
                if notesVM.allNotesSorted().isEmpty {
                    VStack(spacing: 8) {
                        Text("No notes yet")
                            .font(.headline)
                        Text("Add a note!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding(.top, 40)

                    Spacer()
                } else {
                    VStack(spacing: 8) {
                        Text("No matches")
                            .font(.headline)
                        Text("Use a different filter or search")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)

                    Spacer()
                }
            } else { //this catches if the user has notes but none with the selected filter
                List {
                    ForEach(filteredNotes) { note in //trying to find the cafe for the note
                        if let cafe = cafeListVM.cafes.first(where: { $0.id == note.cafeID }) {
                            NavigationLink(destination: CafeDetailView(cafe: cafe)) {
                                NoteRowView(note: note)
                                    .environmentObject(notesVM)
                            }
                        } else {
                            NoteRowView(note: note)
                                .environmentObject(notesVM)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let note = filteredNotes[index]
                            notesVM.delete(note)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .searchable(text: $searchText, prompt: "Search notes")
    }
}

struct NoteRowView: View { //the row view for each note
    let note: CafeNoteEntry //take the entry
    @EnvironmentObject var notesVM: NotesViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(note.cafeName)
                .font(.headline)

            Text(note.text)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)

            if let summary = note.aiSummary, !summary.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI Summary")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    Text(summary)
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
                .padding(8)
                .background(Color.secondary.opacity(0.08))
                .cornerRadius(8)
            }

            HStack(spacing: 6) {
                if let sentiment = note.aiSentiment {
                    Text(sentiment.capitalized)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(colorForSentiment(sentiment).opacity(0.2))
                        .foregroundColor(colorForSentiment(sentiment))
                        .cornerRadius(999)
                }

                if let tags = note.aiTags {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag.replacingOccurrences(of: "-", with: " "))
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.12))
                            .cornerRadius(999)
                    }
                }

                Spacer()
            }

            HStack {
                Text(note.updatedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                if notesVM.isAnalyzingNoteId == note.id {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Analyzing…")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Button {
                        Task {
                            await notesVM.analyzeNoteWithAI(note)
                        }
                    } label: {
                        Text(note.aiSummary == nil ? "Do AI analysis" : "Re-analyze")
                            .font(.caption)
                    }
                }
            }
        }
    }

    //MARK: HELPER FUNC TO COLOR CODE AI SENTIMENT ANALYSIS TAGS
    //COULD clean up because is duped rn but will do before milestone 3
    private func colorForSentiment(_ sentiment: String) -> Color {
        switch sentiment.lowercased() {
        case "positive":
            return .green
        case "negative":
            return .red
        default:
            return .orange
        }
    }
}
