/// A small hand-written set for measuring matching on long notes (written
/// 2026-10-15). Indicative only: one author, a few topics. Never real notes.
abstract final class MatchingEvalSet {
  static const notes = <String, String>{
    // Trek planning.
    'trekPlan': '''Kedarkantha trek plan

We finally fixed the dates: 22 to 27 December, with a group of five from the hostel. The base camp is Sankri, and the drive from Dehradun takes almost ten hours on a hill road, so we need to leave early.

Budget per person is about 9,000 rupees for the trek package, plus train tickets and food on the way. Rohan will collect the money by Friday.

Train: Nanda Devi Express to Dehradun on the 21st night. Book tatkal if the waiting list does not clear.

The summit day starts at 3 am. The guide said the last stretch is steep snow, and microspikes are given by the operator. We should practise walking with a loaded backpack before we go.

Things still open: who carries the first aid kit, and whether we stay one extra night in Dehradun on the way back.''',
    'trekPack': '''Winter trek packing and fitness

Packing for the Himalayan snow trek next month. Layers matter more than one heavy jacket: thermal inner, fleece, down jacket, and a waterproof shell on top. Two pairs of woollen socks per day, gloves with a liner, a woollen cap and a buff for the face.

Shoes: waterproof trekking shoes, broken in before the trip. Gaiters help in snow. Headlamp with extra batteries because summit push is before sunrise.

Fitness: start running 4 km every morning from now, and climb stairs with a 10 kg bag twice a week. Squats and lunges for the legs.

Medicines: Diamox only if the doctor says so, ORS sachets, paracetamol, crepe bandage, blister plasters.

रास्ते के लिए ड्राई फ्रूट्स और चॉकलेट रख लेना।''',
    // DBMS revision.
    'dbmsNotes': '''DBMS unit 3 notes

Normalization removes redundancy. 1NF: atomic values, no repeating groups. 2NF: no partial dependency on part of a composite key. 3NF: no transitive dependency, every non-key attribute depends only on the key. BCNF is stricter: for every functional dependency X to Y, X must be a superkey.

Indexing: a B+ tree index keeps keys sorted in the leaves, which are linked, so range queries are fast. Hash index is good for equality search only. A clustered index decides the physical order of rows; a table can have only one.

Transactions follow ACID. Atomicity: all or nothing. Consistency: the database moves from one valid state to another. Isolation: concurrent transactions do not see each other's half work. Durability: committed data survives a crash, thanks to the log.

Ma'am said questions on serializability and two-phase locking are likely in the end sem.''',
    'dbmsRevise': '''SQL and database revision before the exam

Joins first. Inner join keeps matching rows only; left join keeps every row of the left table and fills nulls. Self join for employee and manager in the same table.

Keys: super key, candidate key, primary key. Functional dependencies decide the normal form, so practise finding the closure of attributes and checking if a decomposition is lossless.

Concurrency control: two-phase locking has a growing phase and a shrinking phase, and it guarantees conflict serializability. Deadlocks can still happen, so know wait-die and wound-wait.

Recovery uses the write-ahead log; redo committed, undo the rest.

Solve last three years papers this weekend. परीक्षा से पहले normalization के सवाल फिर से करने हैं।''',
    // Capstone IoT project.
    'iotMeeting': '''Capstone meeting, week 4

Project: soil moisture monitoring for small farms, with an alert to the farmer when the field is too dry. Faculty guide wants a working prototype by the mid review.

Hardware decided: ESP32 board, capacitive soil moisture sensor, DHT22 for temperature and humidity, and a small solar panel with a battery. Data goes to the cloud every 15 minutes over WiFi; we still have to check network coverage at the test farm.

Tasks: Aman does the circuit and soldering, Priya the dashboard, I write the firmware and the alert logic. Budget is around 4,500 rupees; the department reimburses with bills.

Next meeting Thursday. Bring the sensor readings from the pot test.''',
    'iotSensors': '''Notes on soil moisture sensors

Resistive sensors are cheap but the metal probes corrode within weeks, because current flows through the soil. Capacitive sensors measure the dielectric change instead, have no exposed metal, and last much longer, so they suit a field deployment.

Calibration: read the value in dry air and in a glass of water, then map the range to 0 to 100 percent. Different soils need their own calibration.

The ESP32 ADC is non linear near the ends; take ten samples and average. Deep sleep between readings saves a lot of battery, which matters on solar power.

For irrigation alerts, use a threshold with hysteresis so the alert does not flap when the value hovers near the limit.''',
    // Fitness.
    'gymPlan': '''Gym routine from this month

Push pull legs, six days a week, Sunday rest. Push: bench press, overhead press, dips, triceps pushdown. Pull: deadlift, pull ups, rows, biceps curls. Legs: squats, leg press, Romanian deadlift, calf raises.

Progressive overload: add 2.5 kg when I can do all sets for 8 reps. Warm up ten minutes on the cycle first, my knee hurts otherwise.

Diet: about 120 g protein a day. Eggs in the morning, paneer or chicken at lunch, a scoop of whey after the workout. Sleep at least seven hours.

Track weight every Monday morning.''',
    'dietPlan': '''Protein and diet plan

Goal is to build muscle without much fat gain, so a small calorie surplus of about 250. Protein target 1.6 g per kg body weight.

Breakfast: four egg whites and two whole eggs, oats with milk. Lunch: dal, rice, paneer sabzi, salad. Post workout: whey with banana. Dinner: chicken or soya chunks with roti.

सुबह भीगे हुए चने और रात को दूध। Cut down sugar and fried snacks from the canteen.

Drink three litres of water. Creatine 3 g daily is fine according to the trainer.''',
    // Money.
    'budget': '''Monthly budget, October

Pocket money and internship stipend together come to 18,000. Rent share 6,000, mess 3,500, phone and internet 600, travel 1,000.

Savings: start a SIP of 2,000 a month in a Nifty 50 index fund, and keep 3,000 aside as an emergency fund until it reaches three months of expenses.

Stop ordering food more than twice a week; that alone was 2,500 last month.

Track every expense in the sheet daily.''',
    'funds': '''What I learnt about mutual funds

An index fund just copies an index like the Nifty 50, so the expense ratio is low, around 0.2 percent, and there is no fund manager guessing. Over long periods most active funds fail to beat the index after fees.

SIP means investing a fixed amount every month, which averages the buying price over ups and downs. Starting early matters more than the amount because of compounding.

Direct plans have a lower expense ratio than regular plans sold through agents. Keep an emergency fund in a liquid fund or savings account before investing in equity.

Long term capital gains above 1.25 lakh a year are taxed.''',
    // A journal day that touches several topics.
    'journal': '''Tuesday

Woke up late again. Class on transactions and two-phase locking was actually interesting today; I finally understood why the shrinking phase cannot take new locks.

After lunch the capstone team tested the capacitive sensor in a pot of soil. The readings jumped around until we averaged ten samples, and Aman wants to add deep sleep to save battery.

Evening gym was legs day, squats felt heavy. Need to eat more protein, I skipped eggs this morning.

Called home. Papa asked about the December trek and the train booking; I told him we are going from Dehradun to Sankri.''',
  };

  /// Short notes, each about one paragraph of the journal.
  static const short = <String, String>{
    'shortLocks':
        'Revise two-phase locking and serializability for the DBMS exam.',
    'shortSensor':
        'Average ten ADC samples from the soil moisture sensor before sending.',
    'shortProtein':
        'Eat more protein: eggs every morning and whey after the gym.',
    'shortTrain':
        'Book train tickets to Dehradun for the Sankri trek in December.',
  };

  /// Pairs that belong together.
  static const related = <(String, String)>[
    ('trekPlan', 'trekPack'),
    ('dbmsNotes', 'dbmsRevise'),
    ('iotMeeting', 'iotSensors'),
    ('gymPlan', 'dietPlan'),
    ('budget', 'funds'),
    ('journal', 'shortLocks'),
    ('journal', 'shortSensor'),
    ('journal', 'shortProtein'),
    ('journal', 'shortTrain'),
    ('dbmsNotes', 'shortLocks'),
    ('iotSensors', 'shortSensor'),
    ('dietPlan', 'shortProtein'),
    ('trekPlan', 'shortTrain'),
  ];

  /// Every pair across the five topic groups counts as unrelated (the
  /// journal is left out: it touches every topic).
  static const groups = <List<String>>[
    ['trekPlan', 'trekPack', 'shortTrain'],
    ['dbmsNotes', 'dbmsRevise', 'shortLocks'],
    ['iotMeeting', 'iotSensors', 'shortSensor'],
    ['gymPlan', 'dietPlan', 'shortProtein'],
    ['budget', 'funds'],
  ];
}
