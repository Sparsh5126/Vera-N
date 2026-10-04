/// A small hand-written set of related note pairs, in the mix of English,
/// Hindi and Hinglish a Vera N user writes. Each pair is about the same
/// thing in different words (often a different language). Every text's
/// nearest neighbour should be its partner.
///
/// This is an indicative check (24 texts), not a benchmark of record.
const qualityPairs = <(String, String)>[
  (
    'Maybe the protagonist receives a message every night at 2:17 AM.',
    "What if the messages aren't predicting the future but causing it?",
  ),
  (
    'Buy milk, eggs and bread on the way home.',
    'घर जाते समय दूध, अंडे और ब्रेड ले आना।',
  ),
  (
    'My knee hurts after running; I should rest it this week.',
    'दौड़ने के बाद घुटने में दर्द है, इस हफ्ते आराम करना है।',
  ),
  (
    'माँ का जन्मदिन अगले रविवार है, केक का ऑर्डर देना है।',
    "Order a cake for mom's birthday party on Sunday.",
  ),
  (
    'Idea: an app that reminds you to drink water based on the weather.',
    'A hydration reminder that adapts to how hot it is outside.',
  ),
  (
    'Exam syllabus: thermodynamics chapters 3 to 6, revise entropy.',
    'परीक्षा के लिए ऊष्मागतिकी के अध्याय 3 से 6 दोहराने हैं।',
  ),
  (
    'आज बारिश की वजह से मेट्रो बहुत देर से आई।',
    'The train was late again today because of the heavy rain.',
  ),
  (
    'Book recommendation: Sapiens, about the history of humankind.',
    'I want to read more about how early humans spread across the world.',
  ),
  (
    'किराया हर महीने की पाँच तारीख तक देना है।',
    'Rent is due by the 5th of every month.',
  ),
  (
    'Fix the login bug where the password field clears on rotation.',
    'The password input loses its text when the phone is turned sideways.',
  ),
  (
    'Meeting with Riya kal shaam 6 baje, project deck finalize karna hai.',
    "Finalize the project slides before tomorrow evening's meeting with Riya.",
  ),
  (
    'सुबह की सैर से दिन भर ताज़गी रहती है।',
    'A morning walk keeps me fresh the whole day.',
  ),
];

/// Texts of three lengths for timing: about 15, 60 and 230 tokens.
const timingTexts = <String, String>{
  'short': 'Buy milk, eggs and bread on the way home today.',
  'medium':
      'Maybe the protagonist receives a message every night at 2:17 AM. '
      'At first she thinks it is spam, but the messages describe things '
      'that have not happened yet. आज रात फिर से वही संदेश आया, और इस बार '
      'उसमें मेरा नाम था।',
  'long':
      'Notes from the project review. We agreed that the first release '
      'should focus on fast capture: opening the app and typing in about a '
      'second. Search comes next, then suggestions. Riya will own the '
      'onboarding copy, and I will finish the storage layer and the sync '
      'design. Open questions: where accepted links are stored, which '
      'on-device model to use, and how strict the similarity threshold '
      'should be at launch. मीटिंग में यह भी तय हुआ कि पहले हफ्ते में हम सिर्फ '
      'मज़बूत सुझाव दिखाएँगे, ताकि उपयोगकर्ता को सुझाव बेतरतीब न लगें। अगली '
      'मीटिंग शुक्रवार को है, उससे पहले बेंचमार्क के नतीजे तैयार होने चाहिए। '
      'Also remember: battery matters more than speed, so analysis should '
      'run while charging, and the model must be released after each batch '
      'instead of staying in memory. We should measure memory, load time '
      'and time per note on a mid-range phone before deciding anything.',
};
