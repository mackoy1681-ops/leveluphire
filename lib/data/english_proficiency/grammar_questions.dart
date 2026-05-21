// lib/data/english_proficiency/grammar_questions.dart
// GRAMMAR QUESTIONS - 70 total (40 Medium, 30 Hard)
// Category: grammar (lowercase)

import '../../models/question_model.dart';

final List<Question> grammarQuestions = [
  // ==================== MEDIUM QUESTIONS (1-40) ====================
  
  Question(
    id: 'eng_gram_01',
    text: 'Which sentence is correct?',
    options: [
      'She go to school every day.',
      'She goes to school every day.',
      'She going to school every day.',
      'She gone to school every day.'
    ],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'grammar',
    explanation: 'For third person singular (she/he/it), add -s to the base verb in present simple tense.',
  ),
  
  Question(
    id: 'eng_gram_02',
    text: 'Choose the correct past tense: "I ___ to the store yesterday."',
    options: ['go', 'went', 'gone', 'going'],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'grammar',
    explanation: '"Went" is the past tense of "go" for completed actions in the past.',
  ),
  
  Question(
    id: 'eng_gram_03',
    text: 'Select the correct sentence:',
    options: [
      'He don\'t like coffee.',
      'He doesn\'t likes coffee.',
      'He doesn\'t like coffee.',
      'He don\'t likes coffee.'
    ],
    correctOptionIndex: 2,
    difficulty: 'medium',
    category: 'grammar',
    explanation: 'For third person singular negative, use "doesn\'t" + base form of verb (no "s" on the verb).',
  ),
  
  Question(
    id: 'eng_gram_04',
    text: 'Which sentence uses the present continuous correctly?',
    options: [
      'They are play football now.',
      'They is playing football now.',
      'They am playing football now.',
      'They are playing football now.'
    ],
    correctOptionIndex: 3,
    difficulty: 'medium',
    category: 'grammar',
    explanation: 'Present continuous = am/is/are + verb-ing. "They" takes "are".',
  ),
  
  Question(
    id: 'eng_gram_05',
    text: 'Choose the correct comparative form: "This test is ___ than the last one."',
    options: ['easy', 'easier', 'more easy', 'easiest'],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'grammar',
    explanation: 'For short adjectives (easy), add -er for comparative. "Easier" is correct.',
  ),
  
  Question(
    id: 'eng_gram_06',
    text: 'Which sentence uses the correct preposition?',
    options: [
      'She is interested in learning English.',
      'She is interested at learning English.',
      'She is interested on learning English.',
      'She is interested for learning English.'
    ],
    correctOptionIndex: 0,
    difficulty: 'medium',
    category: 'grammar',
    explanation: 'The correct preposition with "interested" is "in".',
  ),
  
  Question(
    id: 'eng_gram_07',
    text: 'Select the correct passive voice: "The cake ___ by my grandmother."',
    options: ['make', 'made', 'was made', 'is make'],
    correctOptionIndex: 2,
    difficulty: 'medium',
    category: 'grammar',
    explanation: 'Passive voice: subject + to be + past participle. "Was made" is correct for past tense.',
  ),
  
  Question(
    id: 'eng_gram_08',
    text: 'Which sentence has the correct word order?',
    options: [
      'She always is late for meetings.',
      'She is always late for meetings.',
      'Always she is late for meetings.',
      'She late is always for meetings.'
    ],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'grammar',
    explanation: 'Adverbs of frequency (always) come after the verb "to be".',
  ),
  
  Question(
    id: 'eng_gram_09',
    text: 'Choose the correct question form: "___ you like pizza?"',
    options: ['Does', 'Do', 'Is', 'Are'],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'grammar',
    explanation: 'For questions with "you", use "do" as the auxiliary verb.',
  ),
  
  Question(
    id: 'eng_gram_10',
    text: 'Which sentence uses the correct article?',
    options: [
      'I want to be a engineer.',
      'I want to be an engineer.',
      'I want to be engineer.',
      'I want to be the engineer.'
    ],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'grammar',
    explanation: 'Use "an" before words starting with vowel sounds (engineer starts with vowel sound).',
  ),
  
  Question(
    id: 'eng_gram_11',
    text: 'Select the correct future tense: "They ___ to the party tomorrow."',
    options: ['go', 'will go', 'went', 'have gone'],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'grammar',
    explanation: 'Use "will + base verb" for future predictions or decisions.',
  ),
  
  Question(
    id: 'eng_gram_12',
    text: 'Which sentence is correct?',
    options: [
      'There are less people today.',
      'There is less people today.',
      'There are fewer people today.',
      'There is fewer people today.'
    ],
    correctOptionIndex: 2,
    difficulty: 'medium',
    category: 'grammar',
    explanation: 'Use "fewer" for countable nouns (people) and "less" for uncountable nouns.',
  ),
  
  Question(
    id: 'eng_gram_13',
    text: 'Choose the correct pronoun: "John and ___ are going to the meeting."',
    options: ['me', 'I', 'myself', 'mine'],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'grammar',
    explanation: 'Use subject pronoun "I" when it is part of the subject of the sentence.',
  ),
  
  Question(
    id: 'eng_gram_14',
    text: 'Which sentence uses the correct conditional?',
    options: [
      'If I will see her, I will tell her.',
      'If I see her, I will tell her.',
      'If I saw her, I will tell her.',
      'If I see her, I tell her.'
    ],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'grammar',
    explanation: 'First conditional: If + present simple, will + base verb.',
  ),
  
  Question(
    id: 'eng_gram_15',
    text: 'Select the correct sentence:',
    options: [
      'She has went to London.',
      'She have gone to London.',
      'She has gone to London.',
      'She has go to London.'
    ],
    correctOptionIndex: 2,
    difficulty: 'medium',
    category: 'grammar',
    explanation: 'Present perfect: has/have + past participle. "Gone" is the past participle of "go".',
  ),
  
  Question(
    id: 'eng_gram_16',
    text: 'Choose the correct form: "This is the ___ movie I have ever seen."',
    options: ['good', 'better', 'best', 'most good'],
    correctOptionIndex: 2,
    difficulty: 'medium',
    category: 'grammar',
    explanation: 'Use superlative form "best" when comparing three or more things.',
  ),
  
  Question(
    id: 'eng_gram_17',
    text: 'Which sentence uses the correct modal verb?',
    options: [
      'You should to study harder.',
      'You must to study harder.',
      'You should study harder.',
      'You can to study harder.'
    ],
    correctOptionIndex: 2,
    difficulty: 'medium',
    category: 'grammar',
    explanation: 'Modal verbs (should, must, can) are followed by base form without "to".',
  ),
  
  Question(
    id: 'eng_gram_18',
    text: 'Select the correct indirect question: "Could you tell me ___?"',
    options: [
      'where is the station',
      'where the station is',
      'where the station',
      'is where the station'
    ],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'grammar',
    explanation: 'Indirect questions use statement word order (subject before verb).',
  ),
  
  Question(
    id: 'eng_gram_19',
    text: 'Which sentence is correct?',
    options: [
      'Neither of the answers are correct.',
      'Neither of the answers is correct.',
      'Neither of the answers am correct.',
      'Neither of the answers be correct.'
    ],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'grammar',
    explanation: '"Neither" is singular and takes a singular verb ("is").',
  ),
  
  Question(
    id: 'eng_gram_20',
    text: 'Choose the correct sentence:',
    options: [
      'I look forward to see you.',
      'I look forward to seeing you.',
      'I look forward see you.',
      'I look forward for seeing you.'
    ],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'grammar',
    explanation: 'After "look forward to", use the gerund (-ing form).',
  ),
  
  Question(
    id: 'eng_gram_21',
    text: 'Which sentence uses the correct past continuous?',
    options: [
      'I was watch TV when he called.',
      'I was watching TV when he called.',
      'I were watching TV when he called.',
      'I watched TV when he called.'
    ],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'grammar',
    explanation: 'Past continuous: was/were + verb-ing for actions in progress in the past.',
  ),
  
  Question(
    id: 'eng_gram_22',
    text: 'Select the correct relative pronoun: "The man ___ lives next door is a doctor."',
    options: ['which', 'who', 'whose', 'whom'],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'grammar',
    explanation: 'Use "who" for people when they are the subject of the relative clause.',
  ),
  
  Question(
    id: 'eng_gram_23',
    text: 'Choose the correct sentence:',
    options: [
      'She is more taller than me.',
      'She is taller than me.',
      'She is more tall than me.',
      'She is tallest than me.'
    ],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'grammar',
    explanation: 'For short adjectives, add -er. Do not use "more" with -er.',
  ),
  
  Question(
    id: 'eng_gram_24',
    text: 'Which sentence uses the correct conjunction?',
    options: [
      'Although it was raining, but we went out.',
      'Although it was raining, we went out.',
      'Although it was raining, so we went out.',
      'Although it was raining, because we went out.'
    ],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'grammar',
    explanation: 'Do not use "but" with "although" - they have similar meanings.',
  ),
  
  Question(
    id: 'eng_gram_25',
    text: 'Select the correct form: "I wish I ___ taller."',
    options: ['am', 'is', 'were', 'was'],
    correctOptionIndex: 2,
    difficulty: 'medium',
    category: 'grammar',
    explanation: 'Use "were" for all persons in wish clauses (subjunctive mood).',
  ),
  
  Question(
    id: 'eng_gram_26',
    text: 'Which sentence is correct?',
    options: [
      'Each of the students have a book.',
      'Each of the students has a book.',
      'Each of the students are having a book.',
      'Each of the students having a book.'
    ],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'grammar',
    explanation: '"Each" is singular and takes a singular verb ("has").',
  ),
  
  Question(
    id: 'eng_gram_27',
    text: 'Choose the correct preposition: "Please reply ___ my email."',
    options: ['to', 'on', 'at', 'for'],
    correctOptionIndex: 0,
    difficulty: 'medium',
    category: 'grammar',
    explanation: 'The verb "reply" is followed by the preposition "to".',
  ),
  
  Question(
    id: 'eng_gram_28',
    text: 'Select the correct sentence:',
    options: [
      'If I was you, I would apologize.',
      'If I were you, I would apologize.',
      'If I am you, I would apologize.',
      'If I be you, I would apologize.'
    ],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'grammar',
    explanation: 'Use "were" in hypothetical situations (subjunctive mood).',
  ),
  
  Question(
    id: 'eng_gram_29',
    text: 'Which sentence uses the correct quantifier?',
    options: [
      'There is much people at the party.',
      'There are many people at the party.',
      'There is many people at the party.',
      'There are much people at the party.'
    ],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'grammar',
    explanation: 'Use "many" with countable nouns (people). "Are" for plural subject.',
  ),
  
  Question(
    id: 'eng_gram_30',
    text: 'Choose the correct form: "She recommended ___ the blue dress."',
    options: ['buy', 'to buy', 'buying', 'bought'],
    correctOptionIndex: 2,
    difficulty: 'medium',
    category: 'grammar',
    explanation: 'After "recommend", use the gerund (-ing form).',
  ),
  
  Question(
    id: 'eng_gram_31',
    text: 'Which sentence is correct?',
    options: [
      'The news are very interesting.',
      'The news is very interesting.',
      'The news were very interesting.',
      'The news am very interesting.'
    ],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'grammar',
    explanation: '"News" is uncountable and takes a singular verb ("is").',
  ),
  
  Question(
    id: 'eng_gram_32',
    text: 'Select the correct sentence:',
    options: [
      'She is used to wake up early.',
      'She is used to waking up early.',
      'She used to waking up early.',
      'She is use to wake up early.'
    ],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'grammar',
    explanation: '"Be used to" means accustomed to, followed by gerund (-ing).',
  ),
  
  Question(
    id: 'eng_gram_33',
    text: 'Choose the correct question tag: "You\'re coming to the party, ___?"',
    options: ['aren\'t you', 'isn\'t it', 'don\'t you', 'won\'t you'],
    correctOptionIndex: 0,
    difficulty: 'medium',
    category: 'grammar',
    explanation: 'Question tag for "you are" is "aren\'t you".',
  ),
  
  Question(
    id: 'eng_gram_34',
    text: 'Which sentence uses the correct tense?',
    options: [
      'I have been working here since five years.',
      'I have been working here for five years.',
      'I have been working here from five years.',
      'I have been working here during five years.'
    ],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'grammar',
    explanation: 'Use "for" with a period of time (five years), "since" with a specific point.',
  ),
  
  Question(
    id: 'eng_gram_35',
    text: 'Select the correct passive: "The letter ___ yesterday."',
    options: ['is sent', 'was sent', 'has sent', 'were sent'],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'grammar',
    explanation: 'Past simple passive: was/were + past participle. "Letter" is singular.',
  ),
  
  Question(
    id: 'eng_gram_36',
    text: 'Choose the correct sentence:',
    options: [
      'She doesn\'t have no money.',
      'She doesn\'t have any money.',
      'She doesn\'t have some money.',
      'She have no money.'
    ],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'grammar',
    explanation: 'Use "any" in negative sentences, not double negatives.',
  ),
  
  Question(
    id: 'eng_gram_37',
    text: 'Which sentence is correct?',
    options: [
      'Let\'s go to the beach, shall we?',
      'Let\'s go to the beach, will we?',
      'Let\'s go to the beach, do we?',
      'Let\'s go to the beach, aren\'t we?'
    ],
    correctOptionIndex: 0,
    difficulty: 'medium',
    category: 'grammar',
    explanation: 'Question tag for "let\'s" is "shall we".',
  ),
  
  Question(
    id: 'eng_gram_38',
    text: 'Select the correct comparative: "The weather is getting ___ and ___."',
    options: ['bad, bad', 'worse, worse', 'worse, worst', 'bad, worse'],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'grammar',
    explanation: 'Use repeating comparatives to show continuous change.',
  ),
  
  Question(
    id: 'eng_gram_39',
    text: 'Choose the correct sentence:',
    options: [
      'I would rather stay home than go out.',
      'I would rather to stay home than go out.',
      'I would rather staying home than going out.',
      'I would rather stayed home than went out.'
    ],
    correctOptionIndex: 0,
    difficulty: 'medium',
    category: 'grammar',
    explanation: '"Would rather" is followed by base form (without "to").',
  ),
  
  Question(
    id: 'eng_gram_40',
    text: 'Which sentence uses the correct infinitive?',
    options: [
      'I want that you come early.',
      'I want you to come early.',
      'I want you coming early.',
      'I want you come early.'
    ],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'grammar',
    explanation: 'After "want" + object, use the infinitive (to + verb).',
  ),

  // ==================== HARD QUESTIONS (41-70) ====================

  Question(
    id: 'eng_gram_41',
    text: 'Choose the correct sentence with inverted subject-verb order:',
    options: [
      'Never I have seen such beauty.',
      'Never have I seen such beauty.',
      'Never I have saw such beauty.',
      'Never have seen I such beauty.'
    ],
    correctOptionIndex: 1,
    difficulty: 'hard',
    category: 'grammar',
    explanation: 'Negative adverbs (never) at the beginning require inversion: auxiliary verb + subject + main verb.',
  ),
  
  Question(
    id: 'eng_gram_42',
    text: 'Select the correct subjunctive form: "The manager suggested that he ___ the report by Friday."',
    options: ['finishes', 'finish', 'finished', 'has finished'],
    correctOptionIndex: 1,
    difficulty: 'hard',
    category: 'grammar',
    explanation: 'After suggest/recommend/demand, use the base form of the verb in subjunctive mood.',
  ),
  
  Question(
    id: 'eng_gram_43',
    text: 'Which sentence uses the correct conditional (third conditional)?',
    options: [
      'If I would have known, I would have come.',
      'If I had known, I would have come.',
      'If I knew, I would come.',
      'If I have known, I will come.'
    ],
    correctOptionIndex: 1,
    difficulty: 'hard',
    category: 'grammar',
    explanation: 'Third conditional: If + past perfect, would have + past participle (unreal past).',
  ),
  
  Question(
    id: 'eng_gram_44',
    text: 'Choose the correct sentence with a reduced relative clause:',
    options: [
      'The man who is sitting there is my boss.',
      'The man sitting there is my boss.',
      'The man who sitting there is my boss.',
      'The man sits there is my boss.'
    ],
    correctOptionIndex: 1,
    difficulty: 'hard',
    category: 'grammar',
    explanation: 'In reduced relative clauses, remove "who is" and use the present participle.',
  ),
  
  Question(
    id: 'eng_gram_45',
    text: 'Select the correct sentence with parallel structure:',
    options: [
      'She likes hiking, to swim, and running.',
      'She likes hiking, swimming, and to run.',
      'She likes to hike, to swim, and running.',
      'She likes hiking, swimming, and running.'
    ],
    correctOptionIndex: 3,
    difficulty: 'hard',
    category: 'grammar',
    explanation: 'Parallel structure requires the same grammatical form for all items in a list.',
  ),
  
  Question(
    id: 'eng_gram_46',
    text: 'Which sentence uses the correct mixed conditional?',
    options: [
      'If I had studied medicine, I would be a doctor now.',
      'If I studied medicine, I would be a doctor now.',
      'If I have studied medicine, I will be a doctor now.',
      'If I would have studied medicine, I would be a doctor now.'
    ],
    correctOptionIndex: 0,
    difficulty: 'hard',
    category: 'grammar',
    explanation: 'Mixed conditional: past condition + present result (had studied → would be).',
  ),
  
  Question(
    id: 'eng_gram_47',
    text: 'Choose the correct sentence with a cleft structure:',
    options: [
      'It was yesterday that I met her.',
      'It was yesterday when I met her.',
      'It is yesterday that I met her.',
      'It were yesterday that I met her.'
    ],
    correctOptionIndex: 0,
    difficulty: 'hard',
    category: 'grammar',
    explanation: 'Cleft sentences use "it is/was... that" to emphasize a specific element.',
  ),
  
  Question(
    id: 'eng_gram_48',
    text: 'Select the correct use of "whose" in a relative clause:',
    options: [
      'The woman whose car was stolen called the police.',
      'The woman whose the car was stolen called the police.',
      'The woman whose her car was stolen called the police.',
      'The woman that her car was stolen called the police.'
    ],
    correctOptionIndex: 0,
    difficulty: 'hard',
    category: 'grammar',
    explanation: '"Whose" shows possession and is not followed by another determiner.',
  ),
  
  Question(
    id: 'eng_gram_49',
    text: 'Which sentence correctly uses the past perfect?',
    options: [
      'After she finished work, she went home.',
      'After she had finished work, she went home.',
      'After she has finished work, she went home.',
      'After she was finishing work, she went home.'
    ],
    correctOptionIndex: 1,
    difficulty: 'hard',
    category: 'grammar',
    explanation: 'Use past perfect for the earlier action when two past actions are clearly ordered.',
  ),
  
  Question(
    id: 'eng_gram_50',
    text: 'Choose the correct sentence with a gerund as subject:',
    options: [
      'To learn English is important.',
      'Learn English is important.',
      'Learning English is important.',
      'For learning English is important.'
    ],
    correctOptionIndex: 2,
    difficulty: 'hard',
    category: 'grammar',
    explanation: 'Gerunds (-ing form) can function as the subject of a sentence.',
  ),
  
  Question(
    id: 'eng_gram_51',
    text: 'Select the correct sentence with ellipsis:',
    options: [
      'She can sing better than me.',
      'She can sing better than I can.',
      'She can sing better than I.',
      'All of the above are correct.'
    ],
    correctOptionIndex: 3,
    difficulty: 'hard',
    category: 'grammar',
    explanation: 'In formal English, use subject pronoun + auxiliary; in informal, object pronoun is accepted.',
  ),
  
  Question(
    id: 'eng_gram_52',
    text: 'Which sentence correctly uses "would" for past habits?',
    options: [
      'When I was young, I would play outside every day.',
      'When I was young, I would played outside every day.',
      'When I was young, I would to play outside every day.',
      'When I was young, I would playing outside every day.'
    ],
    correctOptionIndex: 0,
    difficulty: 'hard',
    category: 'grammar',
    explanation: '"Would" + base verb describes past habits or repeated actions.',
  ),
  
  Question(
    id: 'eng_gram_53',
    text: 'Choose the correct sentence with a fronted adverbial:',
    options: [
      'Never before had I seen such a thing.',
      'Never before I had seen such a thing.',
      'Never before I saw such a thing.',
      'Never before have seen I such a thing.'
    ],
    correctOptionIndex: 0,
    difficulty: 'hard',
    category: 'grammar',
    explanation: 'Fronted negative adverbials require inversion of subject and auxiliary verb.',
  ),
  
  Question(
    id: 'eng_gram_54',
    text: 'Select the correct use of "the" with proper nouns:',
    options: [
      'The Mount Everest is in the Himalayas.',
      'Mount Everest is in the Himalayas.',
      'Mount Everest is in Himalayas.',
      'The Mount Everest is in Himalayas.'
    ],
    correctOptionIndex: 1,
    difficulty: 'hard',
    category: 'grammar',
    explanation: 'Do not use "the" with most singular proper nouns (Mount Everest). Use "the" with mountain ranges (the Himalayas).',
  ),
  
  Question(
    id: 'eng_gram_55',
    text: 'Which sentence correctly uses "whom"?',
    options: [
      'Whom did you invite to the party?',
      'Whom is coming to the party?',
      'Whom did you say came to the party?',
      'Whom are you?'
    ],
    correctOptionIndex: 0,
    difficulty: 'hard',
    category: 'grammar',
    explanation: 'Use "whom" as the object of a verb or preposition (not as the subject).',
  ),
  
  Question(
    id: 'eng_gram_56',
    text: 'Choose the correct sentence with a participle clause:',
    options: [
      'Walking home, a dog bit me.',
      'Walking home, I was bitten by a dog.',
      'Walking home, me was bitten by a dog.',
      'Walking home, a dog biting me.'
    ],
    correctOptionIndex: 1,
    difficulty: 'hard',
    category: 'grammar',
    explanation: 'The subject of the participle clause must match the main clause subject.',
  ),
  
  Question(
    id: 'eng_gram_57',
    text: 'Select the correct sentence using "lest":',
    options: [
      'He ran fast lest he should miss the bus.',
      'He ran fast lest he will miss the bus.',
      'He ran fast lest he missed the bus.',
      'He ran fast lest he would miss the bus.'
    ],
    correctOptionIndex: 0,
    difficulty: 'hard',
    category: 'grammar',
    explanation: '"Lest" (meaning "in order that not") is followed by "should" + base verb.',
  ),
  
  Question(
    id: 'eng_gram_58',
    text: 'Which sentence correctly uses the subjunctive after "as if"?',
    options: [
      'He acts as if he is the boss.',
      'He acts as if he were the boss.',
      'He acts as if he was the boss.',
      'He acts as if he be the boss.'
    ],
    correctOptionIndex: 1,
    difficulty: 'hard',
    category: 'grammar',
    explanation: 'Use "were" (subjunctive) after "as if" for unreal/untrue situations.',
  ),
  
  Question(
    id: 'eng_gram_59',
    text: 'Choose the correct sentence with a causative structure:',
    options: [
      'I had my car fixed yesterday.',
      'I had my car fix yesterday.',
      'I had my car to fix yesterday.',
      'I had my car fixing yesterday.'
    ],
    correctOptionIndex: 0,
    difficulty: 'hard',
    category: 'grammar',
    explanation: 'Causative "have something done" = have + object + past participle.',
  ),
  
  Question(
    id: 'eng_gram_60',
    text: 'Select the correct sentence using "so... that" for result:',
    options: [
      'It was so beautiful day that we went to the beach.',
      'It was such a beautiful day that we went to the beach.',
      'It was so a beautiful day that we went to the beach.',
      'It was such beautiful day that we went to the beach.'
    ],
    correctOptionIndex: 1,
    difficulty: 'hard',
    category: 'grammar',
    explanation: 'Use "such + (adjective) + noun" or "so + adjective + a/an + noun".',
  ),
  
  Question(
    id: 'eng_gram_61',
    text: 'Which sentence correctly uses "no sooner... than"?',
    options: [
      'No sooner had I arrived than the phone rang.',
      'No sooner I had arrived than the phone rang.',
      'No sooner had I arrived then the phone rang.',
      'No sooner I arrived than the phone rang.'
    ],
    correctOptionIndex: 0,
    difficulty: 'hard',
    category: 'grammar',
    explanation: 'Inversion is required: No sooner + auxiliary + subject + verb + than.',
  ),
  
  Question(
    id: 'eng_gram_62',
    text: 'Choose the correct sentence with a reduced adverb clause:',
    options: [
      'While I was walking to work, I saw an accident.',
      'While walking to work, I saw an accident.',
      'While walk to work, I saw an accident.',
      'While walked to work, I saw an accident.'
    ],
    correctOptionIndex: 1,
    difficulty: 'hard',
    category: 'grammar',
    explanation: 'Reduce "while + subject + be + verb-ing" to "while + verb-ing".',
  ),
  
  Question(
    id: 'eng_gram_63',
    text: 'Select the correct sentence with "the more... the more":',
    options: [
      'The more you practice, the more you will improve.',
      'More you practice, more you will improve.',
      'The more you practice, more you will improve.',
      'More you practice, the more you will improve.'
    ],
    correctOptionIndex: 0,
    difficulty: 'hard',
    category: 'grammar',
    explanation: 'Comparative correlative structure requires "the" before both comparatives.',
  ),
  
  Question(
    id: 'eng_gram_64',
    text: 'Which sentence correctly uses "for" as a conjunction?',
    options: [
      'He was happy, for he had won the prize.',
      'He was happy for he had won the prize.',
      'He was happy because for he had won the prize.',
      'He was happy for that he had won the prize.'
    ],
    correctOptionIndex: 0,
    difficulty: 'hard',
    category: 'grammar',
    explanation: '"For" as a conjunction means "because" and follows a comma.',
  ),
  
  Question(
    id: 'eng_gram_65',
    text: 'Choose the correct sentence with a nominative absolute:',
    options: [
      'The weather being good, we went to the park.',
      'The weather is good, we went to the park.',
      'The weather was good, we went to the park.',
      'The weather good, we went to the park.'
    ],
    correctOptionIndex: 0,
    difficulty: 'hard',
    category: 'grammar',
    explanation: 'A nominative absolute has a noun + participle, grammatically independent from the main clause.',
  ),
  
  Question(
    id: 'eng_gram_66',
    text: 'Select the correct sentence using "bare infinitive" after perception verbs:',
    options: [
      'I saw her to cross the street.',
      'I saw her crossing the street.',
      'I saw her cross the street.',
      'I saw her crossed the street.'
    ],
    correctOptionIndex: 2,
    difficulty: 'hard',
    category: 'grammar',
    explanation: 'After perception verbs (see, hear, watch), use bare infinitive (without "to") for completed actions.',
  ),
  
  Question(
    id: 'eng_gram_67',
    text: 'Which sentence correctly uses "what" as a fused relative pronoun?',
    options: [
      'What you need is a good rest.',
      'That what you need is a good rest.',
      'The thing what you need is a good rest.',
      'What do you need is a good rest.'
    ],
    correctOptionIndex: 0,
    difficulty: 'hard',
    category: 'grammar',
    explanation: '"What" can mean "the thing that" and functions as a fused relative pronoun.',
  ),
  
  Question(
    id: 'eng_gram_68',
    text: 'Choose the correct sentence with a past subjunctive:',
    options: [
      'I wish I was there yesterday.',
      'I wish I had been there yesterday.',
      'I wish I were there yesterday.',
      'I wish I have been there yesterday.'
    ],
    correctOptionIndex: 1,
    difficulty: 'hard',
    category: 'grammar',
    explanation: 'For past wishes, use past perfect subjunctive: wish + had + past participle.',
  ),
  
  Question(
    id: 'eng_gram_69',
    text: 'Select the correct sentence using "preposition + whom/which":',
    options: [
      'The person to who I spoke was very helpful.',
      'The person to whom I spoke was very helpful.',
      'The person who I spoke to was very helpful.',
      'The person that I spoke to was very helpful.'
    ],
    correctOptionIndex: 1,
    difficulty: 'hard',
    category: 'grammar',
    explanation: 'In formal English, place the preposition before "whom" or "which".',
  ),
  
  Question(
    id: 'eng_gram_70',
    text: 'Which sentence correctly uses "such that" for result?',
    options: [
      'His behavior was such that everyone was offended.',
      'His behavior was such so that everyone was offended.',
      'His behavior was such as that everyone was offended.',
      'His behavior was such to that everyone was offended.'
    ],
    correctOptionIndex: 0,
    difficulty: 'hard',
    category: 'grammar',
    explanation: '"Such that" introduces a result clause without "so" or "as".',
  ),
];