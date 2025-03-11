# Research System Database Documentation  
**Version 1.0**  

---

## Schema Overview  
A relational database supporting:  
- **User authentication** (Google OAuth + Email/Password)  
- **Questionnaire creation** with dynamic questions  
- **Response collection** and filtering  
- **PDF report generation** (manual/auto)  

---

## Tables  

### 1. `users`  
| **Field**         | **Type**       | **Description**                          |  
|--------------------|----------------|------------------------------------------|  
| `user_id`          | `CHAR(36)`     | UUID primary key                         |  
| `username`         | `VARCHAR(255)` | Unique username                          |  
| `email`            | `VARCHAR(255)` | Unique email                             |  
| `auth_provider`    | `ENUM`         | `google` or `email_password`             |  
| `password_hash`    | `VARCHAR(255)` | Nullable for Google OAuth users          |  
| `google_id`        | `VARCHAR(255)` | Unique for Google OAuth users            |  
| `is_verified`      | `BOOLEAN`      | Email verification status                |  

---

### 2. `password_reset_tokens`  
| **Field**       | **Type**       | **Description**                          |  
|------------------|----------------|------------------------------------------|  
| `token_id`       | `INT`          | Auto-increment primary key               |  
| `user_id`        | `CHAR(36)`     | Foreign key to `users.user_id`           |  
| `token`          | `VARCHAR(255)` | Unique reset token                       |  

---

### 3. `questionnaires`  
| **Field**            | **Type**       | **Description**                          |  
|-----------------------|----------------|------------------------------------------|  
| `questionnaire_id`    | `CHAR(36)`     | UUID primary key                         |  
| `user_id`             | `CHAR(36)`     | Foreign key to `users.user_id`           |  
| `title`               | `VARCHAR(255)` | Questionnaire title                      |  

---

### 4. `questions`  
| **Field**            | **Type**       | **Description**                          |  
|-----------------------|----------------|------------------------------------------|  
| `question_id`         | `CHAR(36)`     | UUID primary key                         |  
| `questionnaire_id`    | `CHAR(36)`     | Foreign key to `questionnaires`          |  
| `question_type`       | `ENUM`         | `text`, `number`, `multiple_choice`, `date` |  

---

### 5. `responses`  
| **Field**            | **Type**       | **Description**                          |  
|-----------------------|----------------|------------------------------------------|  
| `response_id`         | `CHAR(36)`     | UUID primary key                         |  
| `user_id`             | `CHAR(36)`     | Foreign key to `users.user_id`           |  
| `question_id`         | `CHAR(36)`     | Foreign key to `questions.question_id`   |  
| `response_value`      | `TEXT`         | Answer data (text/number/option ID)      |  

---

### 6. `pdf_reports`  
| **Field**            | **Type**       | **Description**                          |  
|-----------------------|----------------|------------------------------------------|  
| `report_id`           | `CHAR(36)`     | UUID primary key                         |  
| `questionnaire_id`    | `CHAR(36)`     | Foreign key to `questionnaires`          |  
| `generation_method`   | `ENUM`         | `auto` (system) or `manual` (user)       |  
| `filter_criteria`     | `JSON`         | E.g., `{"age": {"min": 25}}`             |  

---

## Relationships  

### 1. **User-to-Questionnaire (1:N)**  
- **Description**: A user creates multiple questionnaires.  
- **Implementation**:  
  ```sql
  ALTER TABLE questionnaires
  ADD CONSTRAINT fk_user_questionnaires
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;



  ## 2. Database Schema  

### 2.1 Tables  

#### 2.1.1 `users`  
- **Primary Key**: `user_id` (UUID)  
- **Fields**:  
  - `username` (Unique)  
  - `email` (Unique)  
  - `auth_provider` (`google`/`email_password`)  
  - `password_hash` (Bcrypt)  
  - `google_id` (Unique for Google OAuth)  

#### 2.1.2 `password_reset_tokens`  
- **Primary Key**: `token_id` (Auto-Increment)  
- **Relationships**:  
  - `user_id` → `users.user_id` (CASCADE)  

#### 2.1.3 `questionnaires`  
- **Primary Key**: `questionnaire_id` (UUID)  
- **Relationships**:  
  - `user_id` → `users.user_id` (CASCADE)  

---

### 2.2 Relationships  

#### 2.2.1 User-to-Questionnaires (1:N)  
- **Parent**: `users`  
- **Child**: `questionnaires`  
- **SQL**:  
  ```sql
  ALTER TABLE questionnaires
  ADD FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;


  ### 3.2 Foreign Key Constraints  

| Parent Table       | Child Table        | Foreign Key           | On Delete       |  
|--------------------|--------------------|-----------------------|-----------------|  
| `users`            | `questionnaires`   | `user_id`             | CASCADE         |  
| `questionnaires`   | `questions`        | `questionnaire_id`    | CASCADE         |  
| `questions`        | `responses`        | `question_id`         | CASCADE         |  
| `users`            | `responses`        | `user_id`             | CASCADE         |  
| `questionnaires`   | `pdf_reports`      | `questionnaire_id`    | CASCADE         |  

---

## 4. Indexes  

| Index Name               | Table         | Fields                  | Purpose                          |  
|--------------------------|---------------|-------------------------|----------------------------------|  
| `idx_users_auth`         | `users`       | `auth_provider`         | Optimize authentication queries  |  
| `idx_questions_type`     | `questions`   | `question_type`         | Filter by question type          |  
| `idx_pdf_filters`        | `pdf_reports` | `filter_criteria`       | Accelerate JSON-based filtering  |  
| `idx_responses_submitted`| `responses`   | `submitted_at`          | Time-based response analysis     |  

---

## 6. Conclusion & Acknowledgements  
**System Developed By**: **[Exiyom Tech Solution](https://exiyom.com)**  
- A dynamic startup incubated at **Bitec Makerspace**, specializing in scalable research and education technologies.  
- Special thanks to the Bitec Makerspace team for their incubation support and resources.  

**© 2025 Exiyom Tech Solution | Bitec Makerspace Incubatee**  