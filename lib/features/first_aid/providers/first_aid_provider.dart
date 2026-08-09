import 'package:flutter/foundation.dart';

import '../models/first_aid_model.dart';

class FirstAidProvider extends ChangeNotifier {
  final List<FirstAidModel> _items = const [
    FirstAidModel(
      id: 'cuts',
      title: 'Cuts & Bleeding',
      description:
          'Basic steps to control bleeding and protect a wound.',
      icon: '🩹',
      category: 'Injuries',
      steps: [
        'Wash your hands if possible before helping.',
        'Apply gentle, firm pressure to the wound using clean cloth or gauze.',
        'Keep applying pressure until the bleeding slows or stops.',
        'Once bleeding is controlled, cover the wound with a clean dressing.',
        'Seek medical attention for deep, large, or heavily bleeding wounds.',
      ],
      doNot: [
        'Do not remove an object deeply embedded in the wound.',
        'Do not repeatedly remove the dressing to check the wound.',
        'Do not ignore heavy or uncontrolled bleeding.',
      ],
      whenToCallEmergency:
          'Call emergency services if bleeding is severe, does not stop with continuous pressure, or the person shows signs of shock.',
    ),

    FirstAidModel(
      id: 'burns',
      title: 'Burns',
      description:
          'Immediate first aid steps for common minor burns.',
      icon: '🔥',
      category: 'Injuries',
      steps: [
        'Move away from the source of heat if it is safe to do so.',
        'Cool the affected area with cool running water.',
        'Remove nearby jewellery or tight items if they are not stuck to the skin.',
        'Cover the burn loosely with a clean dressing.',
        'Get medical help for serious or extensive burns.',
      ],
      doNot: [
        'Do not apply ice directly to the burn.',
        'Do not apply butter, oil, or toothpaste.',
        'Do not break blisters.',
        'Do not remove clothing stuck to the burn.',
      ],
      whenToCallEmergency:
          'Seek emergency medical help for extensive, deep, electrical, chemical, or airway-related burns.',
    ),

    FirstAidModel(
      id: 'choking',
      title: 'Choking',
      description:
          'What to do when someone is unable to breathe because of an obstruction.',
      icon: '🫁',
      category: 'Emergency',
      steps: [
        'Ask the person if they are choking.',
        'If they can cough forcefully, encourage them to keep coughing.',
        'If they cannot breathe, speak, or cough effectively, provide appropriate choking first aid.',
        'Continue helping according to the person’s age and condition.',
        'Call emergency services if the obstruction cannot be cleared or the person becomes unresponsive.',
      ],
      doNot: [
        'Do not give food or water to a choking person.',
        'Do not leave a severely choking person alone.',
        'Do not blindly put your fingers into the person’s mouth.',
      ],
      whenToCallEmergency:
          'Call emergency services immediately when the person cannot breathe effectively, becomes unresponsive, or the obstruction cannot be cleared.',
    ),

    FirstAidModel(
      id: 'fracture',
      title: 'Fractures',
      description:
          'Basic precautions when you suspect a broken bone.',
      icon: '🦴',
      category: 'Injuries',
      steps: [
        'Keep the injured person as still as possible.',
        'Support the injured area in the position you found it.',
        'Apply a cold pack wrapped in cloth to help reduce swelling.',
        'Check the person for other serious injuries.',
        'Seek professional medical care.',
      ],
      doNot: [
        'Do not try to straighten a visibly deformed bone.',
        'Do not push a protruding bone back into place.',
        'Do not unnecessarily move the injured person.',
      ],
      whenToCallEmergency:
          'Call emergency services for severe injuries, heavy bleeding, suspected spinal injury, loss of consciousness, or signs of poor circulation.',
    ),

    FirstAidModel(
      id: 'fainting',
      title: 'Fainting',
      description:
          'What to do when someone suddenly loses consciousness briefly.',
      icon: '😵',
      category: 'Emergency',
      steps: [
        'Make sure the surrounding area is safe.',
        'Lay the person down if they are not already on the ground.',
        'Check whether they are breathing normally.',
        'If they recover, allow them to rest and recover gradually.',
        'Look for signs of injury from the fall.',
      ],
      doNot: [
        'Do not give food or drink while the person is unconscious.',
        'Do not leave the person alone if they have not fully recovered.',
        'Do not allow them to stand suddenly after fainting.',
      ],
      whenToCallEmergency:
          'Call emergency services if the person does not regain consciousness, has difficulty breathing, experiences chest pain, has a seizure, or is seriously injured.',
    ),

    FirstAidModel(
      id: 'cpr',
      title: 'CPR',
      description:
          'Emergency response when a person is unresponsive and not breathing normally.',
      icon: '❤️',
      category: 'Emergency',
      steps: [
        'Check that the area is safe.',
        'Check whether the person responds to you.',
        'Check for normal breathing.',
        'Call emergency services and get an AED if available.',
        'Begin CPR according to your training and follow emergency dispatcher instructions.',
      ],
      doNot: [
        'Do not delay calling emergency services.',
        'Do not stop CPR unless the person starts showing signs of life, another trained responder takes over, the scene becomes unsafe, or you are exhausted.',
        'Do not perform procedures beyond your training unless instructed by emergency professionals.',
      ],
      whenToCallEmergency:
          'Call emergency services immediately when an adult is unresponsive and not breathing normally.',
    ),
  ];

  List<FirstAidModel> get items =>
      List.unmodifiable(_items);

  List<String> get categories {
    return _items
        .map((item) => item.category)
        .toSet()
        .toList();
  }

  List<FirstAidModel> byCategory(String category) {
    return _items
        .where((item) => item.category == category)
        .toList();
  }

  FirstAidModel? findById(String id) {
    for (final item in _items) {
      if (item.id == id) {
        return item;
      }
    }

    return null;
  }
}