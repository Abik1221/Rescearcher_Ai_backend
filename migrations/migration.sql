CREATE DATABASE IF NOT EXISTS research_system;
USE research_system;

-- Users Table (Dual Authentication)
CREATE TABLE users (
    user_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    username VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    auth_provider ENUM('google', 'email_password') NOT NULL,
    password_hash VARCHAR(255),
    google_id VARCHAR(255) UNIQUE,
    full_name VARCHAR(255) NOT NULL,
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,

    CONSTRAINT chk_auth_consistency CHECK (
        (auth_provider = 'google' AND google_id IS NOT NULL AND password_hash IS NULL) OR
        (auth_provider = 'email_password' AND password_hash IS NOT NULL AND google_id IS NULL)
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Password Reset System
CREATE TABLE password_reset_tokens (
    token_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    token VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    used BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Questionnaires
CREATE TABLE questionnaires (
    questionnaire_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Questions
CREATE TABLE questions (
    question_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    questionnaire_id CHAR(36) NOT NULL,
    question_type ENUM('text', 'number', 'multiple_choice', 'date') NOT NULL,
    question_text TEXT NOT NULL,
    is_required BOOLEAN NOT NULL DEFAULT FALSE,
    display_order INT NOT NULL,
    FOREIGN KEY (questionnaire_id) REFERENCES questionnaires(questionnaire_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Responses
CREATE TABLE responses (
    response_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36) NOT NULL,
    questionnaire_id CHAR(36) NOT NULL,
    question_id CHAR(36) NOT NULL,
    response_value TEXT NOT NULL,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (questionnaire_id) REFERENCES questionnaires(questionnaire_id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES questions(question_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- PDF Reports
CREATE TABLE pdf_reports (
    report_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    questionnaire_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    storage_path VARCHAR(255) NOT NULL,
    generation_method ENUM('auto', 'manual') NOT NULL,
    filter_criteria JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (questionnaire_id) REFERENCES questionnaires(questionnaire_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Indexes
CREATE INDEX idx_users_auth ON users(auth_provider);
CREATE INDEX idx_questions_type ON questions(question_type);
CREATE INDEX idx_responses_submitted ON responses(submitted_at);