import Foundation
import SwiftUI

// MARK: - Source model

struct Source: Identifiable, Hashable {
    let id: String
    let name: String
    let url: String
    let rss: String
    let volet: String
    let type: String
    let langue: String
    let frequence: String
    let auteurs: String
    let description: String
    let tags: [String]
    let note: String?
}

extension Source {
    var voletColor: Color {
        switch volet.lowercased() {
        case "offensif":     return Color(red: 0.91, green: 0.32, blue: 0.27)
        case "re":           return Color(red: 0.30, green: 0.65, blue: 0.95)
        case "purple":       return Color(red: 0.65, green: 0.45, blue: 0.95)
        case "threat_intel": return Color(red: 0.95, green: 0.65, blue: 0.20)
        default:             return .gray
        }
    }

    var langueDrapeau: String {
        switch langue {
        case "fr":    return "🇫🇷"
        case "en":    return "🇬🇧"
        case "en+fr": return "🇬🇧 🇫🇷"
        default:      return "🌍"
        }
    }
}

// MARK: - Source registry

enum SourcesRegistry {
    /// Resolve a source from an Article's URL by matching the host.
    /// Returns nil if no source matches (the source UI button will hide).
    static func source(forArticleURL urlString: String) -> Source? {
        guard let host = URL(string: urlString)?.host?.lowercased() else { return nil }
        return all.first { source in
            guard let sourceHost = URL(string: source.url)?.host?.lowercased() else { return false }
            return host.contains(sourceHost) || sourceHost.contains(host)
        }
    }

    static let all: [Source] = [
        Source(
            id: "oxpat-blog",
            name: "0xPat Blog",
            url: "https://0xpat.github.io/",
            rss: "https://0xpat.github.io/feed.xml",
            volet: "offensif",
            type: "primaire",
            langue: "en",
            frequence: "Irrégulier (1-2/mois)",
            auteurs: "0xPat (chercheur indépendant anonyme)",
            description: "Blog technique spécialisé dans le développement de malware et les techniques offensives Windows. Couvre l'anti-analyse, l'injection de processus et l'évasion AV/EDR avec du code source complet.",
            tags: ["maldev", "EDR evasion", "Windows", "offensif"],
            note: nil
        ),
        Source(
            id: "assetnote-research",
            name: "Assetnote Research",
            url: "https://www.assetnote.io/resources/research",
            rss: "https://www.assetnote.io/resources/research/rss.xml",
            volet: "offensif",
            type: "primaire",
            langue: "en",
            frequence: "2-4/mois",
            auteurs: "Shubham Shah, Sean Yeoh, équipe Assetnote",
            description: "Recherche en sécurité web et découverte de vulnérabilités dans des services exposés sur Internet. Spécialisé dans l'attack surface management et les CVE sur des targets bug bounty de haut profil.",
            tags: ["web", "CVE", "bug bounty", "API security"],
            note: nil
        ),
        Source(
            id: "bhis-blog",
            name: "Black Hills Information Security",
            url: "https://www.blackhillsinfosec.com/blog/",
            rss: "https://www.blackhillsinfosec.com/feed/",
            volet: "purple",
            type: "primaire",
            langue: "en",
            frequence: "8-15/mois",
            auteurs: "John Strand, Jordan Drysdale, équipe BHIS",
            description: "Cabinet de pentest américain reconnu publiant régulièrement sur les techniques offensives et défensives. Fort sur Active Directory, detection engineering, et les techniques de red team en entreprise.",
            tags: ["red team", "Active Directory", "detection", "purple"],
            note: nil
        ),
        Source(
            id: "cert-fr",
            name: "CERT-FR / ANSSI",
            url: "https://www.cert.ssi.gouv.fr/",
            rss: "https://www.cert.ssi.gouv.fr/alerte/feed/",
            volet: "threat_intel",
            type: "primaire",
            langue: "fr",
            frequence: "Bulletins quotidiens, alertes 5-10/mois",
            auteurs: "ANSSI (Agence Nationale de la Sécurité des Systèmes d'Information)",
            description: "Centre gouvernemental français de réponse aux incidents cyber. Publie des alertes sur les CVE exploitées en France et des rapports techniques sur les campagnes APT observées par les équipes nationales.",
            tags: ["ANSSI", "alertes", "APT", "France", "institutionnel"],
            note: nil
        ),
        Source(
            id: "checkpoint-research",
            name: "Check Point Research",
            url: "https://research.checkpoint.com/",
            rss: "https://research.checkpoint.com/feed",
            volet: "purple",
            type: "primaire",
            langue: "en",
            frequence: "8-12/mois",
            auteurs: "Équipe CPR (~200 chercheurs). Oded Vanunu, Aviv Donenfeld, Jaromír Hořejší",
            description: "Équipe de recherche de l'éditeur Check Point couvrant les vulnérabilités, le reverse engineering de malware et la threat intelligence. Travaux récents sur l'IA comme vecteur d'attaque et les C2 via services web.",
            tags: ["CVE", "malware", "AI attacks", "threat intel"],
            note: nil
        ),
        Source(
            id: "christophe-tafani",
            name: "Christophe Tafani-Dereeper",
            url: "https://blog.christophetd.fr/",
            rss: "https://blog.christophetd.fr/feed/",
            volet: "purple",
            type: "primaire",
            langue: "en",
            frequence: "0,5-1/mois",
            auteurs: "Christophe Tafani-Dereeper (Cloud Security @ Datadog)",
            description: "Chercheur francophone basé en Suisse, créateur de Stratus Red Team (outil d'émulation adversaire cloud). Publie sur la sécurité AWS/Azure, Active Directory et les techniques offensives Windows.",
            tags: ["cloud", "AWS", "adversary emulation", "Windows", "francophone"],
            note: nil
        ),
        Source(
            id: "cisco-talos",
            name: "Cisco Talos Intelligence",
            url: "https://blog.talosintelligence.com/",
            rss: "https://blog.talosintelligence.com/rss/",
            volet: "threat_intel",
            type: "primaire",
            langue: "en",
            frequence: "12-20/mois",
            auteurs: "Cisco Talos (équipes IR, vulnerability research, malware reverse)",
            description: "L'une des plus grandes équipes de threat intelligence au monde, adossée à la télémétrie Cisco. Publie des rapports d'intrusion réels, des analyses de malware et un rapport trimestriel sur les tendances IR.",
            tags: ["threat intel", "malware", "IR", "APT", "CVE"],
            note: nil
        ),
        Source(
            id: "connor-mcgarr",
            name: "Connor McGarr's Blog",
            url: "https://connormcgarr.github.io/",
            rss: "https://connormcgarr.github.io/feed.xml",
            volet: "RE",
            type: "primaire",
            langue: "en",
            frequence: "Irrégulier (1-2/mois)",
            auteurs: "Connor McGarr (Microsoft MSRC, ex-CrowdStrike)",
            description: "Blog de recherche avancée sur l'exploitation Windows et les internals noyau. Reconnu pour ses séries sur l'exploitation kernel (pool spraying, arbitrary write primitives) et les techniques de bypass de mitigations.",
            tags: ["kernel", "exploitation", "Windows internals", "bypass"],
            note: nil
        ),
        Source(
            id: "darknet-diaries",
            name: "Darknet Diaries",
            url: "https://darknetdiaries.com/",
            rss: "https://feeds.megaphone.fm/darknetdiaries",
            volet: "threat_intel",
            type: "tertiaire",
            langue: "en",
            frequence: "Bi-mensuelle",
            auteurs: "Jack Rhysider",
            description: "Podcast de référence racontant de vraies histoires de cybercriminalité et d'espionnage numérique avec une approche journalistique documentée. Interviews directes de hackers et d'acteurs de l'industrie.",
            tags: ["podcast", "cybercrime", "storytelling", "threat intel"],
            note: nil
        ),
        Source(
            id: "doyensec-blog",
            name: "Doyensec Blog",
            url: "https://blog.doyensec.com/",
            rss: "https://blog.doyensec.com/feed.xml",
            volet: "offensif",
            type: "primaire",
            langue: "en",
            frequence: "2-4/mois",
            auteurs: "Équipe Doyensec (Luca Carettoni, Claudio Merloni et al.)",
            description: "Cabinet de sécurité spécialisé dans la recherche en vulnérabilités web et mobile. Publie des analyses techniques approfondies d'audits avec des PoC reproductibles sur des cibles reconnues.",
            tags: ["web security", "mobile", "CVE", "PoC", "audit"],
            note: nil
        ),
        Source(
            id: "elastic-security-labs",
            name: "Elastic Security Labs",
            url: "https://www.elastic.co/security-labs",
            rss: "https://www.elastic.co/security-labs/rss/feed.xml",
            volet: "RE",
            type: "primaire",
            langue: "en",
            frequence: "4-8/mois",
            auteurs: "Chercheurs Elastic (affiliation institutionnelle claire)",
            description: "Équipe de recherche de l'éditeur Elastic SIEM/EDR. Documente le fonctionnement interne des détections (règles, heuristiques, télémétries) et analyse les malwares avec IoC et règles YARA partagées.",
            tags: ["EDR", "SIEM", "detection", "YARA", "malware analysis"],
            note: nil
        ),
        Source(
            id: "freshrss-releases",
            name: "FreshRSS Releases",
            url: "https://github.com/FreshRSS/FreshRSS/releases",
            rss: "https://github.com/FreshRSS/FreshRSS/releases.atom",
            volet: "misc",
            type: "tertiaire",
            langue: "en",
            frequence: "1-2/mois",
            auteurs: "Équipe FreshRSS (open source)",
            description: "Flux de suivi des nouvelles versions de FreshRSS, l'agrégateur RSS utilisé comme collecteur dans ce système de veille. Permet de suivre les mises à jour et nouvelles fonctionnalités.",
            tags: ["outil", "open source", "veille infra"],
            note: nil
        ),
        Source(
            id: "know-your-adversary",
            name: "Know Your Adversary",
            url: "https://knowyouradversary.com/",
            rss: "https://knowyouradversary.com/feed",
            volet: "threat_intel",
            type: "secondaire",
            langue: "en",
            frequence: "Hebdomadaire",
            auteurs: "Newsletter indépendante",
            description: "Newsletter hebdomadaire centrée sur la connaissance des groupes d'attaquants, leurs TTPs et leur évolution. Synthèse des rapports de threat intelligence de la semaine avec un angle adversarial.",
            tags: ["newsletter", "adversary", "TTPs", "threat intel"],
            note: nil
        ),
        Source(
            id: "mdsec-blog",
            name: "MDSec Blog",
            url: "https://www.mdsec.co.uk/blog",
            rss: "https://www.mdsec.co.uk/feed/",
            volet: "purple",
            type: "primaire",
            langue: "en",
            frequence: "1-3/mois",
            auteurs: "Consultants MDSec (cabinet britannique certifié CREST/CHECK)",
            description: "Cabinet de conseil spécialisé en red teaming, publiant des recherches sur l'évasion EDR, le contournement AMSI et les techniques de process injection. Explique simultanément la technique offensive et le mécanisme de détection contourné.",
            tags: ["red team", "EDR bypass", "AMSI", "process injection", "purple"],
            note: nil
        ),
        Source(
            id: "microsoft-security-blog",
            name: "Microsoft Security Blog",
            url: "https://www.microsoft.com/en-us/security/blog/",
            rss: "https://www.microsoft.com/en-us/security/blog/feed/",
            volet: "threat_intel",
            type: "primaire",
            langue: "en",
            frequence: "8-15/mois",
            auteurs: "Microsoft Threat Intelligence (MSTIC, DART, +10 000 analystes)",
            description: "Blog officiel de Microsoft Security couvrant les campagnes APT attribuées et les techniques d'attaque avec mapping ATT&CK détaillé. Inclut des requêtes KQL, des IoCs et des règles Defender pour chaque rapport.",
            tags: ["Microsoft", "APT", "threat intel", "KQL", "ATT&CK"],
            note: nil
        ),
        Source(
            id: "nviso-labs",
            name: "NVISO Labs",
            url: "https://blog.nviso.eu/",
            rss: "https://blog.nviso.eu/feed/",
            volet: "RE",
            type: "primaire",
            langue: "en",
            frequence: "4-8/mois",
            auteurs: "Équipe NVISO (Daan Raman, Didier Stevens et al.)",
            description: "Équipe de recherche du cabinet belge NVISO, spécialisée dans l'analyse de malware, le DFIR et la detection engineering. Reconnu pour les analyses approfondies de documents Office malveillants et de loaders.",
            tags: ["malware analysis", "DFIR", "detection", "Office", "loaders"],
            note: nil
        ),
        Source(
            id: "portswigger-research",
            name: "PortSwigger Research",
            url: "https://portswigger.net/research",
            rss: "https://portswigger.net/research/rss",
            volet: "offensif",
            type: "primaire",
            langue: "en",
            frequence: "2-6/mois",
            auteurs: "James Kettle (directeur recherche), équipe PortSwigger",
            description: "Équipe de recherche de l'éditeur de Burp Suite. Publie des recherches offensives web avancées avec PoC reproductibles, présentées dans les grandes conférences (Black Hat, DEF CON). Expert en HTTP desync et request smuggling.",
            tags: ["web security", "Burp Suite", "HTTP", "PoC", "Black Hat"],
            note: nil
        ),
        Source(
            id: "outflank-blog",
            name: "Outflank (Fortra)",
            url: "https://www.outflank.nl/blog/",
            rss: "https://www.outflank.nl/blog/feed",
            volet: "offensif",
            type: "primaire",
            langue: "en",
            frequence: "1-3/mois",
            auteurs: "Stan Hegt, Pieter Ceelen, Marc Smeets (Amsterdam, Fortra)",
            description: "Cabinet red team de référence basé aux Pays-Bas, racheté par Fortra (éditeur de Cobalt Strike). Publie des recherches de pointe sur l'évasion EDR, les BOFs, les COM objects piégés et l'exploitation VTL1/enclaves sécurisées.",
            tags: ["red team", "EDR bypass", "Cobalt Strike", "BOF", "Windows"],
            note: nil
        ),
        Source(
            id: "quarkslab-blog",
            name: "Quarkslab Blog",
            url: "https://blog.quarkslab.com/",
            rss: "https://blog.quarkslab.com/feeds/all.rss.xml",
            volet: "RE",
            type: "primaire",
            langue: "en",
            frequence: "2-4/mois",
            auteurs: "Équipe Quarkslab (Paris, fondé 2011)",
            description: "Cabinet français de recherche en sécurité spécialisé dans le reverse engineering profond (firmware, mobile, crypto, obfuscation). Créateurs de QBDI, TritonDSE et Pyrrha. Intervient à Pwn2Own et SSTIC.",
            tags: ["reverse engineering", "firmware", "crypto", "obfuscation", "français"],
            note: nil
        ),
        Source(
            id: "hacktricks-commits",
            name: "HackTricks (Recent Commits)",
            url: "https://book.hacktricks.wiki/",
            rss: "https://github.com/HackTricks-wiki/hacktricks/commits/master.atom",
            volet: "offensif",
            type: "tertiaire",
            langue: "en",
            frequence: "Quasi-quotidienne (commits)",
            auteurs: "Carlos Polop (Halborn, OSCP/OSWE, DEF CON 31 speaker)",
            description: "Wiki de référence en pentest/red team, mis à jour en continu avec des techniques couvrant Windows, Linux, AD, Kubernetes et le cloud. Le flux de commits permet de suivre les nouvelles techniques ajoutées quotidiennement.",
            tags: ["wiki", "pentest", "red team", "Active Directory", "référence"],
            note: nil
        ),
        Source(
            id: "riskinsight-wavestone",
            name: "RiskInsight — Wavestone",
            url: "https://www.riskinsight-wavestone.com/",
            rss: "https://www.riskinsight-wavestone.com/feed/",
            volet: "threat_intel",
            type: "secondaire",
            langue: "fr",
            frequence: "4-8/mois",
            auteurs: "Consultants Wavestone (équipes cyber)",
            description: "Blog du cabinet de conseil français Wavestone, pivot entre la gouvernance cyber et les analyses techniques. Couvre les APT observés en France, NIS2, Entra ID et relaie les conférences francophones (leHACK, SSTIC).",
            tags: ["France", "gouvernance", "APT", "Entra ID", "francophone"],
            note: nil
        ),
        Source(
            id: "risky-business",
            name: "Risky Business",
            url: "https://risky.biz/",
            rss: "https://risky.biz/feeds/risky-business/",
            volet: "threat_intel",
            type: "tertiaire",
            langue: "en",
            frequence: "Podcast 1-2/sem, newsletter 4×/sem",
            auteurs: "Patrick Gray, Adam Boileau, Catalin Cimpanu",
            description: "Podcast et newsletter de référence pour les actualités cyber avec un angle stratégique et technique. Patrick Gray et ses invités analysent les incidents majeurs, les vulnérabilités critiques et la politique cyber internationale.",
            tags: ["podcast", "news", "threat intel", "politique cyber"],
            note: nil
        ),
        Source(
            id: "securelist",
            name: "Securelist — Kaspersky GReAT",
            url: "https://securelist.com/",
            rss: "https://securelist.com/feed/",
            volet: "RE",
            type: "primaire",
            langue: "en",
            frequence: "8-15/mois",
            auteurs: "Global Research and Analysis Team (GReAT)",
            description: "Blog de recherche de l'équipe GReAT de Kaspersky, référence mondiale pour l'analyse de malware APT (Equation Group, Stuxnet, Lazarus). Publie des analyses très approfondies avec règles YARA et IoCs complets.",
            tags: ["APT", "malware analysis", "YARA", "GReAT", "Kaspersky"],
            note: "Entreprise russe — restrictions US/UK/UE depuis 2022 à mentionner dans un cadre académique."
        ),
        Source(
            id: "sentinelone-labs",
            name: "SentinelOne Labs",
            url: "https://www.sentinelone.com/labs/",
            rss: "https://www.sentinelone.com/feed/",
            volet: "RE",
            type: "primaire",
            langue: "en",
            frequence: "4-8/mois",
            auteurs: "Chercheurs SentinelLabs (éditeur EDR coté en bourse)",
            description: "Équipe de recherche de l'éditeur EDR SentinelOne. Décortique les techniques offensives utilisées par les attaquants réels et expose les points de détection exploitables côté défensif avec IoCs et analyses détaillées.",
            tags: ["EDR", "malware analysis", "threat intel", "IoC", "detection"],
            note: nil
        ),
        Source(
            id: "stalkphish",
            name: "StalkPhish",
            url: "https://stalkphish.com/",
            rss: "https://stalkphish.com/feed/",
            volet: "threat_intel",
            type: "primaire",
            langue: "en+fr",
            frequence: "1-3/mois",
            auteurs: "Thomas Damonneville (fondateur, présence média France)",
            description: "Source spécialisée dans l'analyse de kits de phishing et l'usurpation de marque. Expose le fonctionnement technique des PhaaS comme Greatness et les campagnes ciblant les services français (CPF, Ameli).",
            tags: ["phishing", "brand impersonation", "PhaaS", "France", "threat intel"],
            note: nil
        ),
        Source(
            id: "dfir-report",
            name: "The DFIR Report",
            url: "https://thedfirreport.com/",
            rss: "https://thedfirreport.com/feed/",
            volet: "purple",
            type: "primaire",
            langue: "en",
            frequence: "2-4/mois",
            auteurs: "Équipe DFIR Report (identifiée, reconnue en communauté DFIR)",
            description: "Rapports d'intrusions réelles extrêmement détaillés, systématiquement mappés sur MITRE ATT&CK avec timelines précises et IoCs partagés. Chaque rapport couvre à la fois les TTPs offensifs et les artefacts forensiques détectables côté défensif.",
            tags: ["DFIR", "incident response", "ATT&CK", "forensics", "IoC"],
            note: nil
        ),
        Source(
            id: "red-canary-blog",
            name: "The Red Canary Blog",
            url: "https://redcanary.com/blog/",
            rss: "https://redcanary.com/blog/feed/",
            volet: "RE",
            type: "primaire",
            langue: "en",
            frequence: "4-10/mois",
            auteurs: "Équipe Red Canary (MDR), auteurs nommés",
            description: "Blog de l'entreprise MDR Red Canary, auteur du Threat Detection Report annuel. Explique comment chaque technique offensive est détectée avec les télémétries exactes (ETW, Sysmon, kernel callbacks) et mappe sur ATT&CK.",
            tags: ["MDR", "detection", "ETW", "Sysmon", "ATT&CK"],
            note: nil
        ),
        Source(
            id: "trail-of-bits",
            name: "Trail of Bits Blog",
            url: "https://blog.trailofbits.com/",
            rss: "https://blog.trailofbits.com/feed/",
            volet: "RE",
            type: "primaire",
            langue: "en",
            frequence: "6-12/mois",
            auteurs: "Dan Guido (CEO/cofondateur), équipe ML/AI security",
            description: "Cabinet américain de recherche en sécurité reconnu pour ses travaux sur la cryptographie, la sécurité des compilateurs et l'analyse de code. Créateurs de iVerify, Slither (Solidity analyzer) et CHECC.",
            tags: ["crypto", "compilateurs", "AI security", "audit", "open source"],
            note: nil
        ),
        Source(
            id: "microsoft-threat-intel",
            name: "Microsoft Threat Intelligence",
            url: "https://www.microsoft.com/en-us/security/blog/topic/threat-intelligence/",
            rss: "https://www.microsoft.com/en-us/security/blog/feed/",
            volet: "threat_intel",
            type: "primaire",
            langue: "en",
            frequence: "8-15/mois",
            auteurs: "Microsoft Threat Intelligence (MSTIC), DART",
            description: "Section threat intelligence du blog Microsoft Security, couvrant les attributions d'acteurs étatiques (Storm-, Blizzard-, Typhoon-) avec des indicateurs de compromission et des requêtes de chasse aux menaces pour Sentinel/Defender.",
            tags: ["Microsoft", "APT", "Sentinel", "threat intel", "attribution"],
            note: "Même flux RSS que Microsoft Security Blog — filtrage par catégorie dans FreshRSS."
        ),
        Source(
            id: "trustedsec-blog",
            name: "TrustedSec Blog",
            url: "https://trustedsec.com/blog",
            rss: "https://trustedsec.com/feed.rss",
            volet: "purple",
            type: "primaire",
            langue: "en",
            frequence: "8-15/mois",
            auteurs: "Dave Kennedy (fondateur, créateur SET), Carlos Perez, Justin Elze",
            description: "Cabinet américain de red team fondé par Dave Kennedy. Combine recherche offensive (Kerberos, Entra ID) et défensive (série complète sur les sources de log Windows). Publie des outils open source reconnus comme COFFLoader.",
            tags: ["red team", "Kerberos", "logging", "Windows", "purple"],
            note: nil
        ),
        Source(
            id: "unit42",
            name: "Unit 42 — Palo Alto Networks",
            url: "https://unit42.paloaltonetworks.com/",
            rss: "https://unit42.paloaltonetworks.com/feed/",
            volet: "threat_intel",
            type: "primaire",
            langue: "en",
            frequence: "10-15/mois",
            auteurs: "Sam Rubin (SVP), équipe Unit 42 (+200 chercheurs)",
            description: "Équipe de threat intelligence de Palo Alto Networks avec adversary playbooks publics en STIX et attribution formelle (Boggy Serpens, Stately Taurus). Le rapport IR annuel est une référence sur les tendances d'attaque observées mondialement.",
            tags: ["threat intel", "APT", "STIX", "IR report", "attribution"],
            note: nil
        ),
        Source(
            id: "volexity-blog",
            name: "Volexity Blog",
            url: "https://www.volexity.com/blog/",
            rss: "https://www.volexity.com/blog/feed/",
            volet: "RE",
            type: "primaire",
            langue: "en",
            frequence: "2-4/mois",
            auteurs: "Steven Adair (fondateur), Tom Lancaster, équipe Volexity",
            description: "Cabinet de threat intelligence spécialisé dans la forensique mémoire et le tracking d'APT. Reconnu pour la découverte de Cozy Bear post-compromission et ses analyses d'implants en mémoire sans fichier.",
            tags: ["forensics", "APT", "memory analysis", "espionnage", "threat intel"],
            note: nil
        ),
        Source(
            id: "welivesecurity",
            name: "WeLiveSecurity — ESET",
            url: "https://www.welivesecurity.com/en/",
            rss: "https://www.welivesecurity.com/en/rss/feed/",
            volet: "RE",
            type: "primaire",
            langue: "en",
            frequence: "15-20/mois",
            auteurs: "ESET Research (~600 chercheurs)",
            description: "Blog de recherche d'ESET couvrant les analyses de malware APT et les campagnes de cyberattaques mondiales. Publie des analyses avec hashes, IoCs et règles YARA. Référence pour les attributions d'acteurs Corée du Nord, Russie et Chine.",
            tags: ["APT", "malware analysis", "YARA", "ESET", "IoC"],
            note: nil
        ),
        Source(
            id: "winsider",
            name: "Winsider Seminars",
            url: "https://www.alex-ionescu.com/",
            rss: "https://www.alex-ionescu.com/feed/",
            volet: "RE",
            type: "primaire",
            langue: "en",
            frequence: "Très rare",
            auteurs: "Alex Ionescu (co-auteur Windows Internals), Yarden Shafir",
            description: "Blog de référence absolue sur les Windows Internals par Alex Ionescu, co-auteur du livre Windows Internals chez Microsoft Press. Couvre les mécanismes de sécurité Windows les plus profonds : VTL, IUM, Secure Kernel, et les primitives noyau.",
            tags: ["Windows Internals", "kernel", "VTL", "Secure Kernel", "référence"],
            note: nil
        ),
        Source(
            id: "xpn-infosec",
            name: "XPN InfoSec Blog",
            url: "https://blog.xpnsec.com/",
            rss: "https://blog.xpnsec.com/rss/",
            volet: "offensif",
            type: "primaire",
            langue: "en",
            frequence: "Irrégulier (1-2/mois)",
            auteurs: "Adam Chester (@_xpn_, SpecterOps)",
            description: "Blog de recherche offensive de haut niveau par Adam Chester de SpecterOps. Spécialisé dans les techniques Windows avancées : injection via COM, abus du CLR .NET, persistence créative et techniques de red team innovantes présentées à DEF CON/Black Hat.",
            tags: ["red team", "COM", ".NET CLR", "persistence", "SpecterOps"],
            note: nil
        ),
        Source(
            id: "modexp",
            name: "modexp",
            url: "https://modexp.wordpress.com/",
            rss: "https://modexp.wordpress.com/feed/",
            volet: "offensif",
            type: "primaire",
            langue: "en",
            frequence: "Irrégulier (1-2/mois)",
            auteurs: "modexp (chercheur indépendant anonyme)",
            description: "Blog de recherche technique de haut niveau sur le développement de shellcode, les Windows Internals et les techniques offensives avancées. Couvre ARM64, RISC-V, in-memory execution et les structures internes de ntdll/ntoskrnl.",
            tags: ["shellcode", "Windows Internals", "ntdll", "ARM64", "in-memory"],
            note: nil
        ),
        Source(
            id: "secret-club",
            name: "secret.club",
            url: "https://secret.club/",
            rss: "https://secret.club/feed.xml",
            volet: "RE",
            type: "primaire",
            langue: "en",
            frequence: "Irrégulier (1-3/mois)",
            auteurs: "can1357 et contributeurs (collectif de chercheurs)",
            description: "Collectif de chercheurs indépendants publiant des recherches très techniques sur les hyperviseurs, la mémoire Windows, le reverse engineering EPT et les techniques anti-EDR. Connu pour les travaux sur UEFI hypervisors et PE section header spoofing.",
            tags: ["hypervisor", "EPT", "Windows", "RE", "anti-EDR"],
            note: nil
        ),
        Source(
            id: "tldr-sec",
            name: "tl;dr sec",
            url: "https://tldrsec.com/",
            rss: "https://rss.beehiiv.com/feeds/xgTKUmMmUm.xml",
            volet: "purple",
            type: "tertiaire",
            langue: "en",
            frequence: "Hebdomadaire",
            auteurs: "Clint Gibler (ex-NCC Group, ex-Semgrep)",
            description: "Newsletter hebdomadaire de curation de la sécurité offensive et défensive par Clint Gibler. Synthétise les meilleurs articles de la semaine couvrant AppSec, DevSecOps et la recherche Purple Team. Plus de 50 000 abonnés.",
            tags: ["newsletter", "curation", "hebdomadaire", "purple", "AppSec"],
            note: nil
        ),
        Source(
            id: "watchtowr-labs",
            name: "watchTowr Labs",
            url: "https://labs.watchtowr.com/",
            rss: "https://labs.watchtowr.com/rss/",
            volet: "offensif",
            type: "primaire",
            langue: "en",
            frequence: "4-8/mois",
            auteurs: "Benjamin Harris (CEO), équipe watchTowr",
            description: "Cabinet de recherche en vulnérabilités publiant des exploits et des analyses de CVE avec code PoC complet. Reconnu pour ses analyses rapides et détaillées de vulnérabilités critiques dans des produits enterprise (Fortinet, Ivanti, Palo Alto, Cisco).",
            tags: ["exploit", "CVE", "PoC", "enterprise", "vulnérabilités"],
            note: nil
        )
    ]
}
