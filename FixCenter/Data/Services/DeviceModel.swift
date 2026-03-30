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
            ["id": "consola", "name": "Consolas de Videojuegos", "icon": "gamecontroller"],
            ["id": "monitor", "name": "Monitores de PC", "icon": "display"],
            ["id": "tv", "name": "Televisiones", "icon": "tv"]
        ]
        
        // 2. Catálogo de Marcas (Actualizado con marcas de TV/Monitores)
        let brands = [
            ["id": "apple", "name": "Apple", "categories": ["celular", "laptop", "tablet", "pc", "monitor", "tv"]],
            ["id": "samsung", "name": "Samsung", "categories": ["celular", "tablet", "laptop", "monitor", "tv"]],
            ["id": "sony", "name": "Sony (PlayStation)", "categories": ["consola", "monitor", "tv"]],
            ["id": "nintendo", "name": "Nintendo", "categories": ["consola"]],
            ["id": "microsoft", "name": "Microsoft (Xbox)", "categories": ["consola", "laptop", "tablet"]],
            ["id": "asus", "name": "Asus", "categories": ["laptop", "pc", "consola", "monitor"]],
            ["id": "xiaomi", "name": "Xiaomi", "categories": ["celular", "tablet", "monitor", "tv"]],
            ["id": "huawei", "name": "Huawei", "categories": ["celular", "laptop", "tablet", "monitor"]],
            ["id": "motorola", "name": "Motorola", "categories": ["celular"]],
            ["id": "oppo", "name": "OPPO", "categories": ["celular", "tv"]],
            ["id": "vivo", "name": "Vivo", "categories": ["celular"]],
            ["id": "realme", "name": "Realme", "categories": ["celular", "tv"]],
            ["id": "oneplus", "name": "OnePlus", "categories": ["celular", "tablet", "tv"]],
            ["id": "google", "name": "Google", "categories": ["celular", "tablet"]],
            ["id": "lenovo", "name": "Lenovo", "categories": ["laptop", "tablet", "pc", "monitor"]],
            ["id": "hp", "name": "HP", "categories": ["laptop", "pc", "monitor"]],
            ["id": "dell", "name": "Dell", "categories": ["laptop", "pc", "monitor"]],
            ["id": "acer", "name": "Acer", "categories": ["laptop", "pc", "monitor"]],
            ["id": "lg", "name": "LG", "categories": ["monitor", "tv"]],
            ["id": "hisense", "name": "Hisense", "categories": ["tv"]],
            ["id": "tcl", "name": "TCL", "categories": ["tv"]],
            ["id": "benq", "name": "BenQ", "categories": ["monitor"]],
            ["id": "aoc", "name": "AOC", "categories": ["monitor"]]
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

        // 3f. Modelos de Monitores de PC
        let monitoresPorMarca = [
            "samsung": ["Odyssey G9 49\"", "Odyssey G8 34\"", "Odyssey G7 32\"", "Odyssey G5 27\"", "Smart Monitor M8 32\"", "Smart Monitor M7 32\"", "UR55 28\" 4K", "CRG9 49\" Curved", "ViewFinity S8 32\"", "ViewFinity S6 27\""],
            "lg": ["UltraGear 27\" OLED 240Hz", "UltraGear 32\" 144Hz", "UltraGear 34\" Curved", "UltraWide 38\" Curved", "DualUp 28\" Ergo", "UltraFine 5K 27\"", "UltraFine 4K 24\"", "32UN880-B Ergo", "27QN600-B 27\"", "Monitor 24\" IPS FHD"],
            "sony": ["Inzone M9 27\" 4K", "Inzone M3 27\" FHD"],
            "asus": ["ROG Swift OLED PG27AQDM", "ROG Swift 360Hz PG259QN", "ROG Strix XG27AQ", "ROG Strix XG32UQ", "TUF Gaming VG27AQ", "TUF Gaming VG249Q", "ProArt Display PA279CV", "ProArt Display PA329CV", "ProArt PA248QV", "ZenScreen MB16ACE"],
            "lenovo": ["Legion Y27q-20", "Legion Y25-25", "Legion Y32p-30", "ThinkVision P27h-20", "ThinkVision T24i-20", "ThinkVision M14 Portable", "Lenovo G27q-20", "Lenovo L24q-30", "Lenovo Q27q-10", "Lenovo L28u-30"],
            "hp": ["Omen 27c", "Omen 25i", "Omen 34c M", "X24ih Gaming Monitor", "Z24n G3 WUXGA", "Z27q G3 QHD", "M27f FHD", "M24fwa FHD", "E24 G4 FHD", "X34 WQHD Gaming"],
            "dell": ["Alienware 34 Curved QD-OLED", "Alienware 27 Gaming 240Hz", "Alienware 25 Gaming", "UltraSharp 32 4K USB-C", "UltraSharp 27 4K", "UltraSharp 34 Curved USB-C", "S2722QC 27\" 4K", "S2421HGF 24\" Gaming", "S3222DGM Curved", "P2720D 27\" QHD"],
            "acer": ["Predator XB273K", "Predator X38", "Nitro XV272U", "Nitro EI242QRP", "Nitro XV240Y", "ConceptD CP3", "CB272U 27\"", "SB220Q 21.5\"", "R240HY bidx 23.8\"", "Aopen 27HC5R"],
            "benq": ["Mobiuz EX2710S", "Mobiuz EX3210U 4K", "Mobiuz EX3410R Curved", "PD2700U 4K Designer", "PD3220U Mac-Ready", "GW2480T 24\" Eye-care", "GW2780 27\"", "Zowie XL2546K E-Sports", "Zowie XL2411P", "Zowie XL2566K 360Hz"],
            "aoc": ["CQ27G2 Curved", "CU34G2X 34\" Curved", "24G2 Gaming 144Hz", "27G2 Gaming IPS", "C24G1 Curved Gaming", "U2790VQ 27\" 4K", "I2267FW 22\"", "Agon AG493UCX 49\"", "Agon PRO AG254FG", "E1659FWU Portable"]
        ]
        
        // 3g. Modelos de Televisiones (TV)
        let tvsPorMarca = [
            "samsung": ["Neo QLED 8K 85\" QN900C", "Neo QLED 4K 75\" QN90C", "OLED S95C 65\"", "OLED S90C 55\"", "The Frame 65\"", "The Frame 55\"", "QLED Q80C 65\"", "Crystal UHD CU8000 75\"", "Crystal UHD CU7000 50\"", "The Serif 43\""],
            "lg": ["OLED evo G3 77\"", "OLED evo G3 65\"", "OLED C3 65\"", "OLED C3 55\"", "OLED B3 65\"", "QNED 85 Series 75\"", "QNED 80 Series 65\"", "NanoCell 75 Series 86\"", "NanoCell 75\" 4K", "UHD 80 Series 55\""],
            "sony": ["Bravia XR A95L 77\" QD-OLED", "Bravia XR A95L 65\" QD-OLED", "Bravia XR A80L 65\" OLED", "Bravia XR A80L 55\" OLED", "Bravia XR X93L 75\" Mini LED", "Bravia XR X90L 65\" Full Array LED", "Bravia X85K 55\"", "Bravia X77L 43\""],
            "hisense": ["ULED U8K 75\" Mini-LED", "ULED U8K 65\" Mini-LED", "ULED U7K 65\"", "ULED U7K 55\"", "U6K Series 65\"", "U6K Series 50\"", "A6 Series 75\" 4K", "A6 Series 43\" 4K", "A4 Series 40\" FHD", "A4 Series 32\" HD"],
            "tcl": ["QM8 85\" Mini-LED", "QM8 65\" Mini-LED", "Q7 75\" QLED", "Q7 55\" QLED", "6-Series 65\" Mini-LED", "5-Series 50\" QLED", "4-Series 65\" 4K", "4-Series 43\" 4K", "Class S3 40\" FHD", "Class S3 32\" HD"],
            "xiaomi": ["TV Q1 75\" QLED", "TV P1 55\" 4K", "TV P1 43\" 4K", "TV A2 55\" 4K", "TV A2 43\" FHD", "TV A2 32\" HD", "Smart TV 5A 43\"", "Smart TV X Series 50\""]
        ]

        // Consolidación de todos los diccionarios a la lista "models"
        let todosLosCatálogos = [
            ("celular", celularesPorMarca),
            ("laptop", laptopsPorMarca),
            ("tablet", tabletsPorMarca),
            ("consola", consolasPorMarca),
            ("pc", pcsPorMarca),
            ("monitor", monitoresPorMarca),
            ("tv", tvsPorMarca)
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
