//
//  ViewController.swift
//  ToDoList
//
//  Created by Guilherme Moser on 02/02/19.
//  Copyright © 2019 Guilherme Moser. All rights reserved.
//

import Cocoa
import WebKit


class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSWindowDelegate , WKNavigationDelegate {

    
    @IBOutlet weak var CoisasText: NSTextField!
    @IBOutlet weak var Temporada: NSTextField!
    
    @IBOutlet weak var Navegador: WKWebView!
    @IBOutlet weak var Links: NSTextField!
 //   @IBOutlet weak var ImportanteCheckBox: NSButton!
    
    @IBOutlet weak var Abrir: NSButton!
    @IBOutlet weak var TabelaView: NSTableView!
    @IBOutlet weak var Editar: NSButton!
    @IBOutlet weak var Apagar: NSButton!
    var toDoItens : [ToDoItem] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        PegarDados ()
        
        Navegador.navigationDelegate = self
        Navegador.wantsLayer = true
        
         Navegador.load(URLRequest(url: URL(string:  "https://trakt.tv/auth/auth/facebook")!))
        PegarDados ()
       
    }
    
    func PegarDados () {
        // pega os dados do coredate
        if let context = ( NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
           
            do {
                // colocar na class property
               toDoItens = try context.fetch(ToDoItem.fetchRequest())
                print(toDoItens.count)
            } catch {}
            
        }
        //update
        TabelaView.reloadData()
    }

    @IBAction func NavegarAte(_ sender: Any) {
        
        let toDoItem =  toDoItens[TabelaView.selectedRow]
        
        let urlNavegador = toDoItem.link
        
        
        Navegador.load(URLRequest(url: URL(string:  urlNavegador!)!))
        
    }
    
    @IBAction func AddCoisas(_ sender: Any) {
        if CoisasText.stringValue != "" {
            
            if let context = ( NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                
                let toDoItem = ToDoItem(context: context)
                
                toDoItem.nome = CoisasText.stringValue
                
//                if ImportanteCheckBox.state == .off {
//                    // nao importante
//                    toDoItem.importante = false
//                } else {
//                    // importnate
//                     toDoItem.importante = true
//               }
                
                toDoItem.link = Links.stringValue
                
                // agora salvamos
                
                 ( NSApplication.shared.delegate as? AppDelegate)?.saveAction(nil)
                
                CoisasText.stringValue = ""
                Links.stringValue = ""
//                ImportanteCheckBox.state = .off
                
                PegarDados ()
                
            }
           
        }
    }
    
    
    @IBAction func MontarLInk(_ sender: Any) {
        let linkP1 = "https://trakt.tv/shows/"
        let linkP2 = CoisasText.stringValue.replacingOccurrences(of: " ", with: "-")
        let linkP3 = Temporada.stringValue
        
        let linkFinal = linkP1 + linkP2.lowercased() + "/seasons/" + linkP3
        
        Links.stringValue = linkFinal
    }
    
    @IBAction func ApagarClicado(_ sender: Any) {
        let toDoItem = toDoItens [TabelaView.selectedRow]
        
        if let context = ( NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
           
            context.delete(toDoItem)
            
            ( NSApplication.shared.delegate as? AppDelegate)?.saveAction(nil)
            
            PegarDados ()
            
            Apagar.isHidden = true
            Editar.isHidden = true
            
        }
    }
    
    @IBAction func EditarCoisas(_ sender: Any) {
        
         let toDoItem = toDoItens [TabelaView.selectedRow]
        
        if CoisasText.stringValue != "" {
            
            if let context = ( NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                
               // let toDoItem = ToDoItem(context: context)
                
                toDoItem.nome = CoisasText.stringValue
                toDoItem.link = Links.stringValue
                
                context.commitEditing()
                
                // agora salvamos
                
                ( NSApplication.shared.delegate as? AppDelegate)?.saveAction(nil)
                
                CoisasText.stringValue = ""
                Links.stringValue = ""
                
                PegarDados ()
                
                Apagar.isHidden = true
                Editar.isHidden = true
                Abrir.isHidden = true
                
            }
            
        }
        
    }
    // MARK: - TableView Shits
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return toDoItens.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let toDoItem = toDoItens[row]
        
        if (tableColumn?.identifier)!.rawValue == "ImportanteColuna" {
             //    do this for importante
            if let cell = tableView.makeView(withIdentifier:  NSUserInterfaceItemIdentifier(rawValue: "ImportanteCelula") , owner: self) as? NSTableCellView {

//                if toDoItem.importante {
//                    cell.textField?.stringValue = "❗️"
//                } else {
//                    cell.textField?.stringValue = ""
//                }
                
                cell.textField?.stringValue = toDoItem.link ?? "erro"

                return cell
            }
        } else {
           //  coluna do item
            if let cell = tableView.makeView(withIdentifier:  NSUserInterfaceItemIdentifier(rawValue: "ItemCelula") , owner: self) as? NSTableCellView {
                
                cell.textField?.stringValue = toDoItem.nome ?? "erro"
                
                return cell
            }
        if let cell = tableView.makeView(withIdentifier:  NSUserInterfaceItemIdentifier(rawValue: "ItemCelula") , owner: self) as? NSTableCellView {
            
            cell.textField?.stringValue = toDoItem.nome ?? "erro"
            
            return cell
        }
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        do {
        let toDoItem =  toDoItens[TabelaView.selectedRow]
        
            CoisasText.stringValue = toDoItem.nome!
            Links.stringValue = toDoItem.link!
            
            Apagar.isHidden = false
            Editar.isHidden = false
            Abrir.isHidden = false
            
            let linkP1 = "https://trakt.tv/shows/"
            let linkT1 = Links.stringValue.replacingOccurrences(of: linkP1, with: "")
            let linkT2 = linkT1.replacingOccurrences(of: "/seasons/", with: "")
            let linkP2 = CoisasText.stringValue.replacingOccurrences(of: " ", with: "-")
            let linkT3 = linkT2.replacingOccurrences(of: linkP2.lowercased(), with: "")
            
            Temporada.stringValue = linkT3
            
            
            
        } catch {
            
        }
        
    }
    
    override func viewDidAppear() {
        self.view.window?.delegate = self
    }
    
    
    func windowShouldClose(sender: Any) {
        //NSApplication.terminate(self)
        NSApplication.shared.terminate(self)
        //exit(0)
    }
}



