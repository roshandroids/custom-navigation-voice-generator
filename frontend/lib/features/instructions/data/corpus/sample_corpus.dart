import 'package:navigation_voice_generator/features/instructions/data/corpus/corpus_entry.dart';
import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction_category.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_language.dart';

/// A curated sample corpus for the Flutter MVP, mirroring the finalized
/// benchmark corpora. Uses the finalized Nepali text and natural English
/// phrasing from the English corpus — not translations of each other.
final class SampleCorpus {
  const SampleCorpus._();

  static List<CorpusEntry> forLanguage(VoiceLanguage language) => switch (language) {
        VoiceLanguage.nepali => nepali,
        VoiceLanguage.english => english,
      };

  static const nepali = <CorpusEntry>[
    CorpusEntry(id: 'turn_left_001', category: InstructionCategory.directions, situation: 'बायाँ मोड', text: 'देब्रे मोड्नुहोस्।'),
    CorpusEntry(id: 'turn_right_001', category: InstructionCategory.directions, situation: 'दायाँ मोड', text: 'दायाँ मोड्नुहोस्।'),
    CorpusEntry(id: 'keep_left_002', category: InstructionCategory.directions, situation: 'बायाँ रहनुहोस्', text: 'देब्रेतिर लाग्नुहोस्।'),
    CorpusEntry(id: 'continue_straight_002', category: InstructionCategory.directions, situation: 'सीधा जानुहोस्', text: 'सीधा जानुहोस्।'),
    CorpusEntry(id: 'uturn_002', category: InstructionCategory.directions, situation: 'यू-टर्न', text: 'यू-टर्न लिनुहोस्।'),
    CorpusEntry(id: 'roundabout_002', category: InstructionCategory.directions, situation: 'गोलचक्कर', text: 'गोलचक्करमा पहिलो निकास लिनुहोस्।'),
    CorpusEntry(id: 'exit_002', category: InstructionCategory.directions, situation: 'निकास', text: 'अर्को निकास लिनुहोस्।'),
    CorpusEntry(id: 'distance_100m_002', category: InstructionCategory.distances, situation: '१०० मिटर', text: 'सय मिटरपछि देब्रे मोड्नुहोस्।'),
    CorpusEntry(id: 'distance_500m_002', category: InstructionCategory.distances, situation: '५०० मिटर', text: 'पाँच सय मिटरपछि दायाँतिर लाग्नुहोस्।'),
    CorpusEntry(id: 'distance_1km_002', category: InstructionCategory.distances, situation: '१ किलोमिटर', text: 'एक किलोमिटरपछि दायाँ मोड्नुहोस्।'),
    CorpusEntry(id: 'distance_200m_001', category: InstructionCategory.distances, situation: '२०० मिटर', text: 'दुई सय मिटरपछि गोलचक्कर आउँछ।'),
    CorpusEntry(id: 'distance_300m_001', category: InstructionCategory.distances, situation: '३०० मिटर', text: 'तीन सय मिटरपछि सीधा जानुहोस्।'),
    CorpusEntry(id: 'traffic_ahead_001', category: InstructionCategory.traffic, situation: 'ट्राफिक', text: 'अगाडि ट्राफिक जाम छ।'),
    CorpusEntry(id: 'traffic_heavy_002', category: InstructionCategory.traffic, situation: 'भारी ट्राफिक', text: 'बाटोमा धेरै ट्राफिक छ।'),
    CorpusEntry(id: 'accident_ahead_002', category: InstructionCategory.traffic, situation: 'दुर्घटना', text: 'अगाडि दुर्घटना छ।'),
    CorpusEntry(id: 'construction_002', category: InstructionCategory.traffic, situation: 'निर्माण', text: 'अगाडि बाटो बनिरहेको छ।'),
    CorpusEntry(id: 'road_closed_002', category: InstructionCategory.traffic, situation: 'बाटो बन्द', text: 'बाटो बन्द छ।'),
    CorpusEntry(id: 'speed_camera_001', category: InstructionCategory.enforcement, situation: 'स्पिड क्यामेरा', text: 'अगाडि स्पिड क्यामेरा छ।'),
    CorpusEntry(id: 'speed_camera_002', category: InstructionCategory.enforcement, situation: 'स्पिड क्यामेरा', text: 'ल, अगाडि स्पिड क्यामेरा छ है। अलि बिस्तारै जाऊ।'),
    CorpusEntry(id: 'redlight_camera_002', category: InstructionCategory.enforcement, situation: 'रातो बत्ती क्यामेरा', text: 'अगाडिको रातो बत्तीमा क्यामेरा छ। रोकिनुहोस्।'),
    CorpusEntry(id: 'police_002', category: InstructionCategory.enforcement, situation: 'पुलिस', text: 'अगाडि पुलिस छ।'),
    CorpusEntry(id: 'arrival_002', category: InstructionCategory.arrival, situation: 'गन्तव्य', text: 'तपाईं गन्तव्यमा आइपुग्नुभयो।'),
    CorpusEntry(id: 'arrival_005', category: InstructionCategory.arrival, situation: 'गन्तव्य नजिक', text: 'तपाईंको गन्तव्य देब्रेतिर छ।'),
  ];

  static const english = <CorpusEntry>[
    CorpusEntry(id: 'en_turn_left_001', category: InstructionCategory.directions, situation: 'Turn left', text: 'Turn left.'),
    CorpusEntry(id: 'en_turn_right_001', category: InstructionCategory.directions, situation: 'Turn right', text: 'Turn right.'),
    CorpusEntry(id: 'en_keep_left_001', category: InstructionCategory.directions, situation: 'Keep left', text: 'Keep left.'),
    CorpusEntry(id: 'en_keep_right_001', category: InstructionCategory.directions, situation: 'Keep right', text: 'Keep right.'),
    CorpusEntry(id: 'en_continue_straight_001', category: InstructionCategory.directions, situation: 'Continue straight', text: 'Continue straight.'),
    CorpusEntry(id: 'en_uturn_001', category: InstructionCategory.directions, situation: 'U-turn', text: 'Make a U-turn.'),
    CorpusEntry(id: 'en_roundabout_001', category: InstructionCategory.directions, situation: 'Roundabout', text: 'At the roundabout, take the first exit.'),
    CorpusEntry(id: 'en_exit_001', category: InstructionCategory.directions, situation: 'Exit', text: 'Take the next exit.'),
    CorpusEntry(id: 'en_distance_100m_001', category: InstructionCategory.distances, situation: '100 meters', text: 'In one hundred meters, turn left.'),
    CorpusEntry(id: 'en_distance_500m_001', category: InstructionCategory.distances, situation: '500 meters', text: 'In five hundred meters, keep right.'),
    CorpusEntry(id: 'en_distance_1km_001', category: InstructionCategory.distances, situation: '1 kilometer', text: 'In one kilometer, take the next exit.'),
    CorpusEntry(id: 'en_traffic_ahead_001', category: InstructionCategory.traffic, situation: 'Traffic ahead', text: 'Traffic ahead.'),
    CorpusEntry(id: 'en_traffic_heavy_001', category: InstructionCategory.traffic, situation: 'Heavy traffic', text: 'Heavy traffic on your route.'),
    CorpusEntry(id: 'en_accident_ahead_001', category: InstructionCategory.traffic, situation: 'Accident ahead', text: 'Accident ahead, expect delays.'),
    CorpusEntry(id: 'en_construction_001', category: InstructionCategory.traffic, situation: 'Construction', text: 'Road construction ahead.'),
    CorpusEntry(id: 'en_road_closed_001', category: InstructionCategory.traffic, situation: 'Road closed', text: 'Road closed, find another route.'),
    CorpusEntry(id: 'en_speed_camera_001', category: InstructionCategory.enforcement, situation: 'Speed camera', text: 'Speed camera ahead.'),
    CorpusEntry(id: 'en_speed_camera_004', category: InstructionCategory.enforcement, situation: 'Speed camera', text: 'Speed camera ahead. Don\'t try to be a hero.'),
    CorpusEntry(id: 'en_redlight_camera_001', category: InstructionCategory.enforcement, situation: 'Red-light camera', text: 'Red-light camera ahead.'),
    CorpusEntry(id: 'en_police_001', category: InstructionCategory.enforcement, situation: 'Police ahead', text: 'Police ahead.'),
    CorpusEntry(id: 'en_arrival_001', category: InstructionCategory.arrival, situation: 'Arrival', text: 'You have arrived.'),
    CorpusEntry(id: 'en_arrival_002', category: InstructionCategory.arrival, situation: 'Destination on left', text: 'Your destination is on the left.'),
  ];
}
