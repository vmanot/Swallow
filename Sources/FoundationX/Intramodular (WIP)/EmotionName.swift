//
// Copyright (c) Vatsal Manot
//

import Swallow

@_spi(Internal)
public enum EmotionName {
    public enum Aristotelian: String, CaseIterable, Codable, Hashable, Named {
        case anger
        case calmness
        case friendship
        case fear
        case courage
        case shame
        case confidence
        case kindness
        case cruelty
        case pity
        case indignation
        case envy
        case love
        
        public var name: String {
            switch self {
                case .anger:
                    return "Anger"
                case .calmness:
                    return "Calmness"
                case .friendship:
                    return "Friendship"
                case .fear:
                    return "Fear"
                case .courage:
                    return "Courage"
                case .shame:
                    return "Shame"
                case .confidence:
                    return "Confidence"
                case .kindness:
                    return "Kindness"
                case .cruelty:
                    return "Cruelty"
                case .pity:
                    return "Pity"
                case .indignation:
                    return "Indignation"
                case .envy:
                    return "Envy"
                case .love:
                    return "Love"
            }
        }
    }
    
    public enum Berkley: String, CaseIterable, Codable, Hashable, Named {
        case admiration
        case adoration
        case aestheticAppreciation
        case amusement
        case anxiety
        case awe
        case awkwardness
        case boredom
        case calmness
        case confusion
        case craving
        case disgust
        case empatheticPain
        case entrancement
        case envy
        case excitement
        case fear
        case horror
        case interest
        case joy
        case nostalgia
        case romance
        case sadness
        case satisfaction
        case sexualDesire
        case sympathy
        case triump
        
        public var name: String {
            switch self {
                case .admiration:
                    return "Admiration"
                case .adoration:
                    return "Adoration"
                case .aestheticAppreciation:
                    return "Aesthetic Appreciation"
                case .amusement:
                    return "Amusement"
                case .anxiety:
                    return "Anxiety"
                case .awe:
                    return "Awe"
                case .awkwardness:
                    return "Awkwardness"
                case .boredom:
                    return "Boredom"
                case .calmness:
                    return "Calmness"
                case .confusion:
                    return "Confusion"
                case .craving:
                    return "Craving"
                case .disgust:
                    return "Disgust"
                case .empatheticPain:
                    return "Empathetic Pain"
                case .entrancement:
                    return "Entrancement"
                case .envy:
                    return "Envy"
                case .excitement:
                    return "Excitement"
                case .fear:
                    return "Fear"
                case .horror:
                    return "Horror"
                case .interest:
                    return "Interest"
                case .joy:
                    return "Joy"
                case .nostalgia:
                    return "Nostalgia"
                case .romance:
                    return "Romance"
                case .sadness:
                    return "Sadness"
                case .satisfaction:
                    return "Satisfaction"
                case .sexualDesire:
                    return "Sexual Desire"
                case .sympathy:
                    return "Sympathy"
                case .triump:
                    return "Triump"
            }
        }
    }
    
    public enum Plutchik: String, CaseIterable, Codable, Hashable, Named {
        case fear
        case anger
        case sadness
        case joy
        case disgust
        case surprise
        case trust
        case anticipation
        
        public var name: String {
            switch self {
                case .fear:
                    return "Fear"
                case .anger:
                    return "Anger"
                case .sadness:
                    return "Sadness"
                case .joy:
                    return "Joy"
                case .disgust:
                    return "Disgust"
                case .surprise:
                    return "Surprise"
                case .trust:
                    return "Trust"
                case .anticipation:
                    return "Anticipation"
            }
        }
    }
}
