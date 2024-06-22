//import Foundation
import WatchConnectivity

class PhoneConnection: NSObject, WCSessionDelegate, ObservableObject {
    @Published var tasks: [taskItem] = []
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        print("Received user info: \(userInfo)")
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
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
        }
    }
    

}


struct taskItem: Identifiable, Codable {
    let id: String
    let name: String
    let color: String
    let desc: String
    let symbol: String
    let start: Int
    let end: Int
    let done: Bool
    let days: String
}
