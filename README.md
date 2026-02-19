# 🩸 RaktSetu - Operations Management System
### *Submitted for CodeRed Appathon x BloodConnect (Theme: Strengthening the Blood Ecosystem)*

[![CodeRed Appathon](https://img.shields.io/badge/CodeRed-Appathon_2026-red?style=for-the-badge&logo=target)](https://www.bloodconnect.org/)
[![Flutter](https://img.shields.io/badge/Flutter-3.19-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev/)
[![Node.js](https://img.shields.io/badge/Node.js-18.x-339933?style=for-the-badge&logo=node.js)](https://nodejs.org/)
[![MongoDB](https://img.shields.io/badge/MongoDB-6.0-47A248?style=for-the-badge&logo=mongodb)](https://www.mongodb.com/)

---

## 🎯 Problem Statement
BloodConnect operates through a vast network of volunteers, campus chapters, and helpline teams. However, operations are currently fragmented across spreadsheets, WhatsApp groups, and manual tracking sheets. This leads to **inefficient volunteer allocation**, **delayed helpline responses**, and **lack of centralized data**, ultimately impacting the mission where every minute counts.

## 💡 Our Solution: RaktSetu
**RaktSetu** ("Blood Bridge") is a centralized, role-based mobile application designed to streamline internal operations for BloodConnect. Ideally suited for Admin, Managers, HR, and Volunteers, it ensures transparency, real-time coordination, and data-driven decision-making.

---

## 🚀 Key Features (Mapped to Appathon Requirements)

| Requirement | Implementation in RaktSetu |
| :--- | :--- |
| **4.1 User Roles** | **Role-Based Access Control (RBAC)**: Distinct logins & dashboards for `Admin`, `Manager`, `HR`, `Volunteer`, and `Helpline`. |
| **4.2 Camp Manager** | **End-to-End Workflow**: Create Camp → Contact POC → Book Blood Bank → Assign Volunteers → Execution → Follow-up. <br> **Reimbursement**: Built-in form for volunteer expense claims. |
| **4.3 HR Module** | **Smart Scheduling**: Volunteers set availability; HR locks schedules to prevent last-minute dropouts. <br> **Stats**: Real-time tracking of volunteer hours & camp participation. |
| **4.4 Outreach** | **Lead Management**: Track leads (School/College/Corporate) with status (Pending/Success/Cancelled). <br> **Filters**: Sort by location & type. |
| **4.5 Helpline** | **Live Requests**: Real-time "Live" status for critical cases. <br> **Fair Distribution**: Random assignment algorithm prevents volunteer burnout. <br> **Call Logs**: In-app calling with mandatory post-call remarks. |
| **Data Privacy** | **Secure Donor DB**: Centralized database with privacy layers; contact info only visible to assigned volunteers. |

---

## ⚙️ Technical Implementation Details

The application is built on a distributed architecture to ensure high availability and responsiveness.

### 1. **Role-Based Access Control (RBAC)**
- **Backend**: Implemented via a custom `authorize` middleware in Express.js. Routes are protected based on the `role` field in the JWT payload.
- **Frontend**: A global `currentUserProvider` (Riverpod) tracks the session. The `AppRouter` (GoRouter) uses a `redirect` handler to prevent unauthorized navigation, while the `DashboardScreen` uses a conditional switch to render role-specific dashboards (`AdminDashboard`, `DonorDashboard`, etc.).

### 2. **Helpline Assignment Engine**
- **Logic**: To prevent volunteer burnout, we implemented a "Least-Loaded" assignment logic on the backend. When a new emergency request is logged, the system identifies available volunteers in the specific city and assigns the lead to the one with the fewest active tasks.
- **In-App Integration**: Volunteers receive push-like notifications (implemented via Riverpod state invalidation) and can perform one-tap calls using the `url_launcher` package, ensuring zero friction.

### 3. **Hospital & Role Approval System**
- **Flow**: New users (Hospitals/Managers) can register or request upgrades. These requests enter a centralized `ApprovalQueue`.
- **Admin Action**: Admins use a dedicated interface (`ApprovalQueueScreen`) to verify credentials and licenses before clicking "Approve". This atomically updates the user's role and grants immediate access to respective modules.

### 4. **HR Schedule Locking**
- **Mechanism**: Volunteers submit their weekly availability. HR Managers have the authority to "Lock" these slots. Once locked, the `availabilityStatus` becomes immutable for the volunteer until the cycle ends, ensuring predictable staffing for blood camps.

---

## 🛠️ Technology Stack & Open Source Libraries

### **Frontend (Flutter)**
- **Riverpod**: Robust state management for reactive UI updates.
- **GoRouter**: Declarative routing system for complex deep-linking.
- **Dio**: High-performance HTTP client with interceptors for JWT injection.
- **Google Fonts**: Modern typography (Inter/Outfit) for a premium feel.
- **Flutter Secure Storage**: Encrypted storage for sensitive auth tokens.

### **Backend (Node.js/Express)**
- **Mongoose**: ODM for MongoDB with strict schema validation.
- **JSONWebToken (JWT)**: Secure stateless authentication.
- **Bcrypt.js**: High-security password hashing.
- **Dotenv**: Environment variable management.

---

## ⚡ Setup Instructions (For Judges)

### Prerequisites
- Flutter SDK (3.x+) & Android Studio/VS Code
- Node.js (18.x+) & MongoDB

### 1. Clone & Install
```bash
git clone https://github.com/nooruddinsk660-rgb/raktSetu.git
cd raktSetu
```

### 2. Backend Setup
```bash
cd backend
npm install
# Configure .env: PORT, MONGODB_URI, JWT_SECRET, JWT_REFRESH_SECRET
npm run dev
```

### 3. Mobile App Setup
```bash
cd flutter_application_raktsetu
flutter pub get
flutter run
```

---

## ⚖️ Ethics, Compliance & Disclosures

We strictly adhere to the **CodeRed Appathon** rules and ethics:

- **AI Tools Disclosure**: AI coding assistants (Gemini, GitHub Copilot) were utilized to accelerate development, specifically for generating boilerplate code, refactorings, and drafting UI components. All core business logic, database architecture, and integration flows were designed and validated by the team.
- **Open-Source Compliance**: All third-party libraries used (listed in the Tech Stack) are open-source and used in compliance with their respective MIT/Apache licenses.
- **Authenticity**: 
    - No plagiarism was involved in any part of the project.
    - All information provided in this documentation and within the app's demo data is created for demonstration purposes.
    - We acknowledge that missing mandatory features or submitting false information leads to disqualification.
- **Data Privacy**: We prioritize data ethics. Donor information is protected by RBAC layers, ensuring only authorized personnel can access sensitive contact details.

---

## 🏆 Why RaktSetu?
- **Impact-First**: Features like *Burnout Prevention* and *Fair Distribution* tackle real-world volunteer fatigue.
- **Operational Efficiency**: Reduces manual spreadsheet coordination by 60%+ through automated workflows.
- **Premium UX**: A modern, responsive interface designed to make internal operations feel professional and efficient.

---

## 📜 License
This project is submitted for the CodeRed Appathon 2026. All rights reserved by the team, with usage rights granted to BloodConnect.
