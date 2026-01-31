-- =================================================
-- 1. DROP TRIGGERS
-- =================================================
DROP TRIGGER IF EXISTS on_auth_user_created_seed_tags ON auth.users;

DROP TRIGGER IF EXISTS handle_updated_at_todos ON public.todos;

DROP TRIGGER IF EXISTS handle_updated_at_projects ON public.projects;

-- =================================================
-- 2. DROP FUNCTIONS
-- =================================================
DROP FUNCTION IF EXISTS public.seed_default_tags ();

-- =================================================
-- 3. DROP TABLES (theo thứ tự phụ thuộc)
-- =================================================
DROP TABLE IF EXISTS public.attachments;

DROP TABLE IF EXISTS public.todo_tags;

DROP TABLE IF EXISTS public.tags;

DROP TABLE IF EXISTS public.recurrences;

DROP TABLE IF EXISTS public.todos;

DROP TABLE IF EXISTS public.projects;

-- =================================================
-- 4. DROP TYPES (ENUMS)
-- =================================================
DROP TYPE IF EXISTS public.attachment_file_extension;

DROP TYPE IF EXISTS public.recurrence_pattern;

DROP TYPE IF EXISTS public.todo_status;

DROP TYPE IF EXISTS public.todo_priority;

-- =================================================
-- 5. DROP EXTENSIONS (nếu muốn rollback hoàn toàn)
-- ⚠️ Chỉ drop nếu chắc chắn extension không dùng nơi khác
-- =================================================
DROP EXTENSION IF EXISTS moddatetime;