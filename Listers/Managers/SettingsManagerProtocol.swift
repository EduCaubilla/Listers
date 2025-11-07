import Foundation

protocol SettingsManagerProtocol {
    var currentSettings: DMSettings? { get }
    func loadSettings()
    func updateSettings(itemDescription: Bool, itemQuantity: Bool, itemEndDate: Bool, listDescription: Bool, listEndDate: Bool)
}
