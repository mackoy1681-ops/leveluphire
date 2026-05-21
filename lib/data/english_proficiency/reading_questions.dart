// lib/data/english_proficiency/reading_questions.dart
// READING COMPREHENSION QUESTIONS - 50 total (30 Medium, 20 Hard)
// Category Color: Gold (#FFD700)

import '../../models/question_model.dart';

final List<Question> readingQuestions = [
  // ==================== MEDIUM QUESTIONS (1-30) ====================
  
  Question(
    id: 'eng_read_01',
    text: 'Read the passage: "John loves to read books. He goes to the library every weekend. His favorite books are about science."\n\nWhere does John go every weekend?',
    options: [
      'To the park',
      'To the library',
      'To school',
      'To the cinema'
    ],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'reading',
    explanation: 'The passage clearly states: "He goes to the library every weekend."',
  ),
  
  Question(
    id: 'eng_read_02',
    text: 'Read the passage: "The Amazon rainforest is home to millions of species. It produces 20% of the world\'s oxygen."\n\nWhat percentage of the world\'s oxygen does the Amazon produce?',
    options: ['10%', '15%', '20%', '25%'],
    correctOptionIndex: 2,
    difficulty: 'medium',
    category: 'reading',
    explanation: 'The passage states: "It produces 20% of the world\'s oxygen."',
  ),
  
  Question(
    id: 'eng_read_03',
    text: 'Read the passage: "Maria woke up late. She missed her bus. She decided to call her boss to explain she would be late for work."\n\nWhy did Maria call her boss?',
    options: [
      'To quit her job',
      'To explain she would be late',
      'To ask for a raise',
      'To request a day off'
    ],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'reading',
    explanation: 'She called "to explain she would be late for work."',
  ),
  
  Question(
    id: 'eng_read_04',
    text: 'Read the passage: "The company announced a new policy. All employees must complete safety training by Friday. Failure to comply will result in suspension."\n\nWhat happens if employees do not complete the training by Friday?',
    options: [
      'They will get a bonus',
      'They will be promoted',
      'They will be suspended',
      'They will be praised'
    ],
    correctOptionIndex: 2,
    difficulty: 'medium',
    category: 'reading',
    explanation: 'The passage states: "Failure to comply will result in suspension."',
  ),
  
  Question(
    id: 'eng_read_05',
    text: 'Read the passage: "Jane is a vegetarian. She does not eat meat or fish. She usually orders salads or vegetable dishes when eating out."\n\nWhat does Jane NOT eat?',
    options: ['Salads', 'Vegetables', 'Meat and fish', 'Fruits'],
    correctOptionIndex: 2,
    difficulty: 'medium',
    category: 'reading',
    explanation: 'The passage states she is a vegetarian who "does not eat meat or fish."',
  ),
  
  Question(
    id: 'eng_read_06',
    text: 'Read the passage: "The meeting was scheduled for 2 PM. However, the manager was stuck in traffic. The meeting started at 2:30 PM instead."\n\nWhy did the meeting start late?',
    options: [
      'The room was not ready',
      'The manager was stuck in traffic',
      'No one showed up',
      'The projector was broken'
    ],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'reading',
    explanation: 'The passage states: "the manager was stuck in traffic."',
  ),
  
  Question(
    id: 'eng_read_07',
    text: 'Read the passage: "Coffee is one of the most popular beverages in the world. Many people drink it in the morning to feel more awake. Some studies show that moderate coffee consumption may have health benefits."\n\nWhy do many people drink coffee in the morning?',
    options: [
      'To feel more awake',
      'To fall asleep',
      'To cool down',
      'To gain weight'
    ],
    correctOptionIndex: 0,
    difficulty: 'medium',
    category: 'reading',
    explanation: 'The passage states people drink it "to feel more awake."',
  ),
  
  Question(
    id: 'eng_read_08',
    text: 'Read the passage: "Tom saved money for six months. He wanted to buy a new laptop. Finally, he had enough cash and went to the electronics store."\n\nWhat did Tom want to buy?',
    options: ['A phone', 'A tablet', 'A laptop', 'A desktop'],
    correctOptionIndex: 2,
    difficulty: 'medium',
    category: 'reading',
    explanation: 'The passage states: "He wanted to buy a new laptop."',
  ),
  
  Question(
    id: 'eng_read_09',
    text: 'Read the passage: "The customer service representative was very helpful. She listened to my problem carefully and offered a solution within minutes. I was very satisfied with her assistance."\n\nHow did the customer feel about the service?',
    options: ['Angry', 'Satisfied', 'Confused', 'Disappointed'],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'reading',
    explanation: 'The passage states: "I was very satisfied with her assistance."',
  ),
  
  Question(
    id: 'eng_read_10',
    text: 'Read the passage: "The new software update includes several features. Users can now customize their dashboard, receive real-time notifications, and export data in multiple formats."\n\nWhich feature is mentioned in the update?',
    options: [
      'Video calling',
      'Customizable dashboard',
      'Voice commands',
      'Photo editing'
    ],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'reading',
    explanation: 'The passage mentions: "Users can now customize their dashboard."',
  ),
  
  Question(
    id: 'eng_read_11',
    text: 'Read the passage: "Despite the heavy rain, the football match continued. The players were determined to finish the game. The fans cheered loudly from under their umbrellas."\n\nWhat was the weather like during the match?',
    options: ['Sunny', 'Snowy', 'Rainy', 'Windy'],
    correctOptionIndex: 2,
    difficulty: 'medium',
    category: 'reading',
    explanation: 'The passage mentions "heavy rain" and fans under "umbrellas."',
  ),
  
  Question(
    id: 'eng_read_12',
    text: 'Read the passage: "The restaurant is known for its pasta dishes. Their spaghetti carbonara is the most popular item on the menu. Many customers drive from neighboring towns just to eat there."\n\nWhat is the most popular item on the menu?',
    options: [
      'Pizza',
      'Spaghetti carbonara',
      'Salad',
      'Soup'
    ],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'reading',
    explanation: 'The passage states: "Their spaghetti carbonara is the most popular item."',
  ),
  
  Question(
    id: 'eng_read_13',
    text: 'Read the passage: "Employees are reminded that the office will be closed on Monday for the holiday. Normal operations will resume on Tuesday at 9 AM."\n\nWhen will the office reopen?',
    options: [
      'Monday at 9 AM',
      'Tuesday at 9 AM',
      'Monday at 5 PM',
      'Wednesday at 9 AM'
    ],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'reading',
    explanation: 'The passage states: "Normal operations will resume on Tuesday at 9 AM."',
  ),
  
  Question(
    id: 'eng_read_14',
    text: 'Read the passage: "Anna has been working at the company for five years. She started as an intern and worked her way up to department manager. Her dedication has inspired many colleagues."\n\nWhat position does Anna currently hold?',
    options: ['Intern', 'Assistant', 'Department manager', 'CEO'],
    correctOptionIndex: 2,
    difficulty: 'medium',
    category: 'reading',
    explanation: 'The passage states she "worked her way up to department manager."',
  ),
  
  Question(
    id: 'eng_read_15',
    text: 'Read the passage: "The deadline for the project is next Friday. The team needs to complete the final review and submit all documents by 5 PM."\n\nWhen is the project deadline?',
    options: [
      'This Friday',
      'Next Friday',
      'Next Monday',
      'Tomorrow'
    ],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'reading',
    explanation: 'The passage states: "The deadline for the project is next Friday."',
  ),
  
  Question(
    id: 'eng_read_16',
    text: 'Read the passage: "Regular exercise has many benefits. It can improve your mood, help you sleep better, and reduce stress. Doctors recommend at least 30 minutes of activity per day."\n\nHow much exercise do doctors recommend per day?',
    options: [
      '15 minutes',
      '30 minutes',
      '45 minutes',
      '60 minutes'
    ],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'reading',
    explanation: 'The passage states: "Doctors recommend at least 30 minutes of activity per day."',
  ),
  
  Question(
    id: 'eng_read_17',
    text: 'Read the passage: "The hotel offers free Wi-Fi to all guests. The password is provided at check-in. You can connect up to three devices per room."\n\nWhen do guests receive the Wi-Fi password?',
    options: [
      'Before booking',
      'At check-in',
      'At check-out',
      'By email'
    ],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'reading',
    explanation: 'The passage states: "The password is provided at check-in."',
  ),
  
  Question(
    id: 'eng_read_18',
    text: 'Read the passage: "The train to Chicago departs from platform 4 at 3:15 PM. Passengers should arrive at least 15 minutes before departure."\n\nWhat time should passengers arrive?',
    options: [
      '3:00 PM',
      '3:15 PM',
      '3:30 PM',
      '2:45 PM'
    ],
    correctOptionIndex: 0,
    difficulty: 'medium',
    category: 'reading',
    explanation: '15 minutes before 3:15 PM is 3:00 PM.',
  ),
  
  Question(
    id: 'eng_read_19',
    text: 'Read the passage: "David applied for three jobs last week. He already heard back from two companies. He has an interview scheduled for Thursday."\n\nHow many interviews does David have scheduled?',
    options: ['One', 'Two', 'Three', 'None'],
    correctOptionIndex: 0,
    difficulty: 'medium',
    category: 'reading',
    explanation: 'The passage states: "He has an interview scheduled for Thursday" (one interview).',
  ),
  
  Question(
    id: 'eng_read_20',
    text: 'Read the passage: "The museum is free for children under 12. Adults pay \$15. Seniors over 65 receive a 20% discount."\n\nHow much does an adult ticket cost?',
    options: ['\$10', '\$12', '\$15', '\$20'],
    correctOptionIndex: 2,
    difficulty: 'medium',
    category: 'reading',
    explanation: 'The passage states: "Adults pay \$15."',
  ),
  
  Question(
    id: 'eng_read_21',
    text: 'Read the passage: "Sarah enjoys hiking on weekends. Last Saturday, she climbed Mount Mitchell. It was challenging but the view from the top was worth it."\n\nWhat did Sarah do last Saturday?',
    options: [
      'Went swimming',
      'Climbed a mountain',
      'Visited a museum',
      'Watched a movie'
    ],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'reading',
    explanation: 'The passage states: "Last Saturday, she climbed Mount Mitchell."',
  ),
  
  Question(
    id: 'eng_read_22',
    text: 'Read the passage: "The company is hiring for three positions: a software engineer, a marketing specialist, and a customer service representative. All positions require at least two years of experience."\n\nHow many positions are open?',
    options: ['One', 'Two', 'Three', 'Four'],
    correctOptionIndex: 2,
    difficulty: 'medium',
    category: 'reading',
    explanation: 'The passage lists three positions: software engineer, marketing specialist, and customer service representative.',
  ),
  
  Question(
    id: 'eng_read_23',
    text: 'Read the passage: "Please do not use your phone in the library. Talking is also not allowed. If you need assistance, please approach the front desk."\n\nWhere should you go for assistance?',
    options: [
      'The restroom',
      'The front desk',
      'The exit',
      'The back room'
    ],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'reading',
    explanation: 'The passage states: "If you need assistance, please approach the front desk."',
  ),
  
  Question(
    id: 'eng_read_24',
    text: 'Read the passage: "The sale ends this Sunday. All items are 25% off. Discount is applied at checkout."\n\nWhen does the sale end?',
    options: ['Monday', 'Saturday', 'Sunday', 'Friday'],
    correctOptionIndex: 2,
    difficulty: 'medium',
    category: 'reading',
    explanation: 'The passage states: "The sale ends this Sunday."',
  ),
  
  Question(
    id: 'eng_read_25',
    text: 'Read the passage: "Mark is learning Spanish. He practices every day using a language app. His goal is to become fluent before his trip to Spain next year."\n\nWhat is Mark\'s goal?',
    options: [
      'To become fluent in Spanish',
      'To move to Spain',
      'To become a teacher',
      'To learn French'
    ],
    correctOptionIndex: 0,
    difficulty: 'medium',
    category: 'reading',
    explanation: 'The passage states: "His goal is to become fluent before his trip to Spain."',
  ),
  
  Question(
    id: 'eng_read_26',
    text: 'Read the passage: "The conference will be held at the Grand Hotel from October 15 to 17. Registration begins at 8 AM on the first day."\n\nHow many days does the conference last?',
    options: ['Two days', 'Three days', 'Four days', 'Five days'],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'reading',
    explanation: 'October 15 to 17 is three days (15, 16, 17).',
  ),
  
  Question(
    id: 'eng_read_27',
    text: 'Read the passage: "The new cafe on Main Street offers organic coffee and homemade pastries. Their blueberry muffins are especially popular and often sell out by noon."\n\nWhat item often sells out by noon?',
    options: [
      'Coffee',
      'Croissants',
      'Blueberry muffins',
      'Bagels'
    ],
    correctOptionIndex: 2,
    difficulty: 'medium',
    category: 'reading',
    explanation: 'The passage states: "Their blueberry muffins... often sell out by noon."',
  ),
  
  Question(
    id: 'eng_read_28',
    text: 'Read the passage: "To reset your password, click the \'Forgot Password\' link on the login screen. You will receive an email with instructions within 5 minutes."\n\nWhat should you click to reset your password?',
    options: [
      'Sign Up',
      'Forgot Password',
      'Contact Us',
      'Help'
    ],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'reading',
    explanation: 'The passage states: "click the \'Forgot Password\' link."',
  ),
  
  Question(
    id: 'eng_read_29',
    text: 'Read the passage: "The movie received mixed reviews. Critics praised the acting but criticized the slow plot. Audiences seemed to enjoy it more than the experts."\n\nWhat did critics praise?',
    options: [
      'The plot',
      'The acting',
      'The music',
      'The special effects'
    ],
    correctOptionIndex: 1,
    difficulty: 'medium',
    category: 'reading',
    explanation: 'The passage states: "Critics praised the acting."',
  ),
  
  Question(
    id: 'eng_read_30',
    text: 'Read the passage: "You have 30 minutes to complete this section. There are 20 multiple-choice questions. Please answer all questions before time runs out."\n\nHow many questions are in this section?',
    options: ['10', '15', '20', '25'],
    correctOptionIndex: 2,
    difficulty: 'medium',
    category: 'reading',
    explanation: 'The passage states: "There are 20 multiple-choice questions."',
  ),

  // ==================== HARD QUESTIONS (31-50) ====================

  Question(
    id: 'eng_read_31',
    text: 'Read the passage: "The term \'soft skills\' refers to personal attributes that enable someone to interact effectively with others. Unlike hard skills, which are technical and job-specific, soft skills include communication, empathy, and teamwork. Employers increasingly value these qualities as automation handles more technical tasks."\n\nAccording to the passage, why are soft skills becoming more valuable?',
    options: [
      'Hard skills are no longer needed',
      'Automation handles more technical tasks',
      'Soft skills are easier to teach',
      'Employees prefer working alone'
    ],
    correctOptionIndex: 1,
    difficulty: 'hard',
    category: 'reading',
    explanation: 'The passage states employers value soft skills "as automation handles more technical tasks."',
  ),
  
  Question(
    id: 'eng_read_32',
    text: 'Read the passage: "Remote work has transformed how companies operate. While many employees appreciate the flexibility, some struggle with work-life boundaries. Successful remote workers typically establish a dedicated workspace and maintain regular hours."\n\nWhat do successful remote workers typically do?',
    options: [
      'Work from coffee shops daily',
      'Establish a dedicated workspace',
      'Work longer hours',
      'Avoid video meetings'
    ],
    correctOptionIndex: 1,
    difficulty: 'hard',
    category: 'reading',
    explanation: 'The passage states they "establish a dedicated workspace and maintain regular hours."',
  ),
  
  Question(
    id: 'eng_read_33',
    text: 'Read the passage: "The candidate\'s resume was impressive on paper, but during the interview, she struggled to articulate her experience. Her answers were vague and lacked specific examples. Despite her qualifications, the hiring manager decided to continue the search."\n\nWhy did the hiring manager decide not to hire the candidate?',
    options: [
      'She lacked qualifications',
      'She struggled to articulate her experience',
      'She arrived late to the interview',
      'She asked for too much money'
    ],
    correctOptionIndex: 1,
    difficulty: 'hard',
    category: 'reading',
    explanation: 'The passage states she "struggled to articulate her experience" and answers were vague.',
  ),
  
  Question(
    id: 'eng_read_34',
    text: 'Read the passage: "The company\'s quarterly report revealed a 15% increase in revenue compared to last year. However, operating expenses also rose by 20%, resulting in a net profit margin of 8%, down from 12% the previous year. The CEO attributed the expense increase to expanded marketing efforts."\n\nWhat happened to the net profit margin?',
    options: [
      'It increased from 8% to 12%',
      'It decreased from 12% to 8%',
      'It remained the same',
      'It doubled'
    ],
    correctOptionIndex: 1,
    difficulty: 'hard',
    category: 'reading',
    explanation: 'The net profit margin was 12% last year and dropped to 8% this year.',
  ),
  
  Question(
    id: 'eng_read_35',
    text: 'Read the passage: "Customer satisfaction scores have declined for three consecutive quarters. The primary complaints relate to long wait times and unhelpful support staff. In response, management is implementing a new training program and adding 50 support agents by next month."\n\nWhat are the two main customer complaints mentioned?',
    options: [
      'High prices and poor quality',
      'Long wait times and unhelpful staff',
      'Website errors and shipping delays',
      'Limited hours and rude management'
    ],
    correctOptionIndex: 1,
    difficulty: 'hard',
    category: 'reading',
    explanation: 'The passage mentions complaints about "long wait times and unhelpful support staff."',
  ),
  
  Question(
    id: 'eng_read_36',
    text: 'Read the passage: "Climate change is causing polar ice caps to melt at an accelerated rate. Scientists predict that if current trends continue, many coastal cities could face regular flooding within 50 years. Some governments are already investing in sea walls and relocation programs."\n\nWhat are some governments doing to prepare?',
    options: [
      'Building more factories',
      'Investing in sea walls and relocation programs',
      'Reducing carbon emissions only',
      'Moving cities inland'
    ],
    correctOptionIndex: 1,
    difficulty: 'hard',
    category: 'reading',
    explanation: 'The passage states governments are "investing in sea walls and relocation programs."',
  ),
  
  Question(
    id: 'eng_read_37',
    text: 'Read the passage: "The board rejected the proposed merger, citing concerns about market competition. The chairman expressed disappointment but acknowledged that the decision was in the company\'s best interest. Shareholders reacted positively to the news, sending stock prices up 5%."\n\nHow did shareholders react to the merger rejection?',
    options: [
      'They were disappointed',
      'They reacted positively',
      'They filed a lawsuit',
      'They demanded a meeting'
    ],
    correctOptionIndex: 1,
    difficulty: 'hard',
    category: 'reading',
    explanation: 'The passage states: "Shareholders reacted positively to the news."',
  ),
  
  Question(
    id: 'eng_read_38',
    text: 'Read the passage: "The new manager implemented several changes within her first month. She introduced weekly team meetings, revised the project tracking system, and established clearer performance metrics. While some employees resisted initially, most now agree the changes have improved efficiency."\n\nWhat was the initial employee reaction to the changes?',
    options: [
      'Enthusiastic support',
      'Resistance',
      'Indifference',
      'Confusion'
    ],
    correctOptionIndex: 1,
    difficulty: 'hard',
    category: 'reading',
    explanation: 'The passage states: "While some employees resisted initially."',
  ),
  
  Question(
    id: 'eng_read_39',
    text: 'Read the passage: "Electric vehicles (EVs) are gaining popularity, but charging infrastructure remains a challenge. Many potential buyers worry about range anxiety—the fear of running out of power before reaching a charger. To address this, governments are offering incentives for charging station installation."\n\nWhat is \'range anxiety\' as described in the passage?',
    options: [
      'Fear of driving too fast',
      'Fear of running out of power before reaching a charger',
      'Fear of car accidents',
      'Fear of high electricity bills'
    ],
    correctOptionIndex: 1,
    difficulty: 'hard',
    category: 'reading',
    explanation: 'The passage defines range anxiety as "the fear of running out of power before reaching a charger."',
  ),
  
  Question(
    id: 'eng_read_40',
    text: 'Read the passage: "The internship program accepts 50 students each summer. Applicants must have completed at least two years of college and submit a resume and cover letter. The selection committee looks for strong communication skills and relevant coursework."\n\nWhat two documents must applicants submit?',
    options: [
      'Transcript and photo ID',
      'Resume and cover letter',
      'Portfolio and references',
      'Essay and application fee'
    ],
    correctOptionIndex: 1,
    difficulty: 'hard',
    category: 'reading',
    explanation: 'The passage states applicants must "submit a resume and cover letter."',
  ),
  
  Question(
    id: 'eng_read_41',
    text: 'Read the passage: "Despite the company\'s financial troubles, the CEO remained optimistic. He announced a turnaround plan that includes cost-cutting measures and a new product launch. \'We have faced challenges before and emerged stronger,\' he told investors. \'This time will be no different.\'"\n\nWhat is the CEO\'s attitude toward the company\'s situation?',
    options: [
      'Pessimistic',
      'Optimistic',
      'Indifferent',
      'Angry'
    ],
    correctOptionIndex: 1,
    difficulty: 'hard',
    category: 'reading',
    explanation: 'The passage states the CEO "remained optimistic" and expressed confidence.',
  ),
  
  Question(
    id: 'eng_read_42',
    text: 'Read the passage: "To be eligible for the scholarship, students must maintain a GPA of 3.5 or higher. Additionally, they must complete 20 hours of community service per semester and submit a personal essay. The scholarship covers full tuition but not living expenses."\n\nWhat does the scholarship NOT cover?',
    options: [
      'Tuition',
      'Books',
      'Living expenses',
      'Fees'
    ],
    correctOptionIndex: 2,
    difficulty: 'hard',
    category: 'reading',
    explanation: 'The passage states: "The scholarship covers full tuition but not living expenses."',
  ),
  
  Question(
    id: 'eng_read_43',
    text: 'Read the passage: "The restaurant critic described the food as \'uninspired and overpriced.\' She noted that while the service was attentive, the portions were small and the flavors bland. Her two-star review is likely to hurt business at the newly opened establishment."\n\nWhat did the critic say about the service?',
    options: [
      'It was slow',
      'It was rude',
      'It was attentive',
      'It was nonexistent'
    ],
    correctOptionIndex: 2,
    difficulty: 'hard',
    category: 'reading',
    explanation: 'The passage states: "the service was attentive."',
  ),
  
  Question(
    id: 'eng_read_44',
    text: 'Read the passage: "Social media algorithms are designed to show users content they are likely to engage with. This creates \'filter bubbles\' where people primarily see opinions similar to their own. Critics argue this contributes to political polarization by limiting exposure to opposing viewpoints."\n\nWhat is a \'filter bubble\' according to the passage?',
    options: [
      'A spam filtering tool',
      'A situation where users see mainly similar opinions',
      'A privacy setting on social media',
      'A type of advertisement'
    ],
    correctOptionIndex: 1,
    difficulty: 'hard',
    category: 'reading',
    explanation: 'The passage describes filter bubbles as where people "primarily see opinions similar to their own."',
  ),
  
  Question(
    id: 'eng_read_45',
    text: 'Read the passage: "The project was behind schedule and over budget. The team had underestimated the complexity of the integration phase. After bringing in an external consultant, they revised the timeline and reallocated resources. The project is now expected to launch in Q2 instead of Q1."\n\nWhen is the project now expected to launch?',
    options: ['Q1', 'Q2', 'Q3', 'Q4'],
    correctOptionIndex: 1,
    difficulty: 'hard',
    category: 'reading',
    explanation: 'The passage states the project is "expected to launch in Q2 instead of Q1."',
  ),
  
  Question(
    id: 'eng_read_46',
    text: 'Read the passage: "Dr. Martinez has published over 50 peer-reviewed articles on neuroscience. Her research focuses on how sleep affects memory consolidation. She recently received a \$2 million grant to study the long-term effects of sleep deprivation on young adults."\n\nWhat is the focus of Dr. Martinez\'s research?',
    options: [
      'Exercise and brain health',
      'How sleep affects memory consolidation',
      'Diet and cognitive function',
      'Aging and dementia'
    ],
    correctOptionIndex: 1,
    difficulty: 'hard',
    category: 'reading',
    explanation: 'The passage states: "Her research focuses on how sleep affects memory consolidation."',
  ),
  
  Question(
    id: 'eng_read_47',
    text: 'Read the passage: "The airline has a strict carry-on policy. Each passenger may bring one personal item (purse, laptop bag, or briefcase) and one carry-on suitcase. The carry-on must fit in the overhead bin and cannot exceed 22 x 14 x 9 inches. Personal items must fit under the seat."\n\nWhere must the personal item be placed?',
    options: [
      'In the overhead bin',
      'Under the seat',
      'In the cargo hold',
      'At the gate'
    ],
    correctOptionIndex: 1,
    difficulty: 'hard',
    category: 'reading',
    explanation: 'The passage states: "Personal items must fit under the seat."',
  ),
  
  Question(
    id: 'eng_read_48',
    text: 'Read the passage: "Artificial intelligence is transforming healthcare. AI algorithms can now detect certain cancers earlier than human radiologists. However, experts caution that AI should augment rather than replace medical professionals. The technology works best as a screening tool, with doctors making final diagnoses."\n\nHow should AI be used in healthcare, according to experts?',
    options: [
      'To replace doctors completely',
      'To augment rather than replace medical professionals',
      'Only for administrative tasks',
      'Only in research settings'
    ],
    correctOptionIndex: 1,
    difficulty: 'hard',
    category: 'reading',
    explanation: 'Experts caution that "AI should augment rather than replace medical professionals."',
  ),
  
  Question(
    id: 'eng_read_49',
    text: 'Read the passage: "The employee handbook outlines the company\'s code of conduct. Section 4 specifically addresses conflicts of interest. Employees must disclose any outside employment or financial interests that could influence their decisions at work. Failure to disclose may result in termination."\n\nWhat must employees disclose under Section 4?',
    options: [
      'Their salary expectations',
      'Outside employment or financial interests',
      'Their medical history',
      'Their vacation plans'
    ],
    correctOptionIndex: 1,
    difficulty: 'hard',
    category: 'reading',
    explanation: 'Employees must disclose "any outside employment or financial interests that could influence their decisions."',
  ),
  
  Question(
    id: 'eng_read_50',
    text: 'Read the passage: "The company exceeded its sales targets for the third consecutive quarter. Revenue grew by 25% year-over-year, driven by strong performance in the Asia-Pacific region. The CFO credited the success to the new distribution strategy implemented in January. Based on this momentum, the company has raised its annual forecast."\n\nWhat factor drove the revenue growth according to the CFO?',
    options: [
      'Increased advertising spending',
      'The new distribution strategy',
      'Lower product prices',
      'Hiring more sales staff'
    ],
    correctOptionIndex: 1,
    difficulty: 'hard',
    category: 'reading',
    explanation: 'The CFO "credited the success to the new distribution strategy implemented in January."',
  ),
];