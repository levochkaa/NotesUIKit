// ViewController.swift

import UIKit

class ViewController: UITableViewController {

    var notes = [Note]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notes"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(createNewNote(sender:)))

        if let savedData = UserDefaults.standard.object(forKey: "notes") as? Data {
            do {
                notes = try JSONDecoder().decode([Note].self, from: savedData)
            } catch {
                print("Failed to load notes")
            }
        }
    }

    @objc func createNewNote(sender: UIBarButtonItem? = nil) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Note") as? NoteViewController {
            let newNote = Note(id: UUID().uuidString, text: "")
            notes.append(newNote)
            save()
            vc.note = newNote
            if sender != nil {
                navigationController?.pushViewController(vc, animated: true)
            } else {
                navigationController?.pushViewController(vc, animated: false)
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Note") as? NoteViewController {
            vc.note = notes[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = notes[indexPath.row].text.trimmingCharacters(in: .whitespacesAndNewlines)
        return cell
    }

    func save() {
        if let data = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(data, forKey: "notes")
            tableView.reloadData()
        } else {
            print("Failed to save notes")
        }
    }
}

