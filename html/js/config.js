// Google Apps Script Web App URL
// 請將此 URL 替換為您部署的 Google Apps Script Web App URL
const GOOGLE_SCRIPT_URL = 'https://script.google.com/macros/s/AKfycbzeAZjeeu-i_zxZ7yqtMhF-GlqRolONshl3DVckvv9jNxdWlvUSSnscDaAeVfLUQ7Ss/exec';

// Google OAuth Client ID
// 請前往 https://console.cloud.google.com/apis/credentials 建立 OAuth 2.0 客戶端 ID
const GOOGLE_CLIENT_ID = '487197553483-ob3hv43l2kkvunkc0nqc9bd3kj6f8v8g.apps.googleusercontent.com';

// Supabase 配置
const SUPABASE_URL = 'https://lvrcnmvnqbueghjyvxji.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx2cmNubXZucWJ1ZWdoanl2eGppIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIyNTgzOTUsImV4cCI6MjA3NzgzNDM5NX0.l6DMlnQx3YXqTe85yQqcDm3i9cIr7hAFdi3N-6OnAn0'; // 請在 Supabase Dashboard > Settings > API 取得

// 資料來源選擇：'java-api'、'supabase' 或 'google-sheets'
// 'java-api' - 使用 Java Spring Boot 後端 API（推薦）
// 'supabase' - 直接使用 Supabase 客戶端
// 'google-sheets' - 使用 Google Apps Script
const DATA_SOURCE = 'supabase'; // 使用 Supabase（暫時不需要 Java 後端）

