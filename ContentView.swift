import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit // Für UIImage


@main
struct BellwellApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct MenuItem {
    let title: String
    let destination: AnyView
}

struct Artikel {
    let bild: String
    let titel: String
    let beschreibung: String
}




struct ContentView: View {
    @State private var showMenu = false
    @AppStorage("points") var points: Int = 0
    @State private var artikelListe = [
        Artikel(bild: "standort", titel: "Location Event", beschreibung: "For this event assemble a group of 5 all of different locations and get the highest placement for a reward!"),
        Artikel(bild: "depart", titel: "Departement Crossover", beschreibung: "Let's get out of the comfort zone! In this event form groups with members from different departements to get the highest score and win points"),
    ]

    var body: some View {
            NavigationView {
                ZStack {
                    // Hintergrund-Gradient
                    LinearGradient(gradient: Gradient(colors: [Color.darkGreen, Color.lightGreen]), startPoint: .top, endPoint: .bottom)
                        .edgesIgnoringSafeArea(.all)

                    VStack {
                        Spacer() // Neuer Spacer hinzugefügt

                        LogoView()
                            .padding(.top, 20)

                        Text("Bellwell")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        // Die Artikel-Ansicht
                        VStack {
                            ForEach(artikelListe, id: \.titel) { artikel in
                                ArtikelView(artikel: artikel)
                                .padding(.bottom, 20)
                            }
                        }

                        Spacer()

                        // Zeigt die gesammelten Punkte an
                        Text("Total collected Coins: \(points)")
                            .foregroundColor(.white)
                            .padding(.bottom, 20)
                    }
                
                // Button für das Seitenmenü hinzufügen
                HStack {
                    Button(action: {
                        withAnimation {
                            showMenu.toggle()
                        }
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding()

                // Füge das Seitenmenü hinzu
                if showMenu {
                       VStack(alignment: .leading, spacing: 50) {
                        Button(action: {
                            withAnimation {
                                showMenu.toggle()
                            }
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .padding()
                        }
                        .padding(.top, 100)

                        ForEach(MenuItems().items, id: \.title) { item in
                            NavigationLink(destination: item.destination) {
                                Text(item.title)
                                    .foregroundColor(.white)
                                    .font(.headline)
                                    .padding(.leading)
                            }
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.black.opacity(0.5))
                    .edgesIgnoringSafeArea(.all)
                    .transition(.move(edge: .leading))
                    
                }
            }
            .navigationViewStyle(.stack)
        }
    }
}


struct MenuItems: View {
    let items: [MenuItem] = [
        MenuItem(title: "Challenges", destination: AnyView(ChallengesView())),
        MenuItem(title: "Sports", destination: AnyView(SportsView())),
        MenuItem(title: "Food Recipes", destination: AnyView(FoodRecipesView())),
        MenuItem(title: "Meeting Point", destination: AnyView(MeetingPointView())),
        MenuItem(title: "Rewards", destination: AnyView(RewardsView()))
    ]
    
    var body: some View {
        ForEach(items, id: \.title) { item in
            NavigationLink(destination: item.destination) {
                Text(item.title)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(VisualEffectBlur(blurStyle: .systemThinMaterialDark))
                    .cornerRadius(20)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                    .padding(.horizontal, 20)
            }
        }
    }
}

extension Color {
    static let darkGreen = Color(red: 0.0, green: 0.2, blue: 0.1)
    static let lightGreen = Color(red: 0.0, green: 0.5, blue: 0.2)
}

struct ArtikelView: View {
    let artikel: Artikel
    @State private var expanded = false

    var body: some View {
        VStack {
            Image(artikel.bild)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 100)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.5), lineWidth: 4)
                )
            Text(artikel.titel)
                .font(.headline)
                .foregroundColor(.white)
            Button(action: { self.expanded.toggle() }) {
                Text(artikel.beschreibung)
                    .foregroundColor(.white)
                    .lineLimit(self.expanded ? nil : 1)
                    .padding(.horizontal, 60)
            }
        }
        .padding(.bottom, 20)
    }
}



struct LogoView: View {
    var body: some View {
        Image(systemName: "leaf.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 60, height: 60)
            .foregroundColor(.white)
    }
}

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}


struct ChallengesView: View {
    @AppStorage("points") var points: Int = 0
    
    private let colors: [Color] = [.red, .yellow, .green, .blue]
    @State private var sequence: [Int] = []
    @State private var playerSequenceIndex = 0 // Index für die aktuelle Position des Spielers in der Sequenz
    @State private var showingSequence = false
    @State private var activeIndex: Int? = nil
    @State private var gameOver = false
    @State private var score = 0
    @State private var highScores: [Int] = []

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.darkGreen, Color.lightGreen]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Text("Score: \(score)")
                    .foregroundColor(.white)
                    .font(.title)
                if gameOver {
                    VStack {
                        Text("Game Over! Highscores:")
                        ForEach(highScores, id: \.self) { score in
                            Text("\(score)")
                                .foregroundColor(.white)
                        }
                        Text("Tap to restart")
                            .padding()
                            .onTapGesture {
                                self.startGame()
                            }
                    }
                } else {
                    GridView(rows: 2, columns: 2) { row, col in
                        let index = row * 2 + col
                        Button(action: {
                            self.colorTapped(index)
                        }) {
                            colors[index]
                                .frame(width: 100, height: 100)
                                .cornerRadius(20)
                                .scaleEffect(index == activeIndex ? 1.1 : 1.0)
                                .animation(.easeIn(duration: 0.2), value: activeIndex)
                        }
                        .disabled(showingSequence)
                    }
                }
            }
        }
        .onAppear(perform: startGame)
    }

    private func startGame() {
        sequence.removeAll()
        score = 0
        gameOver = false
        playerSequenceIndex = 0
        addColorToSequence()
    }
    
    private func calculatePointsForScore(_ score: Int) -> Int {
        switch score {
        case 10...19:
            return 1
        case 20...29:
            return 3
        case 30...:
            return 7
        default:
            return 0
        }
    }

    private func addColorToSequence() {
        sequence.append(Int.random(in: 0..<colors.count))
        score = sequence.count - 1
        playerSequenceIndex = 0
        showSequence()
    }

    private func showSequence() {
        showingSequence = true
        activeIndex = nil
        
        for (index, colorIndex) in sequence.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.5) {
                self.activeIndex = colorIndex
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.activeIndex = nil
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(sequence.count) * 0.75) {
            self.showingSequence = false
        }
    }
    
    private func colorTapped(_ index: Int) {
        // Überprüfung, ob die getippte Farbe korrekt ist
        if showingSequence || sequence.isEmpty || index != sequence[playerSequenceIndex] {
            gameOver = true
            let earnedPoints = calculatePointsForScore(score)
            points += earnedPoints // Aktualisiere die gespeicherten Punkte
            highScores.append(score)
            highScores.sort(by: >)
            if highScores.count > 5 { highScores.removeLast() } // Behalte nur die Top 5 Highscores
            // Bereite die Ansicht für ein neues Spiel vor
        } else {
            playerSequenceIndex += 1
            // Prüfe, ob das Ende der Sequenz erreicht wurde
            if playerSequenceIndex == sequence.count {
                playerSequenceIndex = 0
                showingSequence = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.addColorToSequence()
                }
            }
        }
    }
}



// Hilfsstruktur, um ein Raster für die Farbknöpfe zu erstellen
struct GridView<Content: View>: View {
    let rows: Int
    let columns: Int
    let content: (Int, Int) -> Content

    var body: some View {
        VStack {
            ForEach(0..<rows, id: \.self) { row in
                HStack {
                    ForEach(0..<columns, id: \.self) { column in
                        self.content(row, column)
                    }
                }
            }
        }
    }

    init(rows: Int, columns: Int, @ViewBuilder content: @escaping (Int, Int) -> Content) {
        self.rows = rows
        self.columns = columns
        self.content = content
    }
}


struct Reward: Identifiable {
    let id = UUID()
    let name: String
    let cost: Int
}


struct RewardsView: View {
    @AppStorage("points") var points: Int = 0
    let rewards = [
        Reward(name: "One free Cafeteria Meal", cost: 10),
        Reward(name: "Free ingredients", cost: 10),
        Reward(name: "Extra holiday", cost: 100),
        Reward(name: "Local Event Tickets", cost: 30),
        Reward(name: "Free Beer", cost: 5)
    ]
    @State private var insufficientPointsRewardId: UUID? = nil
    @State private var selectedReward: Reward? = nil
    @State private var showQRCodeView = false // Zustand, der die Anzeige der QRCodeView steuert

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.darkGreen, Color.lightGreen]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    Text("Available Coins: \(points)")
                        .foregroundColor(.white)
                        .padding()

                    List(rewards) { reward in
                        Button(action: {
                            buyReward(reward)
                        }) {
                            HStack {
                                Text(reward.name)
                                Spacer()
                                Text("\(reward.cost) Punkt\(reward.cost != 1 ? "e" : "")")
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(reward.id == insufficientPointsRewardId ? Color.red : Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .foregroundColor(.white)
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(PlainListStyle())
                }
                
                // Steuert die Navigation zur QRCodeView
                NavigationLink(destination: QRCodeView(rewardName: selectedReward?.name ?? ""), isActive: $showQRCodeView) {
                    EmptyView()
                }
            }
            .navigationBarHidden(true)
        }
    }

    func buyReward(_ reward: Reward) {
        if points >= reward.cost {
            points -= reward.cost
            selectedReward = reward
            showQRCodeView = true // Aktiviert die Navigation zur QRCodeView
            insufficientPointsRewardId = nil
        } else {
            insufficientPointsRewardId = reward.id
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.insufficientPointsRewardId = nil
            }
        }
    }
}



struct FoodRecipesView: View {
    @State private var showPastaRecipe = false
    @State private var showSaladRecipe = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer(minLength: 50) // Erhöht den Abstand vom oberen Rand

                recipeView(imageName: "HealthyPasta", title: "Healthy Pasta", recipeText: "Pasta Recipe: Whole wheat pasta, fresh tomatoes, basil, olive oil...", showRecipe: $showPastaRecipe)
                
                recipeView(imageName: "HealthySalad", title: "Healthy Salad", recipeText: "Salad Recipe: Mixed greens, cherry tomatoes, cucumbers, olive oil dressing...", showRecipe: $showSaladRecipe)
            }
            .padding()
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color.darkGreen, Color.lightGreen]), startPoint: .top, endPoint: .bottom))
        .edgesIgnoringSafeArea(.all)
    }

    @ViewBuilder
    func recipeView(imageName: String, title: String, recipeText: String, showRecipe: Binding<Bool>) -> some View {
        VStack {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
                .padding()
                .shadow(radius: 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.3), Color.green]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 4)
                )
            
            Button(action: {
                withAnimation {
                    showRecipe.wrappedValue.toggle()
                }
            }) {
                Label {
                    Text(title)
                        .fontWeight(.semibold)
                } icon: {
                    Image(systemName: "book.fill")
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark))
                .cornerRadius(20)
                .foregroundColor(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.8), lineWidth: 1)
                )
            }
            
            if showRecipe.wrappedValue {
                Text(recipeText)
                    .foregroundColor(.white)
                    .padding()
                    .transition(.slide)
            }
        }
    }
}

func generateQRCode(from string: String) -> UIImage? {
    // Erhalte eine Referenz auf den QR-Code-Generator
    let filter = CIFilter.qrCodeGenerator()
    
    // Konvertiere den Eingabestring in Daten
    let data = string.data(using: String.Encoding.ascii)
    
    // Setze die Daten als Eingabe für den QR-Code-Generator
    filter.setValue(data, forKey: "inputMessage")
    
    // Versuche, das CIImage zu erhalten, das den QR-Code darstellt
    if let qrCodeImage = filter.outputImage {
        // Konvertiere das CIImage in ein UIImage
        let context = CIContext()
        if let cgImage = context.createCGImage(qrCodeImage, from: qrCodeImage.extent) {
            return UIImage(cgImage: cgImage)
        }
    }
    
    // Gebe nil zurück, falls irgendein Schritt fehlschlägt
    return nil
}



struct QRCodeView: View {
    let rewardName: String
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text(rewardName)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()

            if let qrImage = generateQRCode(from: rewardName) {
                Image(uiImage: qrImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .background(Color.white)
                    .cornerRadius(12)
            } else {
                Text("QR-Code konnte nicht generiert werden.")
                    .foregroundColor(.white)
            }

            Spacer()
            
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LinearGradient(gradient: Gradient(colors: [Color.darkGreen, Color.lightGreen]), startPoint: .top, endPoint: .bottom))
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true) // Versteckt den automatisch generierten Zurück-Knopf
        .navigationBarHidden(true) // Versteckt die gesamte Navigation Bar
    }
}

struct Team: Identifiable, Codable {
    let id: UUID
    var name: String
    var score: Int
    var members: [Member]

    init(id: UUID = UUID(), name: String, score: Int, members: [Member]) {
        self.id = id
        self.name = name
        self.score = score
        self.members = members
    }
}

struct Member: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var department: String
    var location: String

    init(id: UUID = UUID(), name: String, department: String, location: String) {
        self.id = id
        self.name = name
        self.department = department
        self.location = location
    }
}

class TeamStore: ObservableObject {
    @Published var teams: [Team] = [] {
        didSet {
            saveTeams()
        }
    }
    
    init() {
        loadTeams()
    }
    
    func loadTeams() {
        if let savedTeams = UserDefaults.standard.data(forKey: "SavedTeams") {
            let decoder = JSONDecoder()
            if let loadedTeams = try? decoder.decode([Team].self, from: savedTeams) {
                self.teams = loadedTeams
                return
            }
        }
        self.teams = []
    }
    
    func saveTeams() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(teams) {
            UserDefaults.standard.set(encoded, forKey: "SavedTeams")
        }
    }
}



struct MeetingPointView: View {
    @StateObject var teamStore = TeamStore()
    @State private var showingCreateTeam = false
    @State private var showingJoinTeam = false

    init() {
        // Konfiguriere das Erscheinungsbild der Navigationsleiste
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.darkGreen) // Hintergrundfarbe der Navigationsleiste
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white] // Farbe des Titels
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white] // Farbe des großen Titels, falls verwendet

        // Wende das angepasste Erscheinungsbild auf alle Zustände an
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                List {
                    ForEach(teamStore.teams) { team in
                        NavigationLink(destination: TeamDetailView(team: team)) {
                            TeamRow(team: team)
                                .background(LinearGradient(gradient: Gradient(colors: [Color.darkGreen, Color.lightGreen]), startPoint: .leading, endPoint: .trailing)) // Dunkler Grünton
                                .cornerRadius(10)
                                .padding(.vertical, 5) // Vertikaler Abstand zwischen den Teams
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .padding()
                
                
                HStack(spacing: 20) {
                    Button(action: {
                        showingCreateTeam = true
                    }) {
                        Text("Create Team")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        showingJoinTeam = true
                    }) {
                        Text("Join Team")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .padding(.bottom, 20)
            }
            .navigationBarTitle("", displayMode: .inline) // Keine Überschrift
            .background(LinearGradient(gradient: Gradient(colors: [Color.darkGreen, Color.lightGreen]), startPoint: .top, endPoint: .bottom)) // Dunkler Grünton
            .sheet(isPresented: $showingCreateTeam) {
                CreateTeamView(teamStore: teamStore)
            }
            .sheet(isPresented: $showingJoinTeam) {
                JoinTeamView(teamStore: teamStore)
            }
        }
    }
}

struct TeamRow: View {
    let team: Team
    
    var body: some View {
        HStack {
            Text(team.name)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            Text("Team Score: \(team.score)")
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.clear) // Hintergrundfarbe entfernen
    }
}






// Lade Teams beim Start der App
func loadTeams() -> [Team] {
    if let savedTeams = UserDefaults.standard.data(forKey: "SavedTeams") {
        let decoder = JSONDecoder()
        if let loadedTeams = try? decoder.decode([Team].self, from: savedTeams) {
            return loadedTeams
        }
    }
    return []
}

// Speichere Teams in UserDefaults
func saveTeams(_ teams: [Team]) {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(teams) {
        UserDefaults.standard.set(encoded, forKey: "SavedTeams")
    }
}



struct CreateTeamView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var teamStore: TeamStore
    @State private var teamName = ""
    
    
    var body: some View {
        VStack {
            TextField("Team name", text: $teamName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("Create Team") {
                let newTeam = Team(name: teamName, score: 0, members: [])
                teamStore.teams.append(newTeam)
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.green)
            .cornerRadius(10)
        }
        .padding()
        .background(LinearGradient(gradient: Gradient(colors: [Color.darkGreen, Color.lightGreen]), startPoint: .top, endPoint: .bottom))
        .edgesIgnoringSafeArea(.all)
        .navigationBarTitle("New Team", displayMode: .inline)
        .navigationBarItems(trailing: Button("cancel") {
            presentationMode.wrappedValue.dismiss()
        }.foregroundColor(.white))
    }
}




struct JoinTeamView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var teamStore: TeamStore
    @State private var selectedTeamIndex: Int?
    @State private var memberName = ""
    @State private var department = ""
    @State private var location = ""

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Choose a team", selection: $selectedTeamIndex) {
                        ForEach(teamStore.teams.indices, id: \.self) { index in
                            Text(self.teamStore.teams[index].name).tag(index as Int?)
                        }
                    }
                }
                
                Section(header: Text("Deine Informationen")) {
                    TextField("Name", text: $memberName)
                    TextField("Departement", text: $department)
                    TextField("Location", text: $location)
                }
                
                Button("Join") {
                    guard let index = selectedTeamIndex, teamStore.teams[index].members.count < 5 else { return }
                    let newMember = Member(name: memberName, department: department, location: location)
                    teamStore.teams[index].members.append(newMember)
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .navigationBarTitle("Join Team", displayMode: .inline)
            .navigationBarItems(trailing: Button("cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}



struct TeamDetailView: View {
    var team: Team
    
    var body: some View {
        List {
            ForEach(team.members) { member in
                VStack(alignment: .leading) {
                    Text(member.name).font(.headline)
                    Text(member.department)
                    Text(member.location)
                }
            }
        }
        .navigationBarTitle(team.name)
    }
}


struct SportsView: View {
    @State private var showWorkout = false
    @State private var showYoga = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer(minLength: 50) // Erhöht den Abstand vom oberen Rand

                recipeView(imageName: "Workout", title: "Workout", recipeText: "*Insert tasks for Workout here*", showRecipe: $showWorkout)
                
                recipeView(imageName: "Yoga", title: "Yoga", recipeText: "*Insert Yoga tasks here*", showRecipe: $showYoga)
            }
            .padding()
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color.darkGreen, Color.lightGreen]), startPoint: .top, endPoint: .bottom))
        .edgesIgnoringSafeArea(.all)
    }

    @ViewBuilder
    func recipeView(imageName: String, title: String, recipeText: String, showRecipe: Binding<Bool>) -> some View {
        VStack {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
                .padding()
                .shadow(radius: 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.3), Color.green]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 4)
                )
            
            Button(action: {
                withAnimation {
                    showRecipe.wrappedValue.toggle()
                }
            }) {
                Label {
                    Text(title)
                        .fontWeight(.semibold)
                } icon: {
                    Image(systemName: "book.fill")
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark))
                .cornerRadius(20)
                .foregroundColor(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.8), lineWidth: 1)
                )
            }
            
            if showRecipe.wrappedValue {
                Text(recipeText)
                    .foregroundColor(.white)
                    .padding()
                    .transition(.slide)
            }
        }
    }
}
