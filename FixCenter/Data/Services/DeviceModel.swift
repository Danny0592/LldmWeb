import FirebaseFirestore

struct DatabaseSeeds {
    
    static func uploadServiceData() {
        let db = Firestore.firestore()
        
        // 1. Catálogo de Categorías
        let categories = [
            ["id": "celular", "name": "Celulares", "icon": "iphone"],
            ["id": "laptop", "name": "Laptops", "icon": "laptopcomputer"],
            ["id": "tablet", "name": "Tablets", "icon": "ipad"],
            ["id": "pc", "name": "Computadoras de Escritorio", "icon": "desktopcomputer"],
            ["id": "consola", "name": "Consolas de Videojuegos", "icon": "gamecontroller"]
        ]
        
        // 2. Catálogo de Marcas (Actualizado con marcas de PC/Laptop)
        let brands = [
            ["id": "apple", "name": "Apple", "categories": ["celular", "laptop", "tablet", "pc"]],
            ["id": "samsung", "name": "Samsung", "categories": ["celular", "tablet", "laptop"]],
            ["id": "sony", "name": "Sony (PlayStation)", "categories": ["consola"]],
            ["id": "nintendo", "name": "Nintendo", "categories": ["consola"]],
            ["id": "microsoft", "name": "Microsoft (Xbox)", "categories": ["consola", "laptop", "tablet"]],
            ["id": "asus", "name": "Asus", "categories": ["laptop", "pc", "consola"]],
            ["id": "xiaomi", "name": "Xiaomi", "categories": ["celular", "tablet"]],
            ["id": "huawei", "name": "Huawei", "categories": ["celular", "laptop", "tablet"]],
            ["id": "motorola", "name": "Motorola", "categories": ["celular"]],
            ["id": "oppo", "name": "OPPO", "categories": ["celular"]],
            ["id": "vivo", "name": "Vivo", "categories": ["celular"]],
            ["id": "realme", "name": "Realme", "categories": ["celular"]],
            ["id": "oneplus", "name": "OnePlus", "categories": ["celular", "tablet"]],
            ["id": "google", "name": "Google", "categories": ["celular", "tablet"]],
            ["id": "lenovo", "name": "Lenovo", "categories": ["laptop", "tablet", "pc"]],
            ["id": "hp", "name": "HP", "categories": ["laptop", "pc"]],
            ["id": "dell", "name": "Dell", "categories": ["laptop", "pc"]],
            ["id": "acer", "name": "Acer", "categories": ["laptop", "pc"]]
        ]
        
        var models: [[String: String]] = []
        
        // 3a. Modelos de Celulares
        let celularesPorMarca = [
            "apple": ["iPhone 15 Pro Max", "iPhone 15 Pro", "iPhone 15 Plus", "iPhone 15", "iPhone 14 Pro Max", "iPhone 14 Pro", "iPhone 14 Plus", "iPhone 14", "iPhone 13 Pro Max", "iPhone 13 Pro", "iPhone 13", "iPhone 13 mini", "iPhone 12 Pro Max", "iPhone 12 Pro", "iPhone 12", "iPhone 12 mini", "iPhone 11 Pro Max", "iPhone 11 Pro", "iPhone 11", "iPhone SE (3rd Gen)"],
            "samsung": ["Galaxy S24 Ultra", "Galaxy S24+", "Galaxy S24", "Galaxy S23 Ultra", "Galaxy S23+", "Galaxy S23", "Galaxy S22 Ultra", "Galaxy S22+", "Galaxy S22", "Galaxy Z Fold 5", "Galaxy Z Flip 5", "Galaxy Z Fold 4", "Galaxy Z Flip 4", "Galaxy A54", "Galaxy A34", "Galaxy A14", "Galaxy A53", "Galaxy M54", "Galaxy S23 FE", "Galaxy S21 FE"],
            "xiaomi": ["14 Ultra", "14 Pro", "14", "13 Ultra", "13 Pro", "13", "13T Pro", "13T", "12S Ultra", "12 Pro", "12", "Redmi Note 13 Pro+", "Redmi Note 13 Pro", "Redmi Note 13", "Redmi Note 12 Pro+", "Redmi Note 12 Pro", "POCO F5 Pro", "POCO F5", "POCO X5 Pro", "POCO X5"],
            "huawei": ["Mate 60 Pro+", "Mate 60 Pro", "Mate 60", "P60 Pro", "P60 Art", "P60", "Mate X5", "Mate X3", "Mate 50 Pro", "Mate 50", "P50 Pro", "P50 Pocket", "nova 12 Pro", "nova 12", "nova 11 Pro", "nova 11", "enjoy 70", "enjoy 60X", "Mate 40 Pro", "P40 Pro"],
            "motorola": ["Edge 50 Pro", "Edge 50 Ultra", "Edge 40 Pro", "Edge 40", "Edge 40 Neo", "Edge 30 Ultra", "Edge 30 Pro", "Edge 30 Fusion", "Razr 40 Ultra", "Razr 40", "Razr 2022", "Moto G84", "Moto G54", "Moto G14", "Moto G73", "Moto G53", "Moto E13", "Defy 2", "Edge 20 Pro", "Moto G100"],
            "oppo": ["Find X7 Ultra", "Find X7", "Find X6 Pro", "Find X6", "Find N3", "Find N3 Flip", "Find N2", "Find N2 Flip", "Reno11 Pro", "Reno11", "Reno10 Pro+", "Reno10 Pro", "Reno10", "A98", "A79", "A78", "A58", "A38", "A18", "K11"],
            "vivo": ["X100 Pro", "X100", "X90 Pro+", "X90 Pro", "X90", "X Fold3 Pro", "X Fold3", "X Fold2", "X Flip", "V30 Pro", "V30", "V29 Pro", "V29", "V29e", "V27 Pro", "V27", "Y200", "Y100", "Y78", "iQOO 12 Pro"],
            "realme": ["12 Pro+", "12 Pro", "12+", "12", "11 Pro+", "11 Pro", "11", "GT5 Pro", "GT5", "GT3", "GT Neo 5", "GT Neo 3", "C67", "C65", "C55", "C53", "C51", "Narzo 60 Pro", "Narzo 60", "Narzo N53"],
            "oneplus": ["12", "12R", "11", "11R", "10 Pro", "10T", "10R", "9 Pro", "9", "Open", "Nord 3", "Nord CE 3 Lite", "Nord CE 3", "Nord 2T", "Nord CE 2", "Ace 3", "Ace 2 Pro", "Ace 2", "Ace 2V", "8T"],
            "google": ["Pixel 8 Pro", "Pixel 8", "Pixel 8a", "Pixel 7 Pro", "Pixel 7", "Pixel 7a", "Pixel Fold", "Pixel 6 Pro", "Pixel 6", "Pixel 6a", "Pixel 5", "Pixel 5a", "Pixel 4 XL", "Pixel 4", "Pixel 4a 5G", "Pixel 4a", "Pixel 3 XL", "Pixel 3", "Pixel 3a XL", "Pixel 3a"]
        ]
        
        // 3b. Modelos de Laptops
        let laptopsPorMarca = [
            "apple": ["MacBook Pro 16 M3 Max", "MacBook Pro 16 M3 Pro", "MacBook Pro 14 M3", "MacBook Pro 14 M2", "MacBook Pro 13 M2", "MacBook Air 15 M3", "MacBook Air 13 M3", "MacBook Air 15 M2", "MacBook Air 13 M2", "MacBook Air M1", "MacBook Pro 16 M1 Max", "MacBook Pro 14 M1 Pro"],
            "lenovo": ["ThinkPad X1 Carbon Gen 11", "ThinkPad T14s Gen 4", "ThinkPad E14 Gen 5", "IdeaPad Flex 5", "IdeaPad 3", "Legion Pro 7i", "Legion Slim 5", "Yoga 9i", "Yoga 7i", "LOQ 15", "ThinkBook 15 Gen 4", "Ideapad Gaming 3"],
            "hp": ["Spectre x360 14", "Spectre x360 16", "Envy x360 15", "Envy 17", "Pavilion 15", "Pavilion x360", "Omen 16", "Omen Transcend 14", "Victus 15", "Victus 16", "ProBook 450", "EliteBook 840"],
            "dell": ["XPS 13", "XPS 13 Plus", "XPS 15", "XPS 17", "Inspiron 15", "Inspiron 14", "Inspiron 16 Plus", "Alienware m18", "Alienware x16", "Alienware m16", "G15 Gaming", "Latitude 5430", "Latitude 7430", "Precision 3580"],
            "asus": ["Zenbook 14 OLED", "Zenbook Pro 16X", "Vivobook 15", "Vivobook Pro 15", "ROG Zephyrus G14", "ROG Strix SCAR 16", "ROG Flow X13", "TUF Gaming A15", "TUF Dash F15", "ExpertBook B9", "Chromebook Flip", "ProArt Studiobook"],
            "acer": ["Swift 14", "Swift Go 14", "Swift X 14", "Aspire 5", "Aspire 3", "Predator Helios Neo 16", "Predator Triton 300", "Nitro 5", "Nitro 17", "Chromebook Spin 714", "ConceptD 7", "TravelMate P4"]
        ]
        
        // 3c. Modelos de Tablets
        let tabletsPorMarca = [
            "apple": ["iPad Pro 12.9 M2", "iPad Pro 11 M2", "iPad Air (5th Gen)", "iPad Air (4th Gen)", "iPad (10th Gen)", "iPad (9th Gen)", "iPad mini (6th Gen)", "iPad Pro 12.9 M1", "iPad Pro 11 M1", "iPad (8th Gen)", "iPad Air (3rd Gen)", "iPad mini (5th Gen)"],
            "samsung": ["Galaxy Tab S9 Ultra", "Galaxy Tab S9+", "Galaxy Tab S9", "Galaxy Tab S8 Ultra", "Galaxy Tab S8+", "Galaxy Tab S8", "Galaxy Tab S9 FE", "Galaxy Tab S9 FE+", "Galaxy Tab A9+", "Galaxy Tab A9", "Galaxy Tab S7 FE", "Galaxy Tab A8"],
            "lenovo": ["Tab P12 Pro", "Tab P11 Pro Gen 2", "Tab P11 Gen 2", "Tab M10 Plus Gen 3", "Tab M9", "Tab M8 Gen 4", "Yoga Tab 13", "Yoga Tab 11", "Legion Y700", "Tab Extreme", "Duet 5 Chromebook", "Tab M10 HD"],
            "xiaomi": ["Pad 6 Max", "Pad 6 Pro", "Pad 6", "Pad 5 Pro", "Pad 5", "Redmi Pad SE", "Redmi Pad", "Mi Pad 4", "Mi Pad 4 Plus", "Book S 12.4"],
            "huawei": ["MatePad Pro 13.2", "MatePad Pro 11", "MatePad Air", "MatePad 11.5", "MatePad 11", "MatePad SE 10.4", "MatePad T10s", "MatePad Paper", "MediaPad M6", "MediaPad T5"],
            "microsoft": ["Surface Pro 9", "Surface Pro 8", "Surface Pro 7+", "Surface Pro 7", "Surface Pro X", "Surface Go 3", "Surface Go 2", "Surface Go"]
        ]
        
        // 3d. Modelos de Consolas
        let consolasPorMarca = [
            "sony": ["PlayStation 5 (Disco)", "PlayStation 5 (Digital)", "PlayStation 5 Slim (Disco)", "PlayStation 5 Slim (Digital)", "PlayStation Portal", "PlayStation 4 Pro", "PlayStation 4 Slim", "PlayStation 4 (Fat)", "PlayStation 3 Super Slim", "PlayStation 3 Slim", "PlayStation 3 (Fat)", "PS Vita 2000", "PS Vita 1000", "PSP 3000", "PSP GO", "PlayStation Classic"],
            "microsoft": ["Xbox Series X", "Xbox Series S", "Xbox Series S (1TB)", "Xbox One X", "Xbox One S All-Digital", "Xbox One S", "Xbox One (Fat)", "Xbox 360 E", "Xbox 360 S", "Xbox 360 Pro", "Xbox 360 Arcade", "Xbox (Original)"],
            "nintendo": ["Switch OLED", "Switch (V2)", "Switch (V1)", "Switch Lite", "Wii U (Deluxe)", "Wii U (Basic)", "Wii (Family Edition)", "Wii (RVL-001)", "Wii Mini", "New Nintendo 3DS XL", "New Nintendo 3DS", "New Nintendo 2DS XL", "Nintendo 3DS XL", "Nintendo 3DS", "Nintendo 2DS", "Nintendo DSi XL", "Nintendo DSi", "Nintendo DS Lite", "SNES Classic", "NES Classic"],
            "asus": ["ROG Ally (Z1 Extreme)", "ROG Ally (Z1)"]
        ]
        
        // 3e. Computadoras de Escritorio (PC)
        let pcsPorMarca = [
            "apple": ["iMac 24 M3", "iMac 24 M1", "iMac 27 (Intel)", "Mac mini M2 Pro", "Mac mini M2", "Mac mini M1", "Mac Studio M2 Ultra", "Mac Studio M2 Max", "Mac Pro M2 Ultra", "Mac Pro (Tower)"],
            "hp": ["Omen 45L", "Omen 40L", "Omen 25L", "Victus 15L", "Envy Desktop", "Pavilion Desktop", "HP All-in-One 27", "HP All-in-One 24", "EliteDesk 800 G6", "ProDesk 400 G7"],
            "dell": ["Alienware Aurora R16", "Alienware Aurora R15", "XPS Desktop", "Inspiron Desktop", "Inspiron All-in-One", "OptiPlex 7000", "OptiPlex 5000", "OptiPlex 3000", "Precision 3000 Tower", "Precision 5000 Tower"],
            "lenovo": ["Legion Tower 7i", "Legion Tower 5i", "Legion Tower 5 AMD", "IdeaCentre Gaming 5", "IdeaCentre AIO 3", "IdeaCentre 3", "ThinkCentre M90a", "ThinkCentre M70q Tiny", "ThinkStation P360", "Yoga AIO 7"]
        ]

        // Consolidación de todos los diccionarios a la lista "models"
        let todosLosCatálogos = [
            ("celular", celularesPorMarca),
            ("laptop", laptopsPorMarca),
            ("tablet", tabletsPorMarca),
            ("consola", consolasPorMarca),
            ("pc", pcsPorMarca)
        ]
        
        for (categoria, marcasYModelos) in todosLosCatálogos {
            for (brand, list) in marcasYModelos {
                for phone in list {
                    models.append(["name": phone, "brand_id": brand, "category_id": categoria])
                }
            }
        }
        
        // Subir Categorías
        for category in categories {
            if let id = category["id"] as? String {
                db.collection("categories").document(id).setData(category) { error in
                    if let error = error {
                        print("❌ Error subiendo categoría \(id): \(error.localizedDescription)")
                    } else {
                        print("✅ Categoría \(id) subida con éxito.")
                    }
                }
            }
        }
        
        // Subir Marcas
        for brand in brands {
            if let id = brand["id"] as? String {
                db.collection("brands").document(id).setData(brand) { error in
                    if let error = error {
                        print("❌ Error subiendo marca \(id): \(error.localizedDescription)")
                    } else {
                        print("✅ Marca \(id) subida con éxito.")
                    }
                }
            }
        }
        
        // Subir Modelos con ID determinista para evitar duplicados en ejecuciones múltiples
        for model in models {
            guard let name = model["name"], let brandId = model["brand_id"], let categoryId = model["category_id"] else { continue }
            
            // Generamos un ID único y constante
            let safeName = name.replacingOccurrences(of: " ", with: "-")
                .replacingOccurrences(of: "(", with: "")
                .replacingOccurrences(of: ")", with: "")
                .replacingOccurrences(of: "+", with: "plus")
                .lowercased()
            let documentId = "\(categoryId)_\(brandId)_\(safeName)"
            
            db.collection("models").document(documentId).setData(model) { error in
                if let error = error {
                    print("❌ Error subiendo modelo \(name): \(error.localizedDescription)")
                } else {
                    print("✅ Modelo \(name) subido con éxito.")
                }
            }
        }
        
        print("✅ Proceso de actualización de base de datos completa iniciado.")
    }
}
