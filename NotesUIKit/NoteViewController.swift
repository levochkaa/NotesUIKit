// NoteViewController.swift

import UIKit

class NoteViewController: UIViewController, UITextViewDelegate {

    var note: Note!
    var rootVC: ViewController!
    var shareBtn: UIBarButtonItem!

    @IBOutlet var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        shareBtn = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareNote))
        navigationItem.rightBarButtonItems = [shareBtn]
        if let vc = navigationController?.viewControllers.first as? ViewController {
            rootVC = vc
        } else {
            fatalError("Couldn't find rootVC")
        }

        textView.delegate = self
        textView.becomeFirstResponder()
        textView.text = note.text
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.topAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            textView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            textView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10)
        ])

        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteNote))
        let new = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(newNote))
        toolbarItems = [delete, spacer, new]
        navigationController?.isToolbarHidden = false

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardViewEndFrame = view.convert(keyboardValue.cgRectValue, from: view.window)

        switch notification.name {
            case UIResponder.keyboardWillHideNotification:
                textView.contentInset = .zero
                navigationItem.rightBarButtonItems = [shareBtn]
            case UIResponder.keyboardWillChangeFrameNotification:
                textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
            case UIResponder.keyboardWillShowNotification:
                let doneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(hideKeyboard))
                navigationItem.rightBarButtonItems = [doneBtn, shareBtn]
            default:
                ()
        }

        textView.scrollIndicatorInsets = textView.contentInset
        textView.scrollRangeToVisible(textView.selectedRange)
    }

    @objc func hideKeyboard() {
        textView.endEditing(true)
    }

    func textViewDidChange(_ textView: UITextView) {
        if let index = rootVC.notes.firstIndex(where: { $0.id == note.id })  {
            rootVC.notes[index] = Note(id: note.id, text: self.textView.text)
            rootVC.save()
            rootVC.tableView.reloadData()
        }
    }

    @objc func deleteNote() {
        if let index = rootVC.notes.firstIndex(where: { $0.id == note.id }) {
            navigationController?.popToRootViewController(animated: true)
            rootVC.notes.remove(at: index)
            rootVC.save()
            rootVC.tableView.reloadData()
        }
    }

    @objc func newNote() {
        navigationController?.popToRootViewController(animated: false)
        rootVC.createNewNote()
    }

    @objc func shareNote() {
        let vc = UIActivityViewController(activityItems: [textView.text!], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
