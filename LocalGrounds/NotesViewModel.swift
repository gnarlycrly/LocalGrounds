//
//  NotesViewModel.swift
//  LocalGrounds
//
//  Created by Carly Jazwin on 11/05/25.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

//this file stores all users notes & saves to firestore
//also responsible for loading them and enabling edit/delete
//AI ADDED, sentiment analysis and summary and tags for filtering

//MARK: STRUCT FOR WHOLE NOTE ENTRY
//each note entry, this is main model for the note funtionality
struct CafeNoteEntry: Identifiable, Codable, Equatable {
    let id: String
    let cafeID: String
    let cafeName: String
    var text: String
    var updatedAt: Date

    // attributes from ai sentiment analysis
    var aiSummary: String?
    var aiSentiment: String?
    var aiTags: [String]?
}

//MARK: STRUCT FOR THE AI ANALYSIS JSON
//this is the form of the json that gets returned
struct NoteAIAnalysis: Codable {
    let summary: String
    let sentiment: String
    let tags: [String]
}

//MARK: WHOLE NOTE VIEW MODEL CLASS
//ACTUAL viewmodel, handles everything needed to do w notes
class NotesViewModel: ObservableObject {
    @Published private(set) var notes: [CafeNoteEntry] = []
    @Published var isAnalyzingNoteId: String? = nil
    @Published var aiErrorMessage: String? = nil

    private let db = Firestore.firestore()

    private var userId: String { //use auth to attach to each users id
        if let uid = Auth.auth().currentUser?.uid {return uid}
        else { return "unauthenticated-user"}
    }

    private var notesCollection: CollectionReference {
        db.collection("users")
            .document(userId)
            .collection("notes")
    }

    init() {
        loadNotes()
    } //startup func, checks if users logged in & gets notes

    func note(for cafe: Cafe) -> CafeNoteEntry? { //returns cafe note entry based on matching ids
        notes.first { note in
            note.cafeID == cafe.id
        }
    }

    func allNotesSorted() -> [CafeNoteEntry] { //sort based on the updated at attribute so recently updates notes shown first
        notes.sorted { first, second in
            first.updatedAt > second.updatedAt
        }
    }

//MARK: SAVE NOTE FUNC
    func saveNote(for cafe: Cafe, text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines) //clean up the text first

        if trimmed.isEmpty { //if its empty, just delete the note
            if let existing = note(for: cafe) {
                delete(existing)
            }
            return
        }

        if let existing = note(for: cafe) { //if its not, update the note info w the input
            let docRef = notesCollection.document(existing.id)
            let data: [String: Any] = [
                "cafeID": cafe.id,
                "cafeName": cafe.name,
                "text": trimmed,
                "updatedAt": Timestamp(date: Date())
            ]

            //update note in database
            docRef.setData(data, merge: true) { [weak self] error in
                guard let self = self else { return }

                   if let error = error {
                       print("ERROR! Couldn't update note! Error code:", error)
                       return
                   }

                   if let index = self.notes.firstIndex(where: { note in
                       note.id == existing.id
                   }) {
                       self.notes[index].text = trimmed
                       self.notes[index].updatedAt = Date()
                   }
            }
        }
        
        else {
            let docRef = notesCollection.document()
            let now = Date()
            let data: [String: Any] = [
                "cafeID": cafe.id,
                "cafeName": cafe.name,
                "text": trimmed,
                "updatedAt": Timestamp(date: now)
            ]

            //catch all error potentials- SAVING
            docRef.setData(data) { [weak self] error in
                if let error = error {
                    print("ERROR! Couldn't save note! Error code:", error)
                    return
                }
                
                //create new note out of all attrs from entry
                let newNote = CafeNoteEntry(
                    id: docRef.documentID,
                    cafeID: cafe.id,
                    cafeName: cafe.name,
                    text: trimmed,
                    updatedAt: now,
                    aiSummary: nil,
                    aiSentiment: nil,
                    aiTags: nil
                )
                self?.notes.append(newNote) //append to the list of notes
            }
        }
    }

//MARK:  DELETE NOTE FUNC
    func delete(_ note: CafeNoteEntry) {
        notesCollection.document(note.id).delete { [weak self] error in
            if let error = error {
                print("ERROR! Couldn't delete note! Error code:", error)
                return
            }
            self?.notes.removeAll { existingNote in //remove based on ids
                existingNote.id == note.id
            }
        }
    }

//MARK: FUNC TO LOAD NOTES
    func loadNotes() {
        guard Auth.auth().currentUser != nil else { //get user auth
            self.notes = []
            return
        }

        notesCollection
            .order(by: "updatedAt", descending: true)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("ERROR! Couldn't load notes! Error code:", error)
                    return
                }

                guard let documents = snapshot?.documents else {
                    self?.notes = []
                    return
                }
                //decoded note entries
                let decoded: [CafeNoteEntry] = documents.compactMap { doc in
                    let data = doc.data()
                    guard
                        let cafeID = data["cafeID"] as? String,
                        let cafeName = data["cafeName"] as? String,
                        let text = data["text"] as? String,
                        let ts = data["updatedAt"] as? Timestamp
                    else {
                        return nil
                    }

                    let aiSummary = data["aiSummary"] as? String
                    let aiSentiment = data["aiSentiment"] as? String
                    let aiTags = data["aiTags"] as? [String]

                    return CafeNoteEntry( //return the whole entry, with ai added if its available
                        id: doc.documentID,
                        cafeID: cafeID,
                        cafeName: cafeName,
                        text: text,
                        updatedAt: ts.dateValue(),
                        aiSummary: aiSummary,
                        aiSentiment: aiSentiment,
                        aiTags: aiTags
                    )
                }

                self?.notes = decoded
            }
    }

    //MARK: ANALAZYE AI FUNCTION
    //async function to take cafe note and analyze
    func analyzeNoteWithAI(_ note: CafeNoteEntry) async {
        let trimmed = note.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        //trim it first, if empty just return
        
        await MainActor.run {
            self.isAnalyzingNoteId = note.id
            self.aiErrorMessage = nil
        }

        do { //call the endpoint
            let analysis = try await callAIEndpoint(text: trimmed)

            let docRef = notesCollection.document(note.id)
            //update data with all the info from the ai endpoint
            try await docRef.updateData([
                "aiSummary": analysis.summary,
                "aiSentiment": analysis.sentiment,
                "aiTags": analysis.tags,
                "updatedAt": Timestamp(date: Date())
            ])

            await MainActor.run { //look for note matching id
                guard let index = self.notes.firstIndex(where: { note in
                    note.id == note.id
                }) else { return }

                var updatedNote = self.notes[index]
                updatedNote.aiSummary = analysis.summary
                updatedNote.aiSentiment = analysis.sentiment
                updatedNote.aiTags = analysis.tags
                updatedNote.updatedAt = Date()

                self.notes[index] = updatedNote
                self.isAnalyzingNoteId = nil
            }
        } catch {
            await MainActor.run {
                self.aiErrorMessage = "ERROR ANALYZING NOTE"
                self.isAnalyzingNoteId = nil
            }
        }
    }

    //MARK: CALL AI ENDPOINT FUNC
    //sends note to firebase and waits for ai analysis results
    private func callAIEndpoint(text: String) async throws -> NoteAIAnalysis {
        guard let url = URL(string: "https://us-central1-local-groundz.cloudfunctions.net/analyzeCafeNote") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url) //creates http request post, means send data
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //sending json, not just plain text
        let body = ["text": text]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else { //status codes for whether successful
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(NoteAIAnalysis.self, from: data)
    }
}
