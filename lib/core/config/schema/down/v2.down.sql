-- Migration DOWN: rollback for todos / recurrences / tags schema
-- LƯU Ý: Thao tác này sẽ xóa bảng và dữ liệu liên quan. BACKUP trước khi thực thi.
BEGIN;

-- 1) Drop triggers (IF EXISTS để idempotence)
DROP TRIGGER IF EXISTS on_auth_user_created_seed_tags ON auth.users;

DROP TRIGGER IF EXISTS handle_updated_at_todos ON public.todos;

-- 2) Drop row-level security policies
DROP POLICY IF EXISTS "Users can manage their todo tags" ON public.todo_tags;

DROP POLICY IF EXISTS "Users can manage their own tags" ON public.tags;

DROP POLICY IF EXISTS "Policy for recurrences based on todo ownership" ON public.recurrences;

DROP POLICY IF EXISTS "Users can manage their own todos" ON public.todos;

-- 3) Disable RLS so drops won't be blocked (safe even if already disabled)
ALTER TABLE IF EXISTS public.todo_tags DISABLE ROW LEVEL SECURITY;

ALTER TABLE IF EXISTS public.tags DISABLE ROW LEVEL SECURITY;

ALTER TABLE IF EXISTS public.recurrences DISABLE ROW LEVEL SECURITY;

ALTER TABLE IF EXISTS public.todos DISABLE ROW LEVEL SECURITY;

-- 4) Drop dependent objects in dependency-safe order
DROP TABLE IF EXISTS public.todo_tags;

DROP TABLE IF EXISTS public.recurrences;

DROP TABLE IF EXISTS public.tags;

DROP TABLE IF EXISTS public.todos;

-- 5) Drop indexes (harmless if already removed with tables)
DROP INDEX IF EXISTS public.idx_todo_tags_tag_id;

DROP INDEX IF EXISTS public.idx_tags_user_name;

DROP INDEX IF EXISTS public.idx_tags_user_id;

DROP INDEX IF EXISTS public.idx_recurrences_todo_id;

DROP INDEX IF EXISTS public.idx_todos_user_due_date;

DROP INDEX IF EXISTS public.idx_todos_user_status;

DROP INDEX IF EXISTS public.idx_todos_user_id;

-- 6) Drop functions used by triggers
DROP FUNCTION IF EXISTS public.seed_default_tags () CASCADE;

-- 7) Drop extension used for moddatetime trigger
DROP EXTENSION IF EXISTS moddatetime CASCADE;

-- 8) Drop enum types
DROP TYPE IF EXISTS public.recurrence_pattern;

DROP TYPE IF EXISTS public.todo_status;

DROP TYPE IF EXISTS public.todo_priority;

COMMIT;

-- End of DOWN migration