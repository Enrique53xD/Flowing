//import Foundation
import WatchConnectivity

class PhoneConnection: NSObject, WCSessionDelegate, ObservableObject {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
    
    @Published var tasks: [taskItem] = []
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        loadTasksFromUserDefaults()
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        handleReceivedTasks(userInfo)
    }
    
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        if let error = error {
            print("Error receiving user info: \(error.localizedDescription)")
        } else {
            handleReceivedTasks(userInfoTransfer.userInfo)
        }
    }
    
    private func handleReceivedTasks(_ userInfo: [String: Any]) {
        DispatchQueue.main.async {
            if let tasksData = userInfo["tasks"] as? Data {
                do {
                    let decodedTasks = try JSONDecoder().decode([taskItem].self, from: tasksData)
                    self.tasks = decodedTasks
                    print("Received and decoded \(decodedTasks.count) tasks")
                    
                    // Save to UserDefaults
                    UserDefaults.standard.set(tasksData, forKey: "tasks")
                } catch {
                    print("Error decoding tasks: \(error)")
                }
            } else {
                print("No tasks data found in userInfo")
            }
        }
    }
    
    private func loadTasksFromUserDefaults() {
        if let storedTasksData = UserDefaults.standard.data(forKey: "tasks") {
            do {
                let decodedTasks = try JSONDecoder().decode([taskItem].self, from: storedTasksData)
                self.tasks = decodedTasks
                print("Loaded \(decodedTasks.count) tasks from UserDefaults")
            } catch {
                print("Error decoding stored tasks: \(error)")
            }
        }
    }
    
}


struct taskItem: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let color: String
    let desc: String
    let symbol: String
    let start: Int
    let end: Int
    let done: Bool
    let days: String
    
    static func == (lhs: taskItem, rhs: taskItem) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.color == rhs.color &&
        lhs.desc == rhs.desc &&
        lhs.symbol == rhs.symbol &&
        lhs.start == rhs.start &&
        lhs.end == rhs.end &&
        lhs.done == rhs.done &&
        lhs.days == rhs.days
    }
}
